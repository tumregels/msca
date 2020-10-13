from collections import defaultdict

import os
import pandas as pd
import pathlib
import re

from analysex.file_map import file_map


def number2detname():
    map = """
     1 0201
     2 0202
     3 0301
     4 0302
     5 0303
     6 0402
     7 0403
     8 0501
     9 0502
    10 0503
    11 0504
    12 0505
    13 0601
    14 0602
    15 0603
    16 0604
    17 0605
    18 0702
    19 0703
    20 0705
    21 0706
    22 0707
    23 0801
    24 0802
    25 0803
    26 0804
    27 0805
    28 0806
    29 0807
    30 0808
    31 0901
    32 0902
    33 0903
    34 0904
    35 0905
    36 0906
    37 0907
    38 0908
    39 0909
    """

    return {line.split()[0]: 'C' + line.split()[1] for line in map.strip().splitlines()}


def parse_error(filename):
    s = pathlib.Path(filename).read_text()
    map = number2detname()

    pattern = re.compile(r"""
        \s+serpent2\s+dragon5\s*\n
        (\s+\d+\s+.*?\n)\s*maxerr
        """, flags=re.MULTILINE | re.DOTALL | re.X)

    match = pattern.search(s)

    data = {}
    for line in match.group(1).strip().splitlines():
        row = line.split()
        det_name = map[row[0]]
        data[det_name] = float(row[-1])
    # pprint(data)
    return data


def extract_errors(output_path):
    d = file_map
    for level in ['2L', '1L']:
        error_data = defaultdict(dict)
        for key in d.keys():
            if 'ASSBLY' in key:
                drag_path = pathlib.Path(d[key]['drag_res']).resolve().parent if level == '2L' else \
                    pathlib.Path(d[key]['drag_res_1level']).resolve().parent
                for files in [
                    list(drag_path.glob('process_?fm_first.result')),
                    list(drag_path.glob('process_?cm_first.result')),
                    list(drag_path.glob('process_?fm_peak.result')),
                    list(drag_path.glob('process_?cm_peak.result')),
                    list(drag_path.glob('process_?fm_last.result')),
                    list(drag_path.glob('process_?cm_last.result'))
                ]:
                    for file in files:
                        print(file.stem)
                        data = parse_error(file)
                        location = file.stem.split('_')[-1]
                        case = file.stem.split('_')[1][0]
                        type = file.stem.split('_')[1][1]
                        if type not in error_data[location]:
                            error_data[location][type] = {}
                        error_data[location][type][case] = data

        for location in ['first', 'peak', 'last']:
            for type in [('fission', 'f'), ('capture', 'c')]:
                df = pd.DataFrame(error_data[location][type[1]])
                print(df.to_string())
                df.to_csv(str(output_path / f'comp_error_{location}_{type[0]}_{level}.csv'))


if __name__ == '__main__':
    p = pathlib.Path(__file__).resolve().parent.parent.parent
    os.chdir(p)
    data_path = p / 'data'
    data_path.mkdir(parents=True, exist_ok=True)
    extract_errors(data_path)
