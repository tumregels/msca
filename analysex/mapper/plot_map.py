import ast
import os
import pathlib
from textwrap import dedent

import matplotlib.pyplot as plt
import numpy as np


# import matplotlib.patches as mpatches

def parse_tuple(string):
    try:
        s = ast.literal_eval(str(string))
        if type(s) == tuple:
            return s
        return
    except:
        return


def plot_geo_map(matrix, filename='table', label='', title=''):
    matrix = matrix[::-1]  # rotate along x axes

    data = np.asarray(matrix)
    p = plt.figure()
    # p.set_size_inches(28, 16)
    ax = plt.gca()
    ax.axis("off")  # disable picture frame

    if title:
        plt.suptitle(title, size=68, y=3.8)

    tb = plt.table(cellText=data, loc=(0, 0), cellLoc='center')
    # tb.scale(2,8)
    tb.set_fontsize(54)

    for rc, cell in tb.get_celld().items():
        cell.set_height(1.0)
        cell.set_width(1.5)

        # print(rc, cell.get_text(), cell)

        # hide all zeros
        if cell.get_text().get_text() == '0': cell.set_visible(False)

        if 'TI' in cell.get_text().get_text(): cell.set_facecolor("#7FC544")
        if any(x in cell.get_text().get_text() for x in ['T2', 'T1', 'TG']): cell.set_facecolor("#8AD2EA")
        if any(x in cell.get_text().get_text() for x in [f'G{i}' for i in range(1, 6)]): cell.set_facecolor("#F3BE18")
        if 'C1' in cell.get_text().get_text(): cell.set_facecolor("#EFF4AE")
        if 'C2' in cell.get_text().get_text(): cell.set_facecolor("#FBD7CE")
        if 'C3' in cell.get_text().get_text(): cell.set_facecolor("#D8CDE6")
        if 'C4' in cell.get_text().get_text(): cell.set_facecolor("#EAF5E2")
        if 'C5' in cell.get_text().get_text(): cell.set_facecolor("#FCDEAD")
        if 'C6' in cell.get_text().get_text(): cell.set_facecolor("#DBEFFC")
        if 'C7' in cell.get_text().get_text(): cell.set_facecolor("#D6ECCA")
        if 'C8' in cell.get_text().get_text(): cell.set_facecolor("#F8F9C4")

        t = parse_tuple(cell.get_text().get_text())
        if t:
            cell.get_text().set_text('\n'.join(t))

        if not label:
            label = '''\
                L1 cell name
                L1 cell mixtures
                L2 cell name
                L2 cell mixtures'''

        if rc == (0, 0):
            cell.set_visible(True)
            cell.get_text().set_text(dedent(label))
            cell.set_facecolor("#FFFFFF")

        if rc == (1, 0):
            cell.set_visible(True)
            cell.get_text().set_text('$\ Instrumentation \ tube$')
            cell.set_facecolor("#7FC544")

        if rc == (2, 0):
            cell.set_visible(True)
            cell.get_text().set_text('$\ Water\ whole$')
            cell.set_facecolor("#8AD2EA")

    # red_patch = mpatches.Patch(color='red', label='The red data')
    # green_patch = mpatches.Patch(color='green', label='The green data')
    # plt.legend(handles=[red_patch, green_patch],
    #            prop={'size': 36}, loc='upper left',
    #            bbox_to_anchor=(-0.4, 3.7),
    #            ncol=2)

    p.savefig(filename + '.pdf', bbox_inches='tight')
    p.savefig(filename + '.eps', bbox_inches='tight')


def main():
    matrix = [
        ['TI', 'C1', 'C1', 'T1', 'C1', 'C1', 'T2', 'C4', 'C6'],
        [0, 'C2', 'C2', 'C1', 'C2', 'C2', 'C1', 'C2', 'C6'],
        [0, 0, 'C2', 'C1', 'C2', 'C2', 'C1', 'C2', 'C6'],
        [0, 0, 0, 'T1', 'C1', 'C1', 'T2', 'C4', 'C6'],
        [0, 0, 0, 0, 'C2', 'C1', 'C1', 'C2', 'C6'],
        [0, 0, 0, 0, 0, 'T2', 'C1', 'C3', 'C6'],
        [0, 0, 0, 0, 0, 0, 'C2', 'C3', 'C6'],
        [0, 0, 0, 0, 0, 0, 0, 'C5', 'C7'],
        [0, 0, 0, 0, 0, 0, 0, 0, 'C8']
    ]
    plot_geo_map(matrix)


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).resolve().parent.parent.parent)
    main()
