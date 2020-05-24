import csv
import os
import pathlib
import re
from decimal import Decimal
from typing import List, Dict, Any, Tuple

from analysex.parse_pin import get_iso_density_per_ring


def round_up(x):
    ndigits = -(len(str(int(x))) - 3)
    return round(x, ndigits)


def get_burnup_step_data(input_: str, debug: bool = False) -> List[Dict[str, Any]]:
    """parse dragon result output into separate burnup step data
    which contains start line, end line and text of each burnup step
    """
    pattern = 'EVOBLD: TARGET FUEL BURNUP .*?\((?P<step>.*?)MW\*DAY/TONNE\)'
    match = re.compile(pattern)
    burnup = 0.0
    burnup_steps = []
    lines = input_.splitlines()

    for j, line in enumerate(lines, start=1):
        m = re.search(match, line)
        # if matched append line number and burnup into list
        if m:
            lineno = j
            mtext = m.group()
            step = float(m.group('step').strip())
            print(f'lineno start:{lineno: <6} step: {step} text: {mtext[:70]}') if debug else None
            burnup += step
            burnup_steps.append((round_up(burnup), lineno))

    # calculate burnup step start and end line numbers
    data_points = [dict(burnup=burnup, start=start, end=burnup_steps[i + 1][1] - 1)
                   for i, (burnup, start) in enumerate(burnup_steps[:-1])
                   ]
    data_points.append(dict(burnup=burnup_steps[-1][0], start=burnup_steps[-1][1], end=len(lines)))

    print([d['burnup'] for d in data_points]) if debug else None

    # extract text between start and end line numbers
    for d in data_points:
        d['text'] = '\n'.join(lines[d['start']:d['end']]).lstrip()

    return data_points


def save_as_csv(data: Dict[Decimal, List[Tuple[str, str, Decimal]]], filename: str):
    print(f'parsing {filename}', end=' ')

    pathlib.Path(filename).parent.mkdir(exist_ok=True, parents=True)
    with open(filename, 'w', newline="") as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(["burnup", "isotope", "mixture", "atomic density 10**24 p/cc"])
        for key, value in data.items():
            for item in value:
                writer.writerow([float(key), item[0], item[1], item[2]])

    print('\u2713')


def save_as_csv_sorted(data: Dict[Decimal, List[Tuple[str, str, Decimal]]], filename: str):
    print(f'parsing {filename}', end=' ')

    pathlib.Path(filename).parent.mkdir(exist_ok=True, parents=True)
    with open(filename, 'w', newline="") as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(["burnup", "isotope", "mixture", "atomic density 10**24 p/cc"])
        new_data = []
        for key, value in data.items():
            for item in value:
                new_data.append((float(key), item[0], item[1], float(item[2])))
        new_data = sorted(new_data, key=lambda x: (
            int(x[2]), int(x[1].replace('Pu', '').replace('U', ''))))
        writer.writerows(new_data)

    print('\u2713')


def extract_pin_data():
    drag_output_files = [
        'Dragon/PIN_A/output_2020-05-01_23-02-16/CGN_PIN_A.result',
        'Dragon/PIN_B/output_2020-05-02_00-15-18/CGN_PIN_B.result',
        'Dragon/PIN_C/output_2020-05-02_00-16-03/CGN_PIN_C.result',
    ]

    for i in range(len(drag_output_files)):
        drag_file_name = drag_output_files[i]
        text = pathlib.Path(drag_file_name).read_text()
        data_points = get_burnup_step_data(text, debug=False)

        for d in data_points:
            d['iso'] = get_iso_density_per_ring(d['text'])

        burnup_vs_iso = {Decimal(d['burnup']): d['iso'] for d in data_points}

        csvfilename = 'pin_plots/adens_vs_burnup_data_{}.csv'.format(
            re.search("/(PIN_.*?)/", drag_file_name).group(1))
        save_as_csv_sorted(data=burnup_vs_iso, filename=csvfilename)


def extract_assbly_data():
    filenames = [
        'Dragon/ASSEMBLY_A/output_2020-05-17_17-42-26/UOX_TBH_eighth_2level_g2s.result',
        'Dragon/ASSEMBLY_B/output_2020-05-17_23-29-31/GD_TBH_eighth_2level_g2s.result',
        'Dragon/ASSEMBLY_C/output_2020-05-17_23-27-23/GD_TBH_eighth_2level_g2s.result',
        'Dragon/ASSEMBLY_D/output_2020-05-17_20-49-07/GD_TBH_eighth_2level_g2s.result',
    ]

    for filename in filenames:
        text = pathlib.Path(filename).read_text()
        data_points = get_burnup_step_data(text, debug=False)

        for d in data_points:
            d['iso'] = get_iso_density_per_ring(d['text'])

        burnup_vs_iso = {Decimal(d['burnup']): d['iso'] for d in data_points}
        csvfilename = 'assbly_plots/adens_vs_burnup_data_{}.csv'.format(
            re.search("/(ASSEMBLY_.*?)/", filename).group(1))
        save_as_csv_sorted(data=burnup_vs_iso, filename=csvfilename)


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).parent.parent)
    extract_assbly_data()
    extract_pin_data()
