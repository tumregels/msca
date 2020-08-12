import itertools
import pathlib
from collections.abc import Iterable

import matplotlib.pyplot as plt  # type: ignore
import pandas as pd  # type: ignore
import scipy.io
from cycler import cycler  # type: ignore


def plot_data_norm(
        df: pd.DataFrame,
        burnup_vs_keff: pd.DataFrame,
        serp_dep_data: dict,
        filename: str,
        iso_list: tuple = (
                'U235_total',
                'U236_total',
                'Np237_total',
                'U238_total',
                'Pu239_total',
                'Pu240_total',
                'Pu241_total',
        ),
        title: str = '$Atomic \ density \ vs \ Burnup$',
) -> None:
    line_cycler = itertools.cycle(cycler(linestyle=['--', ':', '-.', ':']))

    xdata = burnup_vs_keff['b_step']

    fig = plt.figure()
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

        burnup = list(serp_dep_data['BU'][0])
        if '_total' in iso:
            iso = 'i' + iso.replace('_total', '')
            iso_dens = list(serp_dep_data['TOT_ADENS'][int(serp_dep_data[iso][0, 0]) - 1])
            iso_dens = [i / max(iso_dens) for i in iso_dens]  # normalise
            plt.plot(burnup, iso_dens, linestyle='--', label=f'{iso[1:]} S2', linewidth=1)

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


def plot_data_total(
        df: pd.DataFrame,
        burnup_vs_keff: pd.DataFrame,
        serp_dep_data: dict,
        filename: str,
        iso_list: tuple = (
                'U235_total',
                'U236_total',
                'Np237_total',
                'U238_total',
                'Pu239_total',
                'Pu240_total',
                'Pu241_total',
        ),
        title: str = '$Atomic \ density \ vs \ Burnup$',
        save_data: bool = False,
) -> None:
    if save_data:
        fpath = pathlib.Path(__file__).parent.resolve()
        df.to_pickle(fpath / 'df.pickle')
        burnup_vs_keff.to_pickle(fpath / 'burnup_vs_keff.pickle')
        scipy.io.savemat(fpath / 'serp_dep_data.mat', serp_dep_data)

    line_cycler = itertools.cycle(cycler(linestyle=['--', ':', '-.', ':']))

    xdata = burnup_vs_keff['b_step']

    fig, axs = plt.subplots(
        nrows=len(iso_list),
        ncols=1,
        figsize=(10, 10),
        sharex=True,
    )

    for i, iso in enumerate(iso_list):
        z = df.loc[iso]
        if isinstance(z['mix_number'], Iterable):
            for mix in z['mix_number']:
                y = z.loc[z['mix_number'] == mix].astype(float)
                ydata = y.loc[:, [k for k in y.keys() if 'burn' in k]]
                ydata = ydata / ydata.to_numpy().max()  # normalise
                ydata = ydata.transpose()
                axs[i].plot(xdata, ydata, **next(line_cycler),
                            label=f"{iso.replace('_total', '')} {mix} D5")
        else:
            ydata = z.loc[[k for k in z.keys() if 'burn' in k]].values
            # ydata = ydata / ydata.max()
            axs[i].plot(xdata, ydata, '-b',
                        label=f"{iso.replace('_total', '')} D5")

        burnup = list(serp_dep_data['BU'][0])
        if '_total' in iso:
            iso = 'i' + iso.replace('_total', '')
            iso_dens = list(serp_dep_data['TOT_ADENS'][int(serp_dep_data[iso][0, 0]) - 1])
            # iso_dens = [i / max(iso_dens) for i in iso_dens]  # normalise
            axs[i].plot(burnup, iso_dens, '-r', label=f'{iso[1:]} S2', linewidth=1)

        axs[i].legend()
        axs[i].ticklabel_format(axis="y", style="sci", scilimits=(0, 0))
        axs[i].grid()

    plt.tight_layout()
    plt.xlabel(r'$Burnup \ \frac{MWd}{kgU}$', fontsize=12)
    # to add total ylabel
    # add a big axis, hide frame, hide tick and tick label of the big axis
    fig.add_subplot(111, frameon=False)
    plt.tick_params(labelcolor='none', top=False, bottom=False, left=False, right=False)
    plt.ylabel(r'$Atomic \ density \ 10^{24}/cc$', fontsize=12, labelpad=12)

    plt.suptitle(title, fontsize=12, y=1.04)

    plt.savefig(filename, dpi=500, bbox_inches="tight")
    plt.show()
    plt.close(fig)


if __name__ == '__main__':
    fpath = pathlib.Path(__file__).parent.resolve()
    df = pd.read_pickle(fpath / 'df.pickle')
    burnup_vs_keff = pd.read_pickle(fpath / 'burnup_vs_keff.pickle')
    serp_dep_data = {}
    scipy.io.loadmat(fpath / 'serp_dep_data.mat', serp_dep_data)
    key = 'PIN_B'
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
            filename=fpath / f'{key}_{i}_norm_density.png',
            iso_list=tpl,
            title=f"$Normalized \ total \ atomic \ density \ vs \ burnup$\n {fpath}\n {fpath}\n",
        )

        plot_data_total(
            df, burnup_vs_keff, serp_dep_data,
            filename=fpath / f'{key}_{i}_total_density.png',
            iso_list=tpl,
            save_data=True,
            title=f"$Total \ atomic \ density \ vs \ burnup$\n {fpath}\n {fpath}\n"
        )
