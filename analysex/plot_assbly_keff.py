"""
plot keff vs burnup for assembly calculations performed with
dragon and serpent
"""

import csv
import os
import pathlib
import re
from typing import Iterator, Tuple, List

import matplotlib.pyplot as plt
import scipy.io


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
    x_val = [x[0] / 1000 for x in data]
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
    xd = [x[0] / 1000 for x in data_drag]
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


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).parent.parent)
    drag_output_files = [
        'Dragon/ASSEMBLY_A/output_2020-05-17_17-42-26/UOX_TBH_eighth_2level_g2s.result',
        'Dragon/ASSEMBLY_B/output_2020-05-17_23-29-31/GD_TBH_eighth_2level_g2s.result',
        'Dragon/ASSEMBLY_C/output_2020-05-17_23-27-23/GD_TBH_eighth_2level_g2s.result',
        'Dragon/ASSEMBLY_D/output_2020-05-17_20-49-07/GD_TBH_eighth_2level_g2s.result',
    ]

    serp_output_files = [
        'Serpent/ASSEMBLY_A/output_2020-05-13_12-24-33/ASSBLY_CASEA_mc_res.mat',
        'Serpent/ASSEMBLY_B/output_2020-05-13_22-47-03/ASSBLY_CASEB_mc_res.mat',
        'Serpent/ASSEMBLY_C/output_2020-05-18_15-13-07/ASSBLY_CASEC_mc_res.mat',
        'Serpent/ASSEMBLY_D/output_2020-05-21_10-05-13/ASSBLY_CASED_mc_res.mat',
    ]

    for i in range(len(drag_output_files)):
        serp_file_name = serp_output_files[i]
        serp_res_data = scipy.io.loadmat(serp_file_name)
        burnup_vs_keff_serp = parse_burnup_vs_keff_serp(serp_res_data)

        drag_file_name = drag_output_files[i]
        dragon_pin_a_str = pathlib.Path(drag_file_name).read_text()
        burnup_vs_keff_drag = parse_burnup_vs_keff_drag_assbly(dragon_pin_a_str)

        print(f'plotting {serp_file_name}', end=' ')
        plot_serp_dragon_burnup_vs_keff_assbly(
            data_serp=burnup_vs_keff_serp,
            data_drag=burnup_vs_keff_drag,
            title=f'$k_{{eff}} \ vs \ Burnup$\n {serp_file_name}\n {drag_file_name}\n',
            filename=f'assbly_plots/keff_vs_burnup_{re.search("/(ASSEMBLY_.*?)/", serp_file_name).group(1)}.png'
        )
        print('\u2713')
