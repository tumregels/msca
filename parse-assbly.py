# ## Compare the following information
#
# * Fission and capture reaction rate comparisons at each burnup step
# * Number density evolution for typical isotopes with burnup
# * Keff comparison at each burnup step (DRAGON+)
# * Fission map comparison at each burnup step
import csv
import pathlib
import re
from decimal import Decimal
from typing import Iterator, Tuple, List

import matplotlib.pyplot as plt


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


def parse_burnup_vs_keff(s: str, debug: bool = False) -> List[Tuple[Decimal, Decimal]]:
    """
    Parse ECHO dragon statement to extract values for BURNUP and K-INFINITY

    >>> s = '\\n>|Resultat1 Keff=   1.082721e+00  at burnup=   0.000000e+00               |>0173\\n'
    >>> parse_burnup_vs_keff(s)
    [(Decimal('0.000000'), Decimal('1.082721'))]
    """

    end = '.*\n'
    line = [m.end() for m in re.finditer(end, s)]

    burn_vs_keff = []  # save burnup vs kinf in list

    pattern = r'''>\|(Resultat1 Keff=(?P<keff>.*?)  at burnup=(?P<burnup>.*?))(?=\|>\d+)'''
    match = re.compile(pattern, re.MULTILINE | re.DOTALL)
    for m in re.finditer(match, s):
        lineno = next(i + 1 for i in range(len(line)) if line[i] > m.start(1))
        endno = lineno + len(m.group().splitlines()) - 1
        text = m.group()
        burnup = Decimal(m.group("burnup").strip())
        keff = Decimal(m.group("keff").strip())
        print(
            f'start:{lineno: <6} end:{endno: <6} burnup: {float(burnup)} kinf: {float(keff)} text: {text}'
        ) if debug else None
        burn_vs_keff.append((burnup, keff))

    return burn_vs_keff


def plot_burnup_vs_keff(
        data: List[Tuple[Decimal, Decimal]],
        filename: str = 'keff_vs_burnup.png',
        title: str = '$k_{eff} \ vs \ Burnup$'
):
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


def save_as_csv(data: List[Tuple[Decimal, Decimal]], filename: str = 'burnup_vs_keff.csv'):
    with open(filename, 'w') as out:
        csv_out = csv.writer(out)
        csv_out.writerow(['burnup', 'keff'])
        for row in data:
            csv_out.writerow(row)


def create_plots(path: pathlib.Path) -> None:
    long_str = path.read_text()

    regex = re.search('^Dragon/(ASSEMBLY.*?)/.*.result$', str(path))
    if regex:
        print(f'plotting for {path}')
        name = '_' + regex.group(1).lower() if regex else ''
        burnup_vs_keff = parse_burnup_vs_keff(long_str)
        save_as_csv(burnup_vs_keff, filename=f'burnup_vs_keff{name}.csv')
        plot_burnup_vs_keff(data=burnup_vs_keff, filename=f'burnup_vs_keff{name}.png',
                            title=f'$k_{{eff}} \ vs \ Burnup$\n {name.replace("_", " ")}')
        plot_burnup_vs_keff(data=burnup_vs_keff[:10],
                            filename=f'burnup_vs_keff_cut{name}.png',
                            title=f'$k_{{eff}} \ vs \ Burnup$\n {name.replace("_", " ")} cut')


if __name__ == '__main__':
    for path in pathlib.Path('Dragon').rglob('*.result'):
        create_plots(path)
