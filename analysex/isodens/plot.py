import itertools
from collections.abc import Iterable
from typing import List

import matplotlib.pyplot as plt  # type: ignore
import pandas as pd  # type: ignore
from cycler import cycler  # type: ignore


def plot_serp(plt: plt, iso_list: List[str], dep_data: dict):
    marker = itertools.cycle(('|', '_', '+'))

    burnup = list(dep_data['BU'][0])
    for iso in iso_list:
        if '_total' in iso:
            iso = 'i' + iso.replace('_total', '')
            iso_dens = list(dep_data['TOT_ADENS'][int(dep_data[iso][0, 0]) - 1])
            iso_dens = [i / max(iso_dens) for i in iso_dens]  # normalise
            plt.plot(burnup, iso_dens, linestyle='-.', label=f'{iso[1:]} S2', linewidth=1)


def plot_data(
        df: pd.DataFrame,
        burnup_vs_keff: pd.DataFrame,
        serp_dep_data: dict,
        filename: str,
        title: str = '$Atomic \ density \ vs \ Burnup$') -> None:
    fig = plt.figure()

    line_cycler = itertools.cycle(
        cycler(linestyle=['--', ':', '-.', ':'])
    )
    xdata = (burnup_vs_keff['b_step'] / 1000)
    iso_list = [
        'U235_total',
        'U236_total',
        'Np237_total',
        'U238_total',
        'Pu239_total',
        'Pu240_total',
        'Pu241_total',
    ]
    for iso in iso_list:
        z = df.loc[iso]
        if isinstance(z['mix_number'], Iterable):
            for mix in z['mix_number']:
                y = z.loc[z['mix_number'] == mix].astype(float)
                ydata = y.loc[:, [k for k in y.keys() if 'burn' in k]]
                ydata = ydata / ydata.to_numpy().max()  # normalise
                ydata = ydata.transpose()
                plt.plot(xdata, ydata, **next(line_cycler),
                         label=f"{iso.replace('_total', '')} {mix} D5")
        else:
            ydata = z.loc[[k for k in z.keys() if 'burn' in k]].values
            ydata = ydata / ydata.max()
            plt.plot(xdata, ydata, **next(line_cycler),
                     label=f"{iso.replace('_total', '')} D5")

    plot_serp(plt, iso_list, serp_dep_data)

    ratio = 0.7
    ax = plt.gca()
    xleft, xright = ax.get_xlim()
    ybottom, ytop = ax.get_ylim()
    ax.set_aspect(abs((xright - xleft) / (ybottom - ytop)) * ratio)

    plt.grid()
    plt.legend(loc=(1.04, 0))
    plt.xlabel(r'$Burnup \ \frac{MWd}{kgU}$', fontsize=12)
    plt.ylabel(r'$Normalisation$', fontsize=12)
    plt.suptitle(title, fontsize=12, y=1.02)
    # plt.yscale('log')
    plt.savefig(filename, dpi=500, bbox_inches="tight")
    plt.show()
    plt.close(fig)
