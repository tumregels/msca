import csv
import os
import pathlib
import re
from typing import Tuple, List, Dict, Any

import matplotlib.pyplot as plt  # type: ignore
import scipy.io  # type: ignore
from matplotlib.ticker import ScalarFormatter  # type: ignore


def load_csv(filename: str) -> Dict[str, Dict[str, List[Tuple[float, float]]]]:
    data: Dict[str, Any] = dict()
    with open(filename) as f:
        reader = csv.reader(f)
        next(reader)
        for row in reader:
            iso = row[1]
            burnup = float(row[0])
            mixture = int(row[2])
            dens = float(row[3])
            if iso not in data:
                data[iso] = {}
            if mixture not in data[iso]:
                data[iso][mixture] = []

            data[iso][mixture].append((burnup, dens))
    return data


def plot_atomic_dens_vs_burnup_dragon(
        data: Dict[str, Any],
        title: str = 'Atomic density vs burnup',
        filename: str = 'atomic_dens_vs_burnup.png'
):
    pathlib.Path(filename).parent.mkdir(exist_ok=True, parents=True)

    burnup = [x[0] for x in data['U235'][3]]
    pu239 = [x[1] for x in data['Pu239'][3]]
    u235 = [x[1] for x in data['U235'][3]]
    pu241 = [x[1] for x in data['Pu241'][3]]

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


def plot_atomic_dens_vs_burnup_serp_dragon_relative(
        data_serp: dict,
        data_drag: Dict[str, Any],
        filename: str = 'atomic_dens_vs_burnup.png',
        title: str = '$Atomic \ density \ vs \ Burnup$'
):
    pathlib.Path(filename).parent.mkdir(exist_ok=True, parents=True)

    burnup_s = list(data_serp['BU'][0])
    pu239_s = list(data_serp['TOT_ADENS'][int(data_serp['iPu239'][0, 0]) - 1])  # in matlab indexes starts from 1
    u235_s = list(data_serp['TOT_ADENS'][int(data_serp['iU235'][0, 0]) - 1])
    pu241_s = list(data_serp['TOT_ADENS'][int(data_serp['iPu241'][0, 0]) - 1])

    burnup_d = [x[0] / 1000 for x in data_drag['U235'][3]]
    pu239_d = [x[1] for x in data_drag['Pu239'][3]]
    u235_d = [x[1] for x in data_drag['U235'][3]]
    pu241_d = [x[1] for x in data_drag['Pu241'][3]]

    if len(burnup_s) != len(burnup_d) and burnup_s[0] == 0:
        burnup_s.pop(0)
        pu239_s.pop(0)
        u235_s.pop(0)
        pu241_s.pop(0)
        assert burnup_s[0] == burnup_d[0]
        print(len(burnup_s), len(burnup_d))

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
    drag_output_files = [
        'Dragon/ASSEMBLY_A/output_2020-05-17_17-42-26/UOX_TBH_eighth_2level_g2s.result',
        'Dragon/ASSEMBLY_B/output_2020-05-17_23-29-31/GD_TBH_eighth_2level_g2s.result',
        'Dragon/ASSEMBLY_C/output_2020-05-17_23-27-23/GD_TBH_eighth_2level_g2s.result',
        'Dragon/ASSEMBLY_D/output_2020-05-17_20-49-07/GD_TBH_eighth_2level_g2s.result',
    ]

    serp_output_files = [
        'Serpent/ASSEMBLY_A/output_2020-05-13_12-24-33/ASSBLY_CASEA_mc_dep.mat',
        'Serpent/ASSEMBLY_B/output_2020-05-13_22-47-03/ASSBLY_CASEB_mc_dep.mat',
        'Serpent/ASSEMBLY_C/output_2020-05-18_15-13-07/ASSBLY_CASEC_mc_dep.mat',
        'Serpent/ASSEMBLY_D/output_2020-05-21_10-05-13/ASSBLY_CASED_mc_dep.mat',
    ]

    for i, drag_file_name in enumerate(drag_output_files):
        name = re.search("/(ASSEMBLY_.*?)/", drag_file_name).group(1)  # type: ignore
        csvfilename = 'assbly_plots/adens_vs_burnup_data_{}.csv'.format(name)
        data = load_csv(filename=csvfilename)

        serp_file_name = serp_output_files[i]
        serp_dep_data = scipy.io.loadmat(serp_file_name)

        plot_atomic_dens_vs_burnup_dragon(
            data=data,
            title=f'$Atomic density \ vs \ Burnup$\n {drag_file_name}\n',
            filename='assbly_plots/adens_vs_burnup_{}'.format(
                re.search("/(ASSEMBLY_.*?)/", str(drag_file_name)).group(1))  # type: ignore
        )

        plot_atomic_dens_vs_burnup_serp_dragon_relative(
            data_serp=serp_dep_data,
            data_drag=data,
            title=f'$Atomic \ density \ vs \ Burnup$\n {serp_file_name}\n {drag_file_name}\n',
            filename='assbly_plots/adens_vs_burnup_comparison_relative_{}.png'.format(
                re.search("/(ASSEMBLY_.*?)/", serp_file_name).group(1)  # type: ignore
            )
        )
