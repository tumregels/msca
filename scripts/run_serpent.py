import glob
import json
import os
import os.path as op
import pathlib
import shutil
import subprocess
import sys
from datetime import datetime


def init(config):
    """initialize calculation"""
    # create output directory if missing
    os.makedirs(config.OUTPUT_DIR, exist_ok=True)

    # cleanup previous calculation results
    files = glob.glob(op.join(config.OUTPUT_DIR, "*"))
    for f in files:
        os.remove(f)

    if hasattr(config, "INCLUDE_FILES"):
        for file in config.INCLUDE_FILES:
            shutil.copy(file, config.OUTPUT_DIR)

    # check all paths/files exist
    assert op.isdir(config.XS_LIB_DIR) == True, f"library directory missing {config.XS_LIB_DIR}"
    assert op.isfile(config.INPUT) == True, "serpent input file is missing"
    assert op.isfile(op.join(config.XS_LIB_DIR, config.XS_ACELIB_FILE)) == True, "acelib library file is missing"
    assert op.isfile(op.join(config.XS_LIB_DIR, config.XS_DECLIB_FILE)) == True, "declib library file is missing"
    assert op.isfile(op.join(config.XS_LIB_DIR, config.XS_NFYLIB_FILE)) == True, "nfylib library file is missing"
    assert op.isfile(config.SERPENT_EXE) == True, "serpent exe is missing"

    with open(config.INPUT) as template_:
        serp_input = template_.read().format(
            ACELIB=op.join(config.XS_LIB_DIR, config.XS_ACELIB_FILE),
            DECLIB=op.join(config.XS_LIB_DIR, config.XS_DECLIB_FILE),
            NFYLIB=op.join(config.XS_LIB_DIR, config.XS_NFYLIB_FILE),
        )
    with open(op.join(config.OUTPUT_DIR, config.INPUT), 'w') as f:
        f.write(serp_input)

    # write config file
    with open(op.join(config.OUTPUT_DIR, "config.json"), "w") as f:
        f.write(json.dumps({k: v for k, v in dict(vars(config)).items() if not k.startswith('__')}, indent=4))


def save_pid(file_dir, process_id):
    """save process id to file"""

    print("process id {}".format(process_id))
    file_name = op.join(file_dir, "{}.pid".format(process_id))
    with open(file_name, "w") as f:
        f.write("process id: {}".format(process_id))


def execute(config, background=True):
    """
    This script will immitate the following behavior

        $ /path/to/serpent_exe serpent.in > serpent.out

    To run the script

        $ cd /path/to/serpent/input && python3 /path/to/run_serpent.py

    which will run the simulation in background
    (default behavior set by `background=True`)
    and return the process id.
    To follow up the process use top

        $ top -p process-id

    or tail command

        $ tail -f -n +1 $(ls -td -- output*/ | head -n 1)*.result | nl

    To run in debug mode

        $ DEBUG=1 cd /path/to/serpent/input && python3 /path/to/run_serpent.py

    which will write the output of the simulation
    both to terminal and *.result file.
    """

    init(config)

    output_ = open(config.SERPENT_OUTPUT_FILE, 'w')
    mpi = ['-mpi', str(getattr(config, 'MPI'))] if hasattr(config, 'MPI') and getattr(config, 'MPI') != 1 else []
    serpent_cmd = [config.SERPENT_EXE, *mpi, op.join(config.OUTPUT_DIR, config.INPUT)]

    if background and 'DEBUG' not in os.environ:
        p = subprocess.Popen(
            serpent_cmd,
            stdout=output_,
            cwd=config.OUTPUT_DIR
        )
        save_pid(config.OUTPUT_DIR, p.pid)
    else:
        p = subprocess.Popen(
            serpent_cmd,
            stdout=subprocess.PIPE,
            bufsize=1,
            universal_newlines=True,
            cwd=config.OUTPUT_DIR
        )
        for line in p.stdout:
            output_.write(line)
            print(line, end="")
            sys.stdout.flush()

        p.wait()
        if p.returncode != 0:
            raise subprocess.CalledProcessError(p.returncode, p.args)

    return p


class Config:
    CWD = os.getcwd()
    INPUT = list(pathlib.Path(CWD).glob('*_mc'))[0].stem
    OUTPUT_DIR = op.join(CWD, "output" + "_" + datetime.now().strftime("%Y-%m-%d_%H-%M-%S"))
    XS_LIB_DIR = os.getenv("SERPENT_XS_LIB_DIR") or "/home/nucl/serpent/xs/jeff311"
    XS_ACELIB_FILE = op.join(XS_LIB_DIR, "sss_jeff311u.data")
    XS_DECLIB_FILE = op.join(XS_LIB_DIR, "sss_jeff311.dec")
    XS_NFYLIB_FILE = op.join(XS_LIB_DIR, "sss_jeff311.nfy")
    SERPENT_EXE = os.getenv("SERPENT_EXE") or "/home/legha/bin/serpent-mpi/bin/sss2"
    INCLUDE_FILES = [str(x) for x in pathlib.Path(CWD).glob('DETS_CASE?')]
    # MPI = 5  # number of CPU-s to use
    SERPENT_OUTPUT_FILE = op.join(OUTPUT_DIR, INPUT + ".result")


execute(config=Config, background=True)  # .wait()
