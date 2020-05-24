import os
import pathlib

import os
import pathlib
import re
from decimal import Decimal
from typing import Tuple, List, Dict

import matplotlib.pyplot as plt
import scipy.io
from matplotlib.ticker import ScalarFormatter

from analysex.parse_pin import get_iso_dens_vs_burnup
from analysex.plot_assbly_densities import load_csv


def plot_atomic_dens_vs_burnup_dragon(
        data: Dict[Decimal, List[Tuple[str, str, Decimal]]],
        title: str = 'Atomic density vs burnup',
        filename: str = 'atomic_dens_vs_burnup.png'
):
    pathlib.Path(filename).parent.mkdir(exist_ok=True, parents=True)

    burnup = [k / 1000 for k in data.keys()]
    pu239 = [v[0][2] for _, v in data.items() if v[0][0] == 'Pu239']
    u235 = [v[4][2] for _, v in data.items() if v[4][0] == 'U235']
    pu241 = [v[8][2] for _, v in data.items() if v[8][0] == 'Pu241']

    fig = plt.figure()
    plt.plot(burnup, u235, label='U235', linestyle=':', color='r', linewidth=3)  # dotted
    plt.plot(burnup, pu239, label='Pu239', linestyle='--', color='b', linewidth=3)  # dashed
    plt.plot(burnup, pu241, label='Pu241', linestyle='-.', color='y', linewidth=3)  # dashdot
    plt.legend(loc='upper right')
    plt.grid()
    plt.gca().yaxis.set_major_formatter(ScalarFormatter(useOffset=True))
    plt.ticklabel_format(axis='y', style='sci', scilimits=(-2, 2))
    plt.suptitle(title, fontsize=12, y=1.02)
    plt.xlabel(r'$Burnup \ \frac{MWd}{kgU}$', fontsize=12)
    plt.ylabel(r'$Atomic \ density \ 10^{24}/cc$', fontsize=12)
    plt.savefig(filename, dpi=300, bbox_inches="tight")
    plt.close(fig)


def plot_atomic_dens_vs_burnup_serpent(
        data: dict,
        title: str = 'Atomic density vs burnup',
        filename: str = 'atomic_dens_vs_burnup_serpent.png'
):
    pathlib.Path(filename).parent.mkdir(exist_ok=True, parents=True)

    burnup = data['BU'][0]
    pu239 = data['TOT_ADENS'][int(data['iPu239'][0, 0]) - 1]  # in matlab indexes starts from 1
    u235 = data['TOT_ADENS'][int(data['iU235'][0, 0]) - 1]
    pu241 = data['TOT_ADENS'][int(data['iPu241'][0, 0]) - 1]

    fig = plt.figure()
    plt.plot(burnup, u235, label='U235', linestyle=':', color='r', linewidth=3)  # dotted
    plt.plot(burnup, pu239, label='Pu239', linestyle='--', color='b', linewidth=3)  # dashed
    plt.plot(burnup, pu241, label='Pu241', linestyle='-.', color='y', linewidth=3)  # dashdot
    plt.legend(loc='upper right')
    plt.grid()
    plt.gca().yaxis.set_major_formatter(ScalarFormatter(useOffset=True))
    plt.ticklabel_format(axis='y', style='sci', scilimits=(-2, 2))
    plt.suptitle(title, fontsize=12, y=1.02)
    plt.xlabel(r'$Burnup \ \frac{MWd}{kgU}$', fontsize=12)
    plt.ylabel(r'$Atomic \ density \ 10^{24}/cc$', fontsize=12)
    plt.savefig(filename, dpi=300, bbox_inches="tight")
    plt.show()
    plt.close(fig)


def plot_atomic_dens_vs_burnup_serp_dragon(
        data_serp: dict,
        data_drag: Dict[Decimal, List[Tuple[str, str, Decimal]]],
        filename: str = 'atomic_dens_vs_burnup.png',
        title: str = '$Atomic \ density \ vs \ Burnup$'
):
    pathlib.Path(filename).parent.mkdir(exist_ok=True, parents=True)

    burnup_s = data_serp['BU'][0]
    pu239_s = data_serp['TOT_ADENS'][int(data_serp['iPu239'][0, 0]) - 1]  # in matlab indexes starts from 1
    u235_s = data_serp['TOT_ADENS'][int(data_serp['iU235'][0, 0]) - 1]
    pu241_s = data_serp['TOT_ADENS'][int(data_serp['iPu241'][0, 0]) - 1]

    burnup_d = [k / 1000 for k in data_drag.keys()]
    pu239_d = [v[0][2] for _, v in data_drag.items() if v[0][0] == 'Pu239']
    u235_d = [v[4][2] for _, v in data_drag.items() if v[4][0] == 'U235']
    pu241_d = [v[8][2] for _, v in data_drag.items() if v[8][0] == 'Pu241']

    fig = plt.figure()
    plt.suptitle(title, fontsize=12, y=1.02)
    plt.grid()
    plt.plot(burnup_s, u235_s, 'xk', label='$U235_{Serpent \ 2}$', linewidth=2)  # dotted
    plt.plot(burnup_s, pu239_s, '4b', label='$Pu239_{Serpent \ 2}$', linewidth=2)  # dashed
    plt.plot(burnup_s, pu241_s, '3c', label='$Pu241_{Serpent \ 2}$', linewidth=2)  # dashdot

    plt.plot(burnup_d, u235_d, '1r', label='$U235_{Dragon \ 5}$', linewidth=2)  # dotted
    plt.plot(burnup_d, pu239_d, '+g', label='$Pu239_{Dragon \ 5}$', linewidth=2)  # dashed
    plt.plot(burnup_d, pu241_d, '2m', label='$Pu241_{Dragon \ 5}$', linewidth=2)  # dashdot

    plt.xlabel(r'$Burnup \ \frac{MWd}{kgU}$', fontsize=12)
    plt.ylabel(r'$Atomic \ density \ 10^{24}/cc$', fontsize=12)
    plt.legend(loc="upper right")

    plt.savefig(filename, dpi=300, bbox_inches="tight")
    plt.show()
    plt.close(fig)


def plot_atomic_dens_vs_burnup_serp_dragon_relative(
        data_serp: dict,
        data_drag: Dict[Decimal, List[Tuple[str, str, Decimal]]],
        filename: str = 'atomic_dens_vs_burnup.png',
        title: str = '$Atomic \ density \ vs \ Burnup$'
):
    pathlib.Path(filename).parent.mkdir(exist_ok=True, parents=True)

    burnup_s = data_serp['BU'][0]
    pu239_s = data_serp['TOT_ADENS'][int(data_serp['iPu239'][0, 0]) - 1]  # in matlab indexes starts from 1
    u235_s = data_serp['TOT_ADENS'][int(data_serp['iU235'][0, 0]) - 1]
    pu241_s = data_serp['TOT_ADENS'][int(data_serp['iPu241'][0, 0]) - 1]

    burnup_d = [k / 1000 for k in data_drag.keys()]
    pu239_d = [v[0][2] for _, v in data_drag.items() if v[0][0] == 'Pu239']
    u235_d = [v[4][2] for _, v in data_drag.items() if v[4][0] == 'U235']
    pu241_d = [v[8][2] for _, v in data_drag.items() if v[8][0] == 'Pu241']

    fig = plt.figure()

    p1 = plt.subplot(2, 1, 1)
    p1.set_title(title, fontsize=12)

    plt.grid()
    plt.plot(burnup_s, u235_s, 'xk', label='$U235_{Serpent \ 2}$', linewidth=2)  # dotted
    plt.plot(burnup_s, pu239_s, '4b', label='$Pu239_{Serpent \ 2}$', linewidth=2)  # dashed
    plt.plot(burnup_s, pu241_s, '3c', label='$Pu241_{Serpent \ 2}$', linewidth=2)  # dashdot

    plt.plot(burnup_d, u235_d, '1r', label='$U235_{Dragon \ 5}$', linewidth=2)  # dotted
    plt.plot(burnup_d, pu239_d, '+g', label='$Pu239_{Dragon \ 5}$', linewidth=2)  # dashed
    plt.plot(burnup_d, pu241_d, '2m', label='$Pu241_{Dragon \ 5}$', linewidth=2)  # dashdot

    plt.ylabel(r'$Atomic \ density \ 10^{24}/cc$', fontsize=12)
    plt.legend(loc="upper right", fontsize=5)

    p2 = plt.subplot(2, 1, 2)
    plt.grid()
    relative_error_u235 = []
    relative_error_pu239 = []
    relative_error_pu241 = []
    for i in range(len(burnup_s)):
        relative_error_u235.append(abs(100 * (u235_s[i] - float(u235_d[i])) / u235_s[i])) \
            if u235_s[i] != 0 else relative_error_u235.append(0)
        relative_error_pu239.append(abs(100 * (pu239_s[i] - float(pu239_d[i])) / pu239_s[i])) \
            if pu239_s[i] != 0 else relative_error_pu239.append(0)
        relative_error_pu241.append(abs(100 * (pu241_s[i] - float(pu241_d[i])) / pu241_s[i])) \
            if pu241_s[i] != 0 else relative_error_pu241.append(0)

    plt.semilogy(burnup_s, relative_error_u235, linestyle=':', color='r', label=r'$U235$')
    plt.semilogy(burnup_s, relative_error_pu239, linestyle='-.', color='c', label=r'$Pu239$')
    plt.semilogy(burnup_s, relative_error_pu241, linestyle='--', color='b', label=r'$Pu241$')
    plt.xlabel(r'$Burnup \ \frac{MWd}{kgU}$', fontsize=12)
    plt.ylabel(r'$Relative \ error, \%$', fontsize=12)
    plt.legend(loc="upper right", fontsize=5)
    p2.yaxis.set_label_coords(-0.13, 0.42)

    plt.savefig(filename, dpi=300, bbox_inches="tight")
    plt.show()
    plt.close(fig)

if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).parent.parent)
    # plt.rcParams['figure.figsize'] = [15, 7.5]

    drag_output_files = [
        'Dragon/PIN_A/output_2020-05-01_23-02-16/CGN_PIN_A.result',
        'Dragon/PIN_B/output_2020-05-02_00-15-18/CGN_PIN_B.result',
        'Dragon/PIN_C/output_2020-05-02_00-16-03/CGN_PIN_C.result'
    ]

    serp_output_files = [
        'Serpent/PIN_A/output_2020-05-11_22-39-35/PIN_CASEA_mc_dep.mat',
        'Serpent/PIN_B/output_2020-05-11_22-39-42/PIN_CASEB_mc_dep.mat',
        'Serpent/PIN_C/output_2020-05-11_22-39-48/PIN_CASEC_mc_dep.mat',
    ]

    # for p in drag_output_files:
    #     file = pathlib.Path(p)
    #     long_str = file.read_text()
    #
    #     iso_dens_vs_burnup = get_iso_dens_vs_burnup(long_str, debug=False)
    #     plot_atomic_dens_vs_burnup_dragon(
    #         data=iso_dens_vs_burnup,
    #         title=f'$Atomic density \ vs \ Burnup$\n {file}\n',
    #         filename=f'pin_plots/adens_vs_burnup_{re.search("/(PIN_.*?)/", str(file)).group(1)}'
    #     )
    #
    # for p in serp_output_files:
    #     data = scipy.io.loadmat(p)
    #     plot_atomic_dens_vs_burnup_serpent(
    #         data=data,
    #         title=f'$Atomic density \ vs \ Burnup$\n {p}\n',
    #         filename=f'pin_plots/adens_vs_burnup_serpent_{re.search("/(PIN_.*?)/", p).group(1)}'
    #     )

    for i in range(len(drag_output_files)):
        serp_file_name = serp_output_files[i]
        serp_dep_data = scipy.io.loadmat(serp_file_name)

        drag_file_name = drag_output_files[i]
        dragon_pin_a_str = pathlib.Path(drag_file_name).read_text()
        iso_dens_vs_burnup_dragon = get_iso_dens_vs_burnup(dragon_pin_a_str)

        plot_atomic_dens_vs_burnup_serp_dragon(
            data_serp=serp_dep_data,
            data_drag=iso_dens_vs_burnup_dragon,
            title=f'$Atomic \ density \ vs \ Burnup$\n {serp_file_name}\n {drag_file_name}\n',
            filename=f'pin_plots/adens_vs_burnup_comparison_{re.search("/(PIN_.*?)/", serp_file_name).group(1)}.png'
        )

        plot_atomic_dens_vs_burnup_serp_dragon_relative(
            data_serp=serp_dep_data,
            data_drag=iso_dens_vs_burnup_dragon,
            title=f'$Atomic \ density \ vs \ Burnup$\n {serp_file_name}\n {drag_file_name}\n',
            filename=f'pin_plots/adens_vs_burnup_comparison_relative_{re.search("/(PIN_.*?)/", serp_file_name).group(1)}.png'
        )
