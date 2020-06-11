import os
import pathlib
import re
from typing import List, Dict, Optional, Union

import pandas as pd  # type: ignore
import scipy.io  # type: ignore

from analysex.file_map import file_map  # type: ignore
from analysex.isodens.plot import plot_data_norm, plot_data_total  # type: ignore
from analysex.plot_assbly_keff import parse_burnup_vs_keff_drag_assbly  # type: ignore


def extract_VOLUME_MIX(filename: str) -> Optional[List[float]]:
    s = pathlib.Path(filename).read_text()

    pat = re.compile(r'''
    (?P<mix_count>\d+)\s+<-\s*\n
    VOLUME-MIX\s*\n
    (?P<volumes>.*?)\s*\n
    ->
    ''', flags=re.MULTILINE | re.DOTALL | re.X)

    m = pat.search(s)
    if m:
        mix_count = int(m.group('mix_count'))
        volumes = [float(i) for i in m.group('volumes').strip().split()]
        assert mix_count == len(volumes)
        print(f'Total volume {sum(volumes)} cc')
        return volumes
    else:
        print('Not found')
        return None


def extract_ISOTOPESMIX(filename: str) -> Optional[List[int]]:
    s = pathlib.Path(filename).read_text()

    pat = re.compile(r'''
    (?P<iso_count>\d+)\s+<-\s*\n
    ISOTOPESMIX\s*\n
    (?P<mix_num>.*?)\s*\n
    ->
    ''', flags=re.MULTILINE | re.DOTALL | re.X)

    m = pat.search(s)
    if m:
        iso_count = int(m.group('iso_count'))
        mix_num = re.findall(r'\s*(\d+)', m.group('mix_num'))
        mix_num = [int(i) for i in mix_num]
        return mix_num
    else:
        print('Not found')
        return None


def extract_ISOTOPESUSED(filename: str) -> Optional[List[List[Union[int, str]]]]:
    s = pathlib.Path(filename).read_text()

    pat = re.compile(r'''
    (?P<iso_count>\d+)\s+<-\s*\n
    ISOTOPESUSED\s*\n
    (?P<iso_names>.*?)\s*\n
    ->
    ''', flags=re.MULTILINE | re.DOTALL | re.X)

    m = pat.search(s)
    if m:
        iso_count = int(m.group('iso_count'))
        # iso_names = re.findall(r'\s*(\d+)', m.group('iso_names'))
        # iso_names = [int(i) for i in iso_names]
        # print(iso_count)
        iso_names = m.group('iso_names')
        iso_names = iso_names.replace(' 4', '').replace('\n', '').strip()

        iso_names_list = re.findall(r'(\w+)\s+(\d+)', iso_names)
        assert iso_count == 3 * len(iso_names_list)
        # print(len(iso_names), iso_names)
        # print(Counter(iso_names))
        iso_names = [i for i, _ in iso_names_list]  # type: ignore

        # remove iso name extensions
        # to calculate volume fractions correctly
        for i, name in enumerate(iso_names):
            if name.endswith('Gd'):
                iso_names[i] = name.replace('Gd', '')
            elif name.endswith('Gd2'):
                iso_names[i] = name.replace('Gd2', '')

        return iso_names
    else:
        print('Not found')
        return None


def extract_ISOTOPESDENS(filename: str, debug: bool = False) -> Optional[Dict[str, List[str]]]:
    s = pathlib.Path(filename).read_text()

    pat = re.compile(r'''
    DEPL-DAT(?P<step>\d+)\s*\n
    ->.*?(?P<dens_count>\d+)\s+<-\s*\n
    ISOTOPESDENS\s*\n
    (?P<densities>.*?)\s*\n
    ->
    ''', flags=re.MULTILINE | re.DOTALL | re.X)

    data = {}
    for m in pat.finditer(s):
        dens_count = int(m.group('dens_count'))
        step = str(int(m.group('step')))
        densities = m.group('densities').split()
        assert dens_count == len(densities)
        data['burn' + step] = densities
    if debug:
        print(pd.DataFrame.from_dict(data, orient='index').to_string())

    return data


def create_mix_vol_map(mix_numbers: List[int], volumes: List[float]) -> Dict[int, float]:
    unique_mix_nums = list(set(mix_numbers))
    map = {}
    for i, mix in enumerate(unique_mix_nums):
        map[mix] = volumes[i]
    print(map)
    return map


def total_burnup(row: pd.DataFrame) -> pd.DataFrame:
    # print(row.to_string())
    iso_name = row.iso_name.iloc[0] + '_total'
    burn = [k for k in row.keys() if 'burn' in k]
    row[burn] = row[burn].astype(float).multiply(row["iso_vol_frac"], axis="index")
    row = row.sum()
    row.iso_name = iso_name
    row.mix_number = 0
    # print(row.to_string())
    return row


def save_iso(df: pd.DataFrame, iso_name: str = 'U238') -> None:
    x = df.loc[df.iso_name.isin([iso_name, iso_name + 'Gd'])].iloc[:, :6]
    with pd.ExcelWriter(f"{iso_name}.xlsx", engine='xlsxwriter') as writer:
        x.to_excel(writer, sheet_name=iso_name, startrow=1, startcol=1)


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).resolve().parent.parent.parent)
    d = file_map

    for key in d.keys():
        if key != 'ASSBLY_B':
            continue

        print(key)
        burnup_vs_keff = parse_burnup_vs_keff_drag_assbly(
            s=pathlib.Path(d[key]['drag_res']).read_text()
        )
        burnup_vs_keff = pd.DataFrame(burnup_vs_keff, columns=['b_step', 'k_eff'])
        serp_dep_data = scipy.io.loadmat(d[key]['serp_dep'])

        filename = d[key]['drag_burn']
        volumes = extract_VOLUME_MIX(filename)
        mix_numbers = extract_ISOTOPESMIX(filename)
        mix_vol_map = create_mix_vol_map(mix_numbers, volumes)
        iso_names = extract_ISOTOPESUSED(filename)
        densities = extract_ISOTOPESDENS(filename)

        data = dict(  # type: ignore
            iso_name=iso_names,
            mix_number=mix_numbers,
            **densities,
        )
        df = pd.DataFrame(data)

        df.insert(2, 'mix_volume', df.apply(lambda row: mix_vol_map[row.mix_number], axis=1))
        iso_volumes = df.groupby('iso_name').apply(lambda x: x.mix_volume.sum())

        df.insert(3, 'iso_volume', [iso_volumes[name] for name in iso_names])
        df.insert(4, 'iso_vol_frac', df.apply(lambda row: row.mix_volume / row.iso_volume, axis=1))
        # save_iso(df, iso_name='U238')
        g = df.groupby('iso_name')
        tot_burn = g.apply(lambda x: total_burnup(x))
        df = df.append(tot_burn, ignore_index=True)
        # df.apply(lambda row: sum(total_burn(row)), axis=1)
        df = df.set_index('iso_name')
        print(df.iloc[:7, 0:7].to_string())
        # print(df.to_string())

        iso_lists = [
            (
                'U235_total',
                'Pu239_total',
                'Pu241_total',
            ),
            (
                'U235_total',
                'U236_total',
                'U238_total',
            ),
            (
                'Np237_total',
                'Pu239_total',
                'Pu240_total',
                'Pu241_total',
                'Pu242_total',
            ),
            (
                'Sm147_total',
                'Sm149_total',
                'Sm150_total',
                'Sm151_total',
                'Sm152_total',
                'Eu153_total',
            ),
        ]

        for i, tpl in enumerate(iso_lists):
            plot_data_norm(
                df, burnup_vs_keff, serp_dep_data,
                filename=f'all_plots/{key}_{i}_norm_density.png',
                iso_list=tpl,
                title=f"$Normalized \ total \ atomic \ density \ vs \ burnup$\n {d[key]['serp_dep']}\n {d[key]['drag_burn']}\n"
            )

            plot_data_total(
                df, burnup_vs_keff, serp_dep_data,
                filename=f'all_plots/{key}_{i}_total_density.png',
                iso_list=tpl,
                save_data=True,
                title=f"$Total \ atomic \ density \ vs \ burnup$\n {d[key]['serp_dep']}\n {d[key]['drag_burn']}\n"
            )
            # with pd.ExcelWriter("burn.xlsx", engine='xlsxwriter') as writer:
            #     df.to_excel(writer, sheet_name='burn', startrow=1, startcol=1)
