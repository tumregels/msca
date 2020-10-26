import os
import pathlib
import re
from datetime import datetime

from analysex.file_map import file_map


def main():
    """Calculate burnup duration in minutes for Dragon and Serpent"""
    for key, val in file_map.items():
        # print(key)
        for ftype in ['drag_res', 'drag_res_1level', 'serp_res']:
            if ftype in val:
                if ftype == 'serp_res':
                    drag_file = pathlib.Path(val[ftype].replace('_res.mat', '.result'))
                    s = drag_file.read_text()
                    pat = re.compile(r'''\(MPI=(?P<mpi>\d+)\)''', flags=re.MULTILINE | re.DOTALL | re.X)
                    match = pat.search(s)
                    mpi = int(match.group('mpi'))
                else:
                    drag_file = pathlib.Path(val[ftype])
                datetime_start = datetime.strptime(drag_file.parent.name.replace('output_', ''), '%Y-%m-%d_%H-%M-%S')
                datetime_end = datetime.fromtimestamp(drag_file.stat().st_mtime)
                min_diff = int((datetime_end - datetime_start).total_seconds() / 60.0)
                print(f"{ftype:18s} {drag_file.name:25s} diff: {min_diff:6}") \
                    if ftype != 'serp_res' else print(
                    f"{ftype:18s} {drag_file.name:25s} diff: {min_diff * mpi:6}")
                # print(f"start: {datetime_start} end: {datetime_end}")


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).resolve().parent.parent)
    main()
