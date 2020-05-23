# ## Compare the following information
# 
# * Fission and capture reaction rate comparisons at each burnup step
# * Number density evolution for typical isotopes with burnup


import os
import pathlib
import re
from decimal import Decimal
from typing import Iterator, Tuple, List, Dict, Any

import matplotlib.pyplot as plt
import scipy.io
from matplotlib.ticker import ScalarFormatter


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


def parse_burnup_vs_kinf(s: str, debug: bool = False) -> List[Tuple[Decimal, Decimal]]:
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
        burnup = Decimal(m.group("burnup").strip())
        kinf = Decimal(m.group("kinf").strip())
        print(
            f'start:{lineno: <6} end:{endno: <6} burnup: {float(burnup)} kinf: {float(kinf)} text: {text}'
        ) if debug else None
        burn_vs_kinf.append((burnup, kinf))

    return burn_vs_kinf


def get_burnup_step_data(s: str, debug: bool = False) -> Iterator[Tuple[str, str]]:
    end = '.*\n'
    line = [m.end() for m in re.finditer(end, s)]

    pattern = '>\|(BURNUP step (?P<step>\d+).*?)(?=>\|BURNUP step|>\|CGN_PIN_A completed)'
    match = re.compile(pattern, re.MULTILINE | re.DOTALL)
    for m in re.finditer(match, s):
        lineno = next(i + 1 for i in range(len(line)) if line[i] > m.start(1))
        endno = lineno + len(m.group().splitlines()) - 1
        text = m.group()
        step = m.group('step')
        print(f'lineno start:{lineno: <6} end:{endno: <6} step: {step} text: {text[:70]}') if debug else None
        yield step, text


def get_iso_density_per_ring(s: str, debug: bool = False) -> List[Tuple[str, str, Decimal]]:
    iso_data = []
    for iso in ['Pu239', 'U235', 'Pu241']:
        pattern = (
            # look behind and find ISOTOPIC DENSITIES string
            '(?<=ISOTOPIC DENSITIES AFTER BURNUP FOR MIXTURE =)\s+?(?P<ring>\d+)\s\(10\*\*24 PARTICLES/CC\)'
            # some data
            '.*?'
            # iso name followed by : and float number
            f'{iso}\s+:[\s=]+(?P<density>[+-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+))'
        )
        prog = re.compile(pattern, re.MULTILINE | re.DOTALL)
        for m in re.finditer(prog, s):
            ring = m.group('ring')
            density = Decimal(m.group('density'))
            # print(m.group())
            print(f'iso: {iso: <5} ring: {ring: <2} dens: {density: <10}') if debug else None
            iso_data.append((iso, ring, density))
    return iso_data


def get_iso_dens_vs_burnup(s: str, debug: bool = False) -> Dict[Decimal, List[Tuple[str, str, Decimal]]]:
    iso_dens_vs_burnup = {}
    for burnup_step, burnup_step_text in get_burnup_step_data(s, debug=debug):
        print(burnup_step, burnup_step_text[:70] + '...') if debug else None
        iso_data = get_iso_density_per_ring(burnup_step_text, debug=debug)
        burnup_value = parse_burnup_vs_kinf(burnup_step_text, debug=debug)[0][0]
        print(f'burnup_step: {burnup_step} burnup_value: {burnup_value} iso_data: {iso_data}') if debug else None
        iso_dens_vs_burnup[burnup_value] = iso_data
    return iso_dens_vs_burnup


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
        data: Any,
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


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).parent.parent)

    drag_output_files = [
        'Dragon/PIN_A/output_2020-05-01_23-02-16/CGN_PIN_A.result',
        'Dragon/PIN_B/output_2020-05-02_00-15-18/CGN_PIN_B.result',
        'Dragon/PIN_C/output_2020-05-02_00-16-03/CGN_PIN_C.result'
    ]

    for p in drag_output_files:
        file = pathlib.Path(p)
        long_str = file.read_text()

        iso_dens_vs_burnup = get_iso_dens_vs_burnup(long_str, debug=False)
        plot_atomic_dens_vs_burnup_dragon(
            data=iso_dens_vs_burnup,
            title=f'$Atomic density \ vs \ Burnup$\n {file}\n',
            filename=f'pin_plots/atomic_dens_vs_burnup_{re.search("/(PIN_.*?)/", str(file)).group(1)}'
        )

    serp_output_files = [
        'Serpent/PIN_A/output_2020-05-11_22-39-35/PIN_CASEA_mc_dep.mat',
        'Serpent/PIN_B/output_2020-05-11_22-39-42/PIN_CASEB_mc_dep.mat',
        'Serpent/PIN_C/output_2020-05-11_22-39-48/PIN_CASEC_mc_dep.mat',
    ]

    for p in serp_output_files:
        data = scipy.io.loadmat(p)
        plot_atomic_dens_vs_burnup_serpent(
            data=data,
            title=f'$Atomic density \ vs \ Burnup$\n {p}\n',
            filename=f'pin_plots/atomic_dens_vs_burnup_serpent_{re.search("/(PIN_.*?)/", p).group(1)}'
        )
