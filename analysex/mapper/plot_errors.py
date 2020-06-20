import copy
import io
import os
import pathlib
from textwrap import dedent
from typing import List, Dict, Any

import matplotlib.pyplot as plt  # type: ignore
import numpy as np  # type: ignore
import pandas as pd  # type: ignore
import seaborn as sns  # type: ignore

from analysex.mapper.convert_to_matrix import convert_to_matrix
from analysex.mapper.plot_map import plot_geo_map


def plot_heatmap(
        assembly_map: List[List[Any]],
        data: Dict[str, float],
        filename: str = 'heatmap.png'
) -> None:
    matrix = copy.deepcopy(assembly_map)
    for i, row in enumerate(matrix):
        for j, column in enumerate(row):
            if matrix[i][j] in data:
                matrix[i][j] = data[matrix[i][j]]
            else:
                matrix[i][j] = 0.0

    vmin = min([column for row in matrix for column in row])
    vmax = max([column for row in matrix for column in row])

    matrix = pd.DataFrame(matrix)
    print(matrix.to_string())  # type: ignore

    mask = np.zeros_like(matrix, dtype=np.bool)
    mask[np.tril_indices_from(mask)] = True
    mask[np.diag_indices_from(mask)] = False

    with sns.axes_style("white"):
        f, ax = plt.subplots(figsize=(7, 5))
        ax = sns.heatmap(
            matrix,
            vmin=vmin, vmax=vmax,
            center=0,
            mask=mask,
            cmap=sns.diverging_palette(220, 10, as_cmap=True),
            # square=True,
            annot=True,
            fmt='.2f',
            linewidths=.5,
        )
        ax.set_title(
            r'$Relative \ error \ 100\%\cdot\frac{Dragon5_{NFTOT}-Serpent2_{NFTOT}}{Serpent2_{NFTOT}}$',
            pad=20
        )
        ax.invert_yaxis()
        plt.savefig(filename, dpi=500, bbox_inches="tight")
        plt.show()


def plot_heatmap_label(
        assembly_map: List[List[Any]],
        data: Dict[str, float],
        title: str = '',
        filename: str = 'heatmap_label.png'
) -> None:
    matrix = copy.deepcopy(assembly_map)
    dmatrix = np.zeros_like(matrix, dtype=np.float)
    lmatrix = np.zeros_like(matrix, dtype=np.object)

    for i, row in enumerate(matrix):
        for j, column in enumerate(row):
            if matrix[i][j] in data:
                lmatrix[i][j] = f'{matrix[i][j]}\n{data[matrix[i][j]]:.2f}'
            else:
                lmatrix[i][j] = matrix[i][j]
    lmatrix[7][1] = 'CELL\nERR'  # for legend

    for i, row in enumerate(matrix):
        for j, column in enumerate(row):
            dmatrix[i][j] = data[matrix[i][j]] if matrix[i][j] in data else 0.0

    vmin = min([column for row in dmatrix for column in row])
    vmax = max([column for row in dmatrix for column in row])

    dmatrix = pd.DataFrame(dmatrix)
    print(dmatrix.to_string())
    lmatrix = pd.DataFrame(lmatrix)
    print(lmatrix.to_string())

    mask = np.zeros_like(matrix, dtype=np.bool)
    mask[np.tril_indices_from(mask)] = True
    mask[np.diag_indices_from(mask)] = False
    mask[7][1] = False  # for legend

    with sns.axes_style("white"):
        f, ax = plt.subplots(figsize=(7, 5))
        sns.heatmap(
            dmatrix,
            vmin=vmin, vmax=vmax,
            center=0,
            mask=mask,
            cmap=sns.diverging_palette(220, 10, as_cmap=True),
            # square=True,
            annot=lmatrix,
            annot_kws={"fontsize": 8},
            fmt='',
            linewidths=.5,
            xticklabels=False,
            yticklabels=False,
        )
        ax.set_title(
            '\n'.join([
                title,
                r'$Relative \ error \ 100\%\cdot\frac{Dragon5_{NFTOT}-Serpent2_{NFTOT}}{Serpent2_{NFTOT}}$'
            ]).strip(),
            pad=20
        )
        ax.invert_yaxis()

        plt.savefig(filename, dpi=300, bbox_inches="tight")
        plt.show()


def plot_table(
        assembly_map: List[List[Any]],
        data: Dict[str, float],
        filename: str = 'table.png'
) -> None:
    map = copy.deepcopy(assembly_map)
    matrix = np.zeros_like(map, dtype=object)

    for i, row in enumerate(map):
        for j, column in enumerate(row):
            if map[i][j] in data:
                matrix[i][j] = (map[i][j], str(data[map[i][j]]))
            else:
                matrix[i][j] = map[i][j]

    plot_geo_map(matrix, filename=filename)


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).resolve().parent.parent.parent)

    assembly_map = """
    TI C0201 C0301     TG  C0501  C0601     TG   C0801 C0901
       C0202 C0302  C0402  C0502  C0602  C0702   C0802 C0902
             C0303  C0403  C0503  C0603  C0703   C0803 C0903
                       TG  C0504  C0604     TG   C0804 C0904
                           C0505  C0605  C0705   C0805 C0905
                                     TG  C0706   C0806 C0906
                                         C0707   C0807 C0907
                                                 C0808 C0908
                                                       C0909
                                                            
    """

    map = convert_to_matrix(assembly_map, debug=True)

    error_csv = """
    ,caseA,caseB,caseC,caseD
    C0201,0.23,0.43,-0.05,0.54
    C0202,0.29,-0.27,-0.28,-0.11
    C0301,0.03,0.21,-0.17,-1.14
    C0302,0.17,0.04,-0.05,-0.01
    C0303,-0.15,-0.18,-0.15,0.42
    C0402,0.05,-0.03,0.08,-0.24
    C0403,0.07,-0.1,-0.07,0.42
    C0501,0.0,-0.12,-0.49,0.12
    C0502,-0.08,0.08,0.01,-0.08
    C0503,-0.0,0.22,0.26,-0.04
    C0504,-0.31,-0.01,-0.04,-0.18
    C0505,-0.16,-0.16,-0.18,-1.49
    C0601,0.34,-0.19,-0.07,-1.17
    C0602,-0.1,-0.04,-0.1,0.1
    C0603,0.09,-1.67,-1.61,-0.15
    C0604,0.25,-0.17,-0.35,0.08
    C0605,-0.01,-0.36,-0.12,0.0
    C0702,0.09,-0.17,0.08,-0.08
    C0703,-0.21,0.4,0.55,-0.03
    C0705,0.04,-0.19,-0.23,0.01
    C0706,0.29,0.02,-0.0,0.05
    C0707,0.1,-0.06,-0.88,-1.31
    C0801,0.24,-0.04,0.34,0.24
    C0802,-0.01,-0.21,-0.15,0.09
    C0803,-0.17,0.08,0.15,0.12
    C0804,-0.03,-0.09,0.03,-1.27
    C0805,-0.12,-0.1,-0.05,0.32
    C0806,-0.27,-0.13,-0.27,-0.1
    C0807,-0.11,0.29,-0.03,0.32
    C0808,-0.09,0.35,0.22,29.19
    C0901,0.09,-0.41,0.15,0.36
    C0902,-0.07,-0.03,0.16,-15.43
    C0903,0.1,0.18,0.25,0.01
    C0904,0.01,0.01,0.14,0.27
    C0905,-0.22,0.0,-0.01,0.13
    C0906,-0.1,0.16,-0.08,-0.14
    C0907,0.27,0.37,0.29,0.15
    C0908,-0.02,0.11,0.05,0.5
    C0909,-0.13,0.25,0.27,0.34
    """

    df = pd.read_csv(io.StringIO(dedent(error_csv)), index_col=0)
    datas = df.to_dict()
    for key, data in datas.items():
        # plot_table(map, data, f'table_{key.lower()}.png')
        # plot_heatmap(map, data, filename=f'heatmap_{key.lower()}.png')
        plot_heatmap_label(
            map, data,
            filename=f'all_plots/heatmap_{key.lower()}_label.png',
            title=f'${key[:-1]} \ {key[-1]}$'
        )
