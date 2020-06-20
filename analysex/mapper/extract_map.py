import copy
import os
import pathlib
import re

from pandas import DataFrame

from mapper.convert_to_matrix import convert_to_matrix, join_matrixes
from mapper.parse_mixtures import get_name_mix_dict


def extract_geo_map(filename):
    """extract assembly map"""
    s = pathlib.Path(filename).read_text()

    pat = re.compile(r'''
    ^\s+CELL\s+\n?
    (?P<map>TI.*?)
    (?:MESHX|MERGE)
    ''', flags=re.MULTILINE | re.DOTALL | re.X)

    for m in pat.finditer(s):
        matrix = convert_to_matrix(m.groupdict()["map"])
        print(DataFrame(matrix).to_string())
        return matrix


def add_mix_info_to_matrix(matrix, mix_map, debug=False):
    m = copy.deepcopy(matrix)
    for r, l in enumerate(m, start=1):
        for c, item in enumerate(l, start=1):
            if item != 0:
                val = mix_map[m[r - 1][c - 1]]
                m[r - 1][c - 1] = (m[r - 1][c - 1], val)
    if debug:
        print(DataFrame(m).to_string())
    return m


def create_two_level_matrix(geo_n1_filename, geo_n2_filename):
    matrixes = []
    for filename in [geo_n1_filename, geo_n2_filename]:
        print(filename)
        matrix = extract_geo_map(filename)
        mix_map = get_name_mix_dict(filename)
        matrix = add_mix_info_to_matrix(matrix, mix_map)
        matrixes.append(matrix)

    full_matrix = join_matrixes(*matrixes)
    print(DataFrame(full_matrix).to_string())
    return full_matrix


def main():
    filenames = list(pathlib.Path('Dragon/ASSBLY_B').glob('Geo_N?.c2m'))
    return create_two_level_matrix(*filenames)


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).resolve().parent.parent.parent)
    main()
