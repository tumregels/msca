import os
import pathlib
import re

from mapper.extract_map import create_two_level_matrix
from mapper.plot_map import plot_geo_map


def main():
    for assbly in ['ASSBLY_A', 'ASSBLY_B', 'ASSBLY_C', 'ASSBLY_D']:
        filenames = list(pathlib.Path(f'Dragon/{assbly}').glob('Geo_N?.c2m'))
        matrix = create_two_level_matrix(*filenames)
        plot_geo_map(
            matrix,
            filename=f'{re.search("/(ASS.*?_.*?)/", str(filenames[0])).group(1).lower()}.png'
        )


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).resolve().parent.parent.parent)
    main()
