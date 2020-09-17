"""
plot keff vs burnup for pin/assembly calculations performed with
Dragon5 and Serpent2
"""

import csv
import os
import pathlib
import re
from typing import Iterator, List, Tuple

import scipy.io
from scipy.signal import find_peaks

import matplotlib.pyplot as plt
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


def sync_drag_serp_data(
        data_drag: List[Tuple[float, float]],
        data_serp: List[Tuple[float, float]],
        debug: bool = False,
) -> Tuple[List[Tuple[float, float]], List[Tuple[float, float]]]:
    xd, yd = [list(t) for t in zip(*data_drag)]
    xs, ys = [list(t) for t in zip(*data_serp)]

    # remove any burnup point missing in xs or xd
    for item in list(set(xs) - set(xd)):
        index = xs.index(item)
        if debug:
            print(f'removing xs[{index}]={item}')
        xs.pop(index)
        ys.pop(index)
    for item in list(set(xd) - set(xs)):
        index = xd.index(item)
        if debug:
            print(f'removing xd[{index}]={item}')
        xd.pop(index)
        yd.pop(index)

    assert xd == xs

    return list(zip(xd, yd)), list(zip(xs, ys))


def parse_drag_burnup_vs_keff(
        s: str,
        debug: bool = False,
        pattern: str = r'>\|\+\+\+ Burnup=(?P<burnup>.*?)\s+Keff=(?P<keff>.*?)\s+(?=\|>\d+)'
) -> List[Tuple[float, float]]:
    """
    Parse ECHO dragon statement to extract values for BURNUP and K-INFINITY

    >>> s = '\\n>|+++ Burnup=  0.000000e+00  Keff=  1.084023e+00                          |>0144\\n'
    >>> parse_drag_burnup_vs_keff(s)
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


def parse_serp_burnup_vs_keff(data: dict) -> List[Tuple[float, float]]:
    burnup_vs_keff = [(data['BURNUP'][:, 0][i], data['ABS_KEFF'][:, 0][i])
                      for i in range(len(data['BURNUP']))]
    return burnup_vs_keff


def plot_drag_burnup_vs_keff(
        data: List[Tuple[float, float]],
        filename: str = 'keff_vs_burnup.png',
        title: str = '$k_{eff} \ vs \ Burnup$'
) -> None:
    pathlib.Path(filename).parent.mkdir(exist_ok=True, parents=True)

    x_val, y_val = zip(*data)

    fig = plt.figure()
    plt.grid()
    plt.plot(x_val, y_val)
    plt.plot(x_val, y_val, 'or')
    plt.suptitle(title, fontsize=12)
    plt.xlabel(r'$Burnup \ \frac{MWd}{tU}$', fontsize=12)
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


def create_drag_keff_plots(path: pathlib.Path) -> None:
    print(path, end=' ')
    text = path.read_text()

    regex = re.search('^Dragon/(ASSEMBLY.*?)/output_(.*?)/.*.result$', str(path))
    if regex:
        name = regex.group(1).lower() + '_' + regex.group(2).lower()
        burnup_vs_keff = parse_drag_burnup_vs_keff(text)
        save_as_csv(burnup_vs_keff, filename=f'assbly_plots/burnup_vs_keff_{name}.csv')
        plot_drag_burnup_vs_keff(
            data=burnup_vs_keff,
            filename=f'data/plots/burnup_vs_keff_{name}.png',
            title=f'$k_{{eff}} \ vs \ Burnup$\n {str(path)}')
        plot_drag_burnup_vs_keff(
            data=burnup_vs_keff[:10],
            filename=f'data/plots/burnup_vs_keff_cut_{name}.png',
            title=f'$k_{{eff}} \ vs \ Burnup$\n {str(path)} cut')
        print('\u2713')


def plot_serp_drag_burnup_vs_keff(
        data_serp: List[Tuple[float, float]],
        data_drag: List[Tuple[float, float]],
        filename: str = 'keff_vs_burnup_assbly.png',
        title: str = '$k_{eff} \ vs \ Burnup$'
) -> None:
    pathlib.Path(filename).parent.mkdir(exist_ok=True, parents=True)

    xd, yd = zip(*data_drag)
    xs, ys = zip(*data_serp)

    assert xd == xs

    fig = plt.figure()
    # plt.gca().set_title(title, fontsize=12)
    plt.grid()
    plt.plot(xd, yd, 'or', label='dragon')
    plt.plot(xs, ys, '+b', label='serpent')
    # plt.suptitle(title, fontsize=12, y=1.02)
    plt.xlabel(r'$Burnup \ MWd/t$', fontsize=12)
    plt.ylabel(r'$k_{eff}$', fontsize=12)
    plt.legend(loc="upper right")
    plt.tight_layout()
    plt.savefig(filename, dpi=300)
    plt.savefig(filename.replace('.png', '.eps'))
    plt.show()
    plt.close(fig)


def plot_serp_drag_1l_2l_burnup_vs_keff(
        data_serp: List[Tuple[float, float]],
        data_drag_1l: List[Tuple[float, float]],
        data_drag: List[Tuple[float, float]],
        filename: str = 'keff_vs_burnup_assbly.png',
        title: str = '$k_{eff} \ vs \ Burnup$'
) -> None:
    xd, yd = zip(*data_drag)
    xd1, yd1 = zip(*data_drag_1l)
    xs, ys = zip(*data_serp)

    assert xd == xd1 == xs

    fig = plt.figure()
    plt.gca().set_title(title, fontsize=12)
    plt.grid()
    plt.plot(xd, yd, 'or', label='dragon 2l')
    plt.plot(xd1, yd1, 'xg', label='dragon 1l')
    plt.plot(xs, ys, '+b', label='serpent')
    plt.xlabel(r'$Burnup \ \frac{MWd}{tU}$', fontsize=12)
    plt.ylabel(r'$Multiplication \ factor \ k_{eff}$', fontsize=12)
    plt.legend(loc="upper right")
    plt.tight_layout()
    plt.savefig(filename, dpi=300, bbox_inches="tight")
    plt.show()
    plt.close(fig)


def plot_serp_drag_burnup_vs_keff_error(
        data_serp: List[Tuple[float, float]],
        data_drag: List[Tuple[float, float]],
        filename: str = 'keff_vs_burnup.png',
        title: str = '$k_{eff} \ vs \ Burnup$'
):
    pathlib.Path(filename).parent.mkdir(exist_ok=True, parents=True)

    xd, yd = [list(t) for t in zip(*data_drag)]
    xs, ys = [list(t) for t in zip(*data_serp)]

    assert xd == xs

    fig = plt.figure()

    plt.subplot(2, 1, 1)
    # plt.gca().set_title(title, fontsize=12)
    plt.grid()
    plt.plot(xd, yd, '.r', label='DRAGON5')
    plt.plot(xs, ys, '+b', label='SERPENT2')

    plt.ylabel(r'$k_{eff}$', fontsize=12, labelpad=15)
    plt.legend(loc="upper right")

    plt.subplot(2, 1, 2)
    plt.grid()

    rho_s = [(ys[i] - 1) * 10 ** 5 / ys[i] for i in range(len(ys))]
    rho_d = [(yd[i] - 1) * 10 ** 5 / yd[i] for i in range(len(yd))]

    diff = [rho_s[i] - rho_d[i] for i in range(len(ys))]

    # print data for 0, max discrepancy and max burnup
    mi, mv = max(enumerate(diff), key=(lambda x: abs(x[1])))
    print(f"\n{'Burnup':>6s} {'keff S2':>10s} {'keff D5':>10s} {'Discr (pcm)':>11s}")
    print(f"{xd[0]:6} {ys[0]:10.5f} {yd[0]:10.5f} {diff[0]:11.0f}")
    print(f"{xd[mi]:6} {ys[mi]:10.5f} {yd[mi]:10.5f} {diff[mi]:11.0f}")
    print(f"{xd[-1]:6} {ys[-1]:10.5f} {yd[-1]:10.5f} {diff[-1]:11.0f}")

    plt.plot(xd, diff, '.')
    plt.xlabel(r'$Burnup \ MWd/t$', fontsize=12)
    plt.ylabel(r'$Discrepancy, \ pcm$', fontsize=10)

    # plt.legend()  # plt.legend(loc=(1.04, 0), fontsize=12)
    plt.tight_layout()
    plt.savefig(filename, dpi=300)
    plt.savefig(filename.replace('.png', '.eps'))
    plt.show()
    plt.close(fig)


def plot_serp_drag_1l_2l_burnup_vs_keff_error(
        data_serp: List[Tuple[float, float]],
        data_drag_1l: List[Tuple[float, float]],
        data_drag: List[Tuple[float, float]],
        filename: str = 'keff_vs_burnup.png',
        title: str = '$k_{eff} \ vs \ Burnup$'
):
    pathlib.Path(filename).parent.mkdir(exist_ok=True, parents=True)

    xd, yd = [list(t) for t in zip(*data_drag)] # data from 2 level scheme
    xd1, yd1 = [list(t) for t in zip(*data_drag_1l)] # data from 1 level scheme
    xs, ys = [list(t) for t in zip(*data_serp)]

    assert xd == xd1 == xs

    fig = plt.figure(figsize=(10,7))

    plt.subplot(2, 1, 1)
    plt.gca().set_title(title, fontsize=10)
    plt.grid()
    plt.plot(xd, yd, '.r', label='$D5 \ 2L$')
    plt.plot(xd1, yd1, 'xg', label='$D5 \ 1L$')
    plt.plot(xs, ys, '+b', label='$S2$')

    plt.ylabel(r'$k_{eff}$', fontsize=12)
    plt.legend(loc="upper right")

    plt.subplot(2, 1, 2)
    plt.grid()

    rho_s = [(ys[i] - 1) * 10 ** 5 / ys[i] for i in range(len(ys))]
    rho_d = [(yd[i] - 1) * 10 ** 5 / yd[i] for i in range(len(yd))]
    rho_d1 = [(yd1[i] - 1) * 10 ** 5 / yd1[i] for i in range(len(yd1))]

    diff = [rho_s[i] - rho_d[i] for i in range(len(ys))]
    diff1 = [rho_s[i] - rho_d1[i] for i in range(len(ys))]

    plt.plot(xd, diff, '-r', label=r'$\rho_{S2}-\rho_{D5 \ 2L}$')
    plt.plot(xd, diff1, '-g', label=r'$\rho_{S2}-\rho_{D5 \ 1L}$')
    plt.xlabel(r'$Burnup \ MWd/tU$', fontsize=12)
    plt.ylabel(r'$Discrepancy \ pcm$', fontsize=12)

    plt.legend()
    plt.tight_layout()
    plt.savefig(filename, dpi=300, bbox_inches="tight")
    plt.savefig(filename.replace('.png', '.pdf'), bbox_inches="tight")
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
        burnup_vs_keff_serp = parse_serp_burnup_vs_keff(serp_res_data)

        drag_file_name = d[key]['drag_res']
        dragon_result_str = pathlib.Path(drag_file_name).read_text()
        burnup_vs_keff_drag = parse_drag_burnup_vs_keff(dragon_result_str)
        keff_peaks(drag_file_name, burnup_vs_keff_drag)

        burnup_vs_keff_drag, burnup_vs_keff_serp = sync_drag_serp_data(
            data_drag=burnup_vs_keff_drag,
            data_serp=burnup_vs_keff_serp,
        )

        print(f'plotting {serp_file_name}', end=' ')
        plot_serp_drag_burnup_vs_keff(
            data_serp=burnup_vs_keff_serp,
            data_drag=burnup_vs_keff_drag,
            title=f'$k_{{eff}} \ vs \ Burnup$\n {serp_file_name}\n {drag_file_name}\n',
            filename=f'data/plots/keff_vs_burnup_{key}.png'
        )

        plot_serp_drag_burnup_vs_keff_error(
            data_serp=burnup_vs_keff_serp,
            data_drag=burnup_vs_keff_drag,
            title=f'$k_{{eff}} \ vs \ Burnup$\n {serp_file_name}\n {drag_file_name}\n',
            filename=f'data/plots/keff_vs_burnup_error_{key}.png'
        )

        if 'ASSBLY' in key:
            drag_file_name_1l = d[key]['drag_res_1level']
            dragon_result_str_1l = pathlib.Path(drag_file_name_1l).read_text()
            burnup_vs_keff_drag_1l = parse_drag_burnup_vs_keff(dragon_result_str_1l)

            burnup_vs_keff_drag_1l, burnup_vs_keff_serp = sync_drag_serp_data(
                data_drag=burnup_vs_keff_drag_1l,
                data_serp=burnup_vs_keff_serp,
            )

            plot_serp_drag_1l_2l_burnup_vs_keff(
                data_serp=burnup_vs_keff_serp,
                data_drag_1l=burnup_vs_keff_drag_1l,
                data_drag=burnup_vs_keff_drag,
                title=f'$k_{{eff}} \ vs \ Burnup$\n {serp_file_name}\n {drag_file_name}\n {drag_file_name_1l}\n',
                filename=f'data/plots/keff_vs_burnup_1l_2l_{key}.png'
            )

            plot_serp_drag_1l_2l_burnup_vs_keff_error(
                data_serp=burnup_vs_keff_serp,
                data_drag_1l=burnup_vs_keff_drag_1l,
                data_drag=burnup_vs_keff_drag,
                title=f"$k_{{eff}} \ vs \ Burnup \ ASSBLY \ {key.split('_')[-1]}$",
                filename=f'data/plots/keff_vs_burnup_1l_2l_error_{key}.png'
            )

        print('\u2713')
