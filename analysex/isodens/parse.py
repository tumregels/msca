import os
import pathlib
import re
from typing import List, Dict, Optional, Union

import pandas as pd  # type: ignore
import scipy.io  # type: ignore

from analysex.isodens.plot import plot_data
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
        iso_names_list = [i for i, _ in iso_names_list]  # type: ignore
        return iso_names_list
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


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).resolve().parent.parent.parent)

    d = {
        'PIN_A': {
            'drag_res': 'Dragon/PIN_A/output_2020-06-09_17-14-57/CGN_PIN_A.result',
            'drag_pat': r'>\|\+\+\+ Burnup=(?P<burnup>.*?)\s+Keff=(?P<keff>.*?)\s+(?=\|>\d+)',
            'drag_burn': 'Dragon/PIN_A/output_2020-06-09_17-14-57/_BURN_rowland.txt',
            'serp_dep': 'Serpent/PIN_A/output_2020-05-11_22-39-35/PIN_CASEA_mc_dep.mat',
            'serp_res': 'Serpent/PIN_A/output_2020-05-11_22-39-35/PIN_CASEA_mc_res.mat',
        },
        'PIN_B': {
            'drag_res': 'Dragon/PIN_B/output_2020-06-09_17-16-38/CGN_PIN_B.result',
            'drag_pat': r'>\|\+\+\+ Burnup=(?P<burnup>.*?)\s+Keff=(?P<keff>.*?)\s+(?=\|>\d+)',
            'drag_burn': 'Dragon/PIN_B/output_2020-06-09_17-16-38/_BURN_rowland.txt',
            'serp_dep': 'Serpent/PIN_B/output_2020-05-11_22-39-42/PIN_CASEB_mc_dep.mat',
            'serp_res': 'Serpent/PIN_B/output_2020-05-11_22-39-42/PIN_CASEB_mc_res.mat',
        },
        'PIN_C': {
            'drag_res': 'Dragon/PIN_C/output_2020-06-09_17-18-27/CGN_PIN_C.result',
            'drag_pat': r'>\|\+\+\+ Burnup=(?P<burnup>.*?)\s+Keff=(?P<keff>.*?)\s+(?=\|>\d+)',
            'drag_burn': 'Dragon/PIN_C/output_2020-06-09_17-18-27/_BURN_rowland.txt',
            'serp_dep': 'Serpent/PIN_C/output_2020-05-11_22-39-48/PIN_CASEC_mc_dep.mat',
            'serp_res': 'Serpent/PIN_C/output_2020-05-11_22-39-48/PIN_CASEC_mc_res.mat',
        },
        'ASSBLY_A': {
            'drag_res': 'Dragon/ASSBLY_A/output_2020-06-06_13-46-57/ASSBLY_CASEA.result',
            'drag_pat': r'>\|\+\+\+ Burnup=(?P<burnup>.*?)\s+Keff=(?P<keff>.*?)\s+(?=\|>\d+)',
            'drag_burn': 'Dragon/ASSBLY_A/output_2020-06-06_13-46-57/ASSBLY_CASEA_BURN2.txt',
            'serp_dep': 'Serpent/ASSEMBLY_A/output_2020-05-13_12-24-33/ASSBLY_CASEA_mc_dep.mat',
            'serp_res': 'Serpent/ASSEMBLY_A/output_2020-05-13_12-24-33/ASSBLY_CASEA_mc_res.mat',
        },
        'ASSBLY_B': {
            'drag_res': 'Dragon/ASSBLY_B/output_2020-06-06_13-45-45/ASSBLY_CASEB.result',
            'drag_pat': r'>\|\+\+\+ Burnup=(?P<burnup>.*?)\s+Keff=(?P<keff>.*?)\s+(?=\|>\d+)',
            'drag_burn': 'Dragon/ASSBLY_B/output_2020-06-06_13-45-45/ASSBLY_CASEB_BURN2.txt',
            'serp_dep': 'Serpent/ASSEMBLY_B/output_2020-05-13_22-47-03/ASSBLY_CASEB_mc_dep.mat',
            'serp_res': 'Serpent/ASSEMBLY_B/output_2020-05-13_22-47-03/ASSBLY_CASEB_mc_res.mat',
        },
        'ASSBLY_C': {
            'drag_res': 'Dragon/ASSBLY_C/output_2020-06-06_13-43-34/ASSBLY_CASEC.result',
            'drag_pat': r'>\|\+\+\+ Burnup=(?P<burnup>.*?)\s+Keff=(?P<keff>.*?)\s+(?=\|>\d+)',
            'drag_burn': 'Dragon/ASSBLY_C/output_2020-06-06_13-43-34/ASSBLY_CASEC_BURN2.txt',
            'serp_dep': 'Serpent/ASSEMBLY_C/output_2020-05-18_15-13-07/ASSBLY_CASEC_mc_dep.mat',
            'serp_res': 'Serpent/ASSEMBLY_C/output_2020-05-18_15-13-07/ASSBLY_CASEC_mc_res.mat',
        },
        'ASSBLY_D': {
            'drag_res': 'Dragon/ASSBLY_D/output_2020-06-06_13-41-48/ASSBLY_CASED.result',
            'drag_pat': r'>\|\+\+\+ Burnup=(?P<burnup>.*?)\s+Keff=(?P<keff>.*?)\s+(?=\|>\d+)',
            'drag_burn': 'Dragon/ASSBLY_D/output_2020-06-06_13-41-48/ASSBLY_CASED_BURN2.txt',
            'serp_dep': 'Serpent/ASSEMBLY_D/output_2020-05-21_10-05-13/ASSBLY_CASED_mc_dep.mat',
            'serp_res': 'Serpent/ASSEMBLY_D/output_2020-05-21_10-05-13/ASSBLY_CASED_mc_res.mat',
        },
    }

    for key in d.keys():
        print(key)
        if key == 'PIN_B':
            burnup_vs_keff = parse_burnup_vs_keff_drag_assbly(
                s=pathlib.Path(d[key]['drag_res']).read_text(),
                pattern=d[key]['drag_pat']
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
                # iso_numbers=[i for _, i in iso_names],
                mix_number=mix_numbers,
                # volume=[mix_vol_map[mix] for mix in mix_numbers],
                **densities,
            )
            df = pd.DataFrame(data)

            df.insert(2, 'mix_volume', df.apply(lambda row: mix_vol_map[row.mix_number], axis=1))
            iso_volumes = df.groupby('iso_name').apply(lambda x: x.mix_volume.sum())

            df.insert(3, 'iso_volume', [iso_volumes[name] for name in iso_names])
            df.insert(4, 'iso_vol_frac', df.apply(lambda row: row.mix_volume / row.iso_volume, axis=1))
            g = df.groupby('iso_name')
            tot_burn = g.apply(lambda x: total_burnup(x))
            df = df.append(tot_burn, ignore_index=True)
            # df.apply(lambda row: sum(total_burn(row)), axis=1)
            df = df.set_index('iso_name')
            print(df.iloc[:7, 0:7].to_string())
            # print(df.to_string())

            plot_data(df, burnup_vs_keff, serp_dep_data,
                      filename=f'{key}_density.png',
                      title=f"$Normalized \ Total \ Atomic \ density \ vs \ Burnup$\n {d[key]['serp_dep']}\n {d[key]['drag_burn']}\n")

            # with pd.ExcelWriter("burn.xlsx", engine='xlsxwriter') as writer:
            #     df.to_excel(writer, sheet_name='burn', startrow=1, startcol=1)
