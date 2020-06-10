import os
import pathlib
import re
from decimal import Decimal
from typing import Tuple, List

import matplotlib.pyplot as plt
import scipy.io

from analysex.file_map import file_map
from analysex.plot_assbly_keff import (
    parse_burnup_vs_keff_serp,
    parse_burnup_vs_keff_drag_assbly,
)


def parse_burnup_vs_kinf_drag(s: str, debug: bool = False) -> List[Tuple[float, float]]:
    """
    Parse ECHO dragon statement to extract values for BURNUP and K-INFINITY
    
    >>> s = '\\n>|BURNUP:   3.000000e+01   <-> K-INFINITY :   1.055019e+00                |>0173\\n'
    >>> parse_burnup_vs_kinf(s)
    [(Decimal('30.00000'), Decimal('1.055019'))]
    """

    end = '.*\n'
    line = [m.end() for m in re.finditer(end, s)]

    burn_vs_kinf = []  # save burnup vs kinf in list

    pattern = r'''>\|(BURNUP:(?P<burnup>.*?)<-> K-INFINITY :(?P<kinf>.*?))(?=\|>\d+)'''
    match = re.compile(pattern, re.MULTILINE | re.DOTALL)
    for m in re.finditer(match, s):
        lineno = next(i + 1 for i in range(len(line)) if line[i] > m.start(1))
        endno = lineno + len(m.group().splitlines()) - 1
        text = m.group()
        burnup = float(m.group("burnup").strip()) / 1000
        kinf = float(m.group("kinf").strip())
        print(
            f'start:{lineno: <6} end:{endno: <6} burnup: {float(burnup)} kinf: {float(kinf)} text: {text}'
        ) if debug else None
        burn_vs_kinf.append((burnup, kinf))

    return burn_vs_kinf


def plot_burnup_vs_keff(
        data: List[Tuple[float, float]],
        filename: str = 'keff_vs_burnup.png',
        title: str = '$k_{eff} \ vs \ Burnup$'
):
    x_val = [x[0] for x in data]
    y_val = [x[1] for x in data]

    fig = plt.figure()
    plt.grid()
    plt.plot(x_val, y_val)
    plt.plot(x_val, y_val, 'or')
    plt.suptitle(title, fontsize=12, y=1.02)
    plt.xlabel(r'$Burnup \ \frac{MWd}{kgU}$', fontsize=12)
    plt.ylabel(r'$Multiplication \ factor \ k_{eff}$', fontsize=12)
    plt.savefig(filename, dpi=300, bbox_inches="tight")
    plt.show()
    plt.close(fig)


def plot_serp_dragon_burnup_vs_keff(
        data_serp: List[Tuple[Decimal, Decimal]],
        data_drag: List[Tuple[Decimal, Decimal]],
        filename: str = 'keff_vs_burnup.png',
        title: str = '$k_{eff} \ vs \ Burnup$'
):
    xd = [x[0] for x in data_drag]
    yd = [x[1] for x in data_drag]

    xs = [x[0] for x in data_serp]
    ys = [x[1] for x in data_serp]

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


def plot_serp_dragon_burnup_vs_keff_relative_error(
        data_serp: List[Tuple[float, float]],
        data_drag: List[Tuple[float, float]],
        filename: str = 'keff_vs_burnup.png',
        title: str = '$k_{eff} \ vs \ Burnup$'
):
    pathlib.Path(filename).parent.mkdir(exist_ok=True, parents=True)

    xd = [x[0] for x in data_drag]
    yd = [x[1] for x in data_drag]

    xs = [x[0] for x in data_serp]
    ys = [x[1] for x in data_serp]

    assert xd == xs

    fig = plt.figure()

    ratio = 0.7
    ax = plt.gca()
    xleft, xright = ax.get_xlim()
    ybottom, ytop = ax.get_ylim()
    ax.set_aspect(abs((xright - xleft) / (ybottom - ytop)) * ratio)

    p1 = plt.subplot(2, 1, 1)
    p1.set_title(title, fontsize=12)

    plt.grid()
    plt.plot(xd, yd, '.r', label='Dragon 5')
    plt.plot(xs, ys, '+b', label='Serpent 2')

    plt.ylabel(r'$k_{eff}$', fontsize=12)
    plt.legend(loc="upper right")

    p2 = plt.subplot(2, 1, 2)
    plt.grid()

    rho_s = [(ys[i] - 1) * 10 ** 5 / ys[i] for i in range(len(ys))]
    rho_d = [(yd[i] - 1) * 10 ** 5 / yd[i] for i in range(len(yd))]

    diff = [rho_s[i] - rho_d[i] for i in range(len(ys))]

    plt.plot(xd, diff, '-', label=r'$\rho_{Serpent}-\rho_{Dragon}$')
    plt.xlabel(r'$Burnup \ \frac{MWd}{kgU}$', fontsize=12)
    plt.ylabel(r'$Discrepancy, \ pcm$', fontsize=10)

    plt.legend()  # plt.legend(loc=(1.04, 0), fontsize=12)
    plt.tight_layout()
    plt.savefig(filename, dpi=300, bbox_inches="tight")
    plt.show()
    plt.close(fig)


def sync_drag_serp_data(
        data_drag: List[Tuple[float, float]],
        data_serp: List[Tuple[float, float]]
) -> Tuple[List[Tuple[float, float]], List[Tuple[float, float]]]:
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

    return list(zip(xd, yd)), list(zip(xs, ys))


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).parent.parent)
    d = file_map

    for key in d.keys():
        print(f"plotting {d[key]['drag_res']}")

        serp_file_name = d[key]['serp_res']
        serp_res_data = scipy.io.loadmat(serp_file_name)
        burnup_vs_keff_serp = parse_burnup_vs_keff_serp(serp_res_data)

        drag_file_name = d[key]['drag_res']
        dragon_pin_a_str = pathlib.Path(drag_file_name).read_text()
        burnup_vs_keff_dragon = parse_burnup_vs_keff_drag_assbly(dragon_pin_a_str)
        burnup_vs_keff_dragon = [
            (step / 1000, burnup) for step, burnup in burnup_vs_keff_dragon]

        burnup_vs_keff_dragon, burnup_vs_keff_serp = sync_drag_serp_data(
            data_drag=burnup_vs_keff_dragon,
            data_serp=burnup_vs_keff_serp,
        )

        plot_serp_dragon_burnup_vs_keff_relative_error(
            data_serp=burnup_vs_keff_serp,
            data_drag=burnup_vs_keff_dragon,
            title=f'$k_{{eff}} \ vs \ Burnup$\n {serp_file_name}\n {drag_file_name}\n',
            filename=f'all_plots/keff_vs_burnup_comparison_{key}.png'
        )

        print('\u2713')
