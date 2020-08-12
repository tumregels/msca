"""
plot keff vs burnup for assembly calculations performed with
dragon and serpent
"""

import csv
import os
import pathlib
import re
from typing import Iterator, List, Tuple

import matplotlib.pyplot as plt
import scipy.io
from scipy.signal import find_peaks

from analysex.file_map import file_map


def parse_echo(s: str) -> Iterator[str]:
    """
    Parse ECHO statements from dragon 5 output

    >>> next(parse_echo('\\n>|BURNUP step 1 between  0.000000e+00 and  7.692308e-01 day:              |>0131\\n'))
    'start:2      end:2      text: >|BURNUP step 1 between  0.000000e+00 and  7.692308e-01 day:              '
    """

    end = '.*\n'
    line = [m.end() for m in re.finditer(end, s)]

    pattern = '>\|(.*?)(?=\|>\d+)'
    match = re.compile(pattern, re.MULTILINE | re.DOTALL)
    for m in re.finditer(match, s):
        lineno = next(i + 1 for i in range(len(line)) if line[i] > m.start(1))
        endno = lineno + len(m.group().splitlines()) - 1
        text = m.group()
        yield f'start:{lineno: <6} end:{endno: <6} text: {text}'
    else:
        yield ''


def parse_burnup_vs_keff_drag_assbly(
        s: str,
        debug: bool = False,
        pattern: str = r'>\|\+\+\+ Burnup=(?P<burnup>.*?)\s+Keff=(?P<keff>.*?)\s+(?=\|>\d+)'
) -> List[Tuple[float, float]]:
    """
    Parse ECHO dragon statement to extract values for BURNUP and K-INFINITY

    >>> s = '\\n>|+++ Burnup=  0.000000e+00  Keff=  1.084023e+00                          |>0144\\n'
    >>> parse_burnup_vs_keff_drag_assbly(s)
    [(0.0, 1.084023)]
    """

    end = '.*\n'
    line = [m.end() for m in re.finditer(end, s)]

    burn_vs_keff = []  # save burnup vs kinf in list

    match = re.compile(pattern, re.MULTILINE | re.DOTALL)
    for m in re.finditer(match, s):
        lineno = next(i + 1 for i in range(len(line)) if line[i] > m.start(1))
        endno = lineno + len(m.group().splitlines()) - 1
        text = m.group()
        burnup = float(m.group("burnup").strip())
        keff = float(m.group("keff").strip())
        print(
            f'start:{lineno: <6} end:{endno: <6} burnup: {burnup} keff: {keff} text: {text}'
        ) if debug else None
        burn_vs_keff.append((burnup, keff))

    burn_vs_keff = [(step / 1000, burnup) for step, burnup in burn_vs_keff]
    return burn_vs_keff


def parse_burnup_vs_keff_serp(data: dict) -> List[Tuple[float, float]]:
    burnup_vs_keff = [(data['BURNUP'][:, 0][i], data['ABS_KEFF'][:, 0][i])
                      for i in range(len(data['BURNUP']))]
    return burnup_vs_keff


def plot_burnup_vs_keff(
        data: List[Tuple[float, float]],
        filename: str = 'keff_vs_burnup.png',
        title: str = '$k_{eff} \ vs \ Burnup$'
) -> None:
    x_val = [x[0] for x in data]
    y_val = [x[1] for x in data]

    fig = plt.figure()
    plt.grid()
    plt.plot(x_val, y_val)
    plt.plot(x_val, y_val, 'or')
    plt.suptitle(title, fontsize=12)
    plt.xlabel(r'$Burnup \ \frac{MWd}{kgU}$', fontsize=12)
    plt.ylabel(r'$Multiplication \ factor \ k_{eff}$', fontsize=12)
    plt.savefig(filename, dpi=300, bbox_inches="tight")
    # plt.show()
    plt.close(fig)


def save_as_csv(data: List[Tuple[float, float]], filename: str = 'burnup_vs_keff_drag.csv') -> None:
    with open(filename, 'w') as out:
        csv_out = csv.writer(out)
        csv_out.writerow(['burnup', 'keff'])
        for row in data:
            csv_out.writerow(row)


def create_dragon_keff_plots(path: pathlib.Path) -> None:
    print(path, end=' ')
    text = path.read_text()

    regex = re.search('^Dragon/(ASSEMBLY.*?)/output_(.*?)/.*.result$', str(path))
    if regex:
        name = regex.group(1).lower() + '_' + regex.group(2).lower()
        burnup_vs_keff = parse_burnup_vs_keff_drag_assbly(text)
        save_as_csv(burnup_vs_keff, filename=f'assbly_plots/burnup_vs_keff_{name}.csv')
        plot_burnup_vs_keff(
            data=burnup_vs_keff,
            filename=f'assbly_plots/burnup_vs_keff_{name}.png',
            title=f'$k_{{eff}} \ vs \ Burnup$\n {str(path)}')
        plot_burnup_vs_keff(
            data=burnup_vs_keff[:10],
            filename=f'assbly_plots/burnup_vs_keff_cut_{name}.png',
            title=f'$k_{{eff}} \ vs \ Burnup$\n {str(path)} cut')
        print('\u2713')


def plot_serp_dragon_burnup_vs_keff_assbly(
        data_serp: List[Tuple[float, float]],
        data_drag: List[Tuple[float, float]],
        filename: str = 'keff_vs_burnup_assbly.png',
        title: str = '$k_{eff} \ vs \ Burnup$'
) -> None:
    xd = [x[0] for x in data_drag]
    yd = [x[1] for x in data_drag]

    xs = [x[0] for x in data_serp]
    ys = [x[1] for x in data_serp]

    # remove any burnup point missing in xs or xd
    for item in list(set(xs) - set(xd)):
        index = xs.index(item)
        print(f'removing xs[{index}]={item}')
        xs.pop(index)
        ys.pop(index)
    for item in list(set(xd) - set(xs)):
        index = xd.index(item)
        print(f'removing xd[{index}]={item}')
        xd.pop(index)
        yd.pop(index)

    assert xd == xs

    fig = plt.figure()
    plt.grid()
    # plt.plot(xd,yd)
    plt.plot(xd, yd, 'or', label='dragon')
    plt.plot(xs, ys, '+b', label='serpent')
    plt.suptitle(title, fontsize=12, y=1.02)
    plt.xlabel(r'$Burnup \ \frac{MWd}{kgU}$', fontsize=12)
    plt.ylabel(r'$Multiplication \ factor \ k_{eff}$', fontsize=12)
    plt.legend(loc="upper right")
    plt.savefig(filename, dpi=300, bbox_inches="tight")
    plt.show()
    plt.close(fig)


def plot_serp_dragon_1l_2l_burnup_vs_keff_assbly(
        data_serp: List[Tuple[float, float]],
        data_drag_1l: List[Tuple[float, float]],
        data_drag: List[Tuple[float, float]],
        filename: str = 'keff_vs_burnup_assbly.png',
        title: str = '$k_{eff} \ vs \ Burnup$'
) -> None:
    xd = [x[0] for x in data_drag]
    yd = [x[1] for x in data_drag]

    xd1 = [x[0] for x in data_drag_1l]
    yd1 = [x[1] for x in data_drag_1l]

    xs = [x[0] for x in data_serp]
    ys = [x[1] for x in data_serp]

    # remove any burnup point missing in xs or xd
    for item in list(set(xs) - set(xd)):
        index = xs.index(item)
        print(f'removing xs[{index}]={item}')
        xs.pop(index)
        ys.pop(index)
    for item in list(set(xd) - set(xs)):
        index = xd.index(item)
        print(f'removing xd[{index}]={item}')
        xd.pop(index)
        xd1.pop(index)
        yd.pop(index)
        yd1.pop(index)

    assert xd == xd1 == xs

    fig = plt.figure()
    plt.grid()
    plt.plot(xd, yd, 'or', label='dragon 2l')
    plt.plot(xd1, yd1, 'xg', label='dragon 1l')
    plt.plot(xs, ys, '+b', label='serpent')
    plt.suptitle(title, fontsize=12, y=1.02)
    plt.xlabel(r'$Burnup \ \frac{MWd}{kgU}$', fontsize=12)
    plt.ylabel(r'$Multiplication \ factor \ k_{eff}$', fontsize=12)
    plt.legend(loc="upper right")
    plt.savefig(filename, dpi=300, bbox_inches="tight")
    plt.show()
    plt.close(fig)


def keff_peaks(filename: str, data: List[Tuple[float, float]]) -> None:
    peaks = find_peaks([i[1] for i in data])[0]

    for peak in peaks:
        print(f'{peak + 1:3d}  {data[peak][0]:7.1f}  {data[peak][1]:9.7f} < {filename}')


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).resolve().parent.parent)
    d = file_map

    for key in d.keys():
        serp_file_name = d[key]['serp_res']
        serp_res_data = scipy.io.loadmat(serp_file_name)
        burnup_vs_keff_serp = parse_burnup_vs_keff_serp(serp_res_data)

        drag_file_name = d[key]['drag_res']
        dragon_result_str = pathlib.Path(drag_file_name).read_text()
        burnup_vs_keff_drag = parse_burnup_vs_keff_drag_assbly(dragon_result_str)
        keff_peaks(drag_file_name, burnup_vs_keff_drag)

        print(f'plotting {serp_file_name}', end=' ')
        plot_serp_dragon_burnup_vs_keff_assbly(
            data_serp=burnup_vs_keff_serp,
            data_drag=burnup_vs_keff_drag,
            title=f'$k_{{eff}} \ vs \ Burnup$\n {serp_file_name}\n {drag_file_name}\n',
            filename=f'all_plots/keff_vs_burnup_{key}.png'
        )

        if 'ASSBLY' in key:
            drag_file_name_1l = d[key]['drag_res_1level']
            dragon_result_str_1l = pathlib.Path(drag_file_name_1l).read_text()
            burnup_vs_keff_drag_1l = parse_burnup_vs_keff_drag_assbly(dragon_result_str_1l)

            plot_serp_dragon_1l_2l_burnup_vs_keff_assbly(
                data_serp=burnup_vs_keff_serp,
                data_drag_1l=burnup_vs_keff_drag_1l,
                data_drag=burnup_vs_keff_drag,
                title=f'$k_{{eff}} \ vs \ Burnup$\n {serp_file_name}\n {drag_file_name}\n {drag_file_name_1l}\n',
                filename=f'all_plots/keff_vs_burnup_1l_2l_{key}.png'
            )

        print('\u2713')
