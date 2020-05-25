import os
import pathlib
import re
from decimal import Decimal
from typing import Tuple, List

import matplotlib.pyplot as plt


def parse_res_output(data: str) -> dict:
    lines = data.splitlines()

    data_lines = []
    # start from line 10, loop through all lines
    for line in lines[10:]:
        # skip lines starting with '%
        if line.startswith('%'):
            continue
        # consider lines with equals sign
        if '=' in line:
            data_lines.append(line)

    dict_ = {}  # declare dictionary

    for line in data_lines:
        equal = line.split('=')
        key = equal[0].split()[0]
        value = equal[1].strip(' [];')

        # check to see if key already exists
        # this will occur in burnup mode due to the way output file are written.
        if key in dict_:
            tmp_exist = dict_[key]  # store current data
            tmp_new = value.split()  # store new data
            #  loop over all new values and append to exist
            for tmp in tmp_new:
                try:
                    tmp_exist.append(float(tmp))
                except ValueError:
                    tmp_exist.append(tmp)

            dict_.update({key: tmp_exist})

        # add new key to dictionary
        else:
            try:
                dict_.update({key: [float(tmp_s) for tmp_s in value.split()]})
            except ValueError:
                dict_.update({key: value.split()})

    return dict_


def parse_burnup_vs_keff_serp(data: dict) -> List[Tuple[float, float]]:
    burnup_vs_keff = [(data['BURNUP'][::2][i], data['ABS_KEFF'][::2][i]) for i in range(len(data['BURNUP'][::2]))]
    return burnup_vs_keff


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


def plot_serp_dragon_burnup_vs_keff_(
        data_serp: List[Tuple[Decimal, Decimal]],
        data_drag: List[Tuple[Decimal, Decimal]],
        filename: str = 'keff_vs_burnup.png',
        title: str = '$k_{eff} \ vs \ Burnup$'
):
    xd = [x[0] for x in data_drag]
    yd = [x[1] for x in data_drag]

    xs = [x[0] for x in data_serp]
    ys = [x[1] for x in data_serp]

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

    fig = plt.figure()

    p1 = plt.subplot(2, 1, 1)
    p1.set_title(title, fontsize=12)

    plt.grid()
    plt.plot(xd, yd, 'or', label='Dragon 5')
    plt.plot(xs, ys, '+b', label='Serpent 2')

    # plt.xlabel(r'$Burnup \ \frac{MWd}{kgU}$', fontsize=12)
    plt.ylabel(r'$Multiplication \ factor \ k_{eff}$', fontsize=12)
    plt.legend(loc="upper right")

    p2 = plt.subplot(2, 1, 2)
    plt.grid()
    relative_error = [100 * (ys[i] - yd[i]) / ys[i] for i in range(len(ys))]

    plt.semilogy(xd, relative_error, 'xg', label=r'$\frac{k_{Serpent}-k_{Dragon}}{k_{Serpent}} \times 100$')
    plt.xlabel(r'$Burnup \ \frac{MWd}{kgU}$', fontsize=12)
    plt.ylabel(r'$Relative \ error, \%$', fontsize=12)
    plt.legend(loc="upper right", fontsize=15)
    p2.yaxis.set_label_coords(-0.04, 0.52)

    plt.savefig(filename, dpi=300, bbox_inches="tight")
    plt.show()
    plt.close(fig)


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).parent.parent)

    plt.rcParams['figure.figsize'] = [15, 7.5]

    drag_output_files = [
        'Dragon/PIN_A/output_2020-05-01_23-02-16/CGN_PIN_A.result',
        'Dragon/PIN_B/output_2020-05-02_00-15-18/CGN_PIN_B.result',
        'Dragon/PIN_C/output_2020-05-02_00-16-03/CGN_PIN_C.result',
    ]

    serp_output_files = [
        'Serpent/PIN_A/output_2020-05-11_22-39-35/PIN_CASEA_mc_res.m',
        'Serpent/PIN_B/output_2020-05-11_22-39-42/PIN_CASEB_mc_res.m',
        'Serpent/PIN_C/output_2020-05-11_22-39-48/PIN_CASEC_mc_res.m',
    ]

    for i in range(len(drag_output_files)):
        serp_file_name = serp_output_files[i]
        serp_pin_a_str = pathlib.Path(serp_file_name).read_text()
        serp_res_data = parse_res_output(serp_pin_a_str)
        burnup_vs_keff_serp = parse_burnup_vs_keff_serp(serp_res_data)

        drag_file_name = drag_output_files[i]
        dragon_pin_a_str = pathlib.Path(drag_file_name).read_text()
        burnup_vs_kinf_dragon = parse_burnup_vs_kinf_drag(dragon_pin_a_str)

        plot_serp_dragon_burnup_vs_keff_relative_error(
            data_serp=burnup_vs_keff_serp,
            data_drag=burnup_vs_kinf_dragon,
            title=f'$k_{{eff}} \ vs \ Burnup$\n {serp_file_name}\n {drag_file_name}\n',
            filename=f'pin_plots/keff_vs_burnup_comparison_{re.search("/(PIN_.*?)/", serp_file_name).group(1)}.png'
        )
