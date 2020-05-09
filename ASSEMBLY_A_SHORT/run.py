#!/home/legha/bin/miniconda3/envs/jupyter/bin/python3
import json
import os
import os.path as op
import sys
import os
import stat
import subprocess
import shutil
import glob
from datetime import datetime


def init(config):
    """initialize calculation"""
    # create output directory if missing
    os.makedirs(config.OUTPUT_DIR, exist_ok=True)

    # cleanup previous calculation results
    files = glob.glob(op.join(config.OUTPUT_DIR, "*"))
    for f in files:
        os.remove(f)

    # remove old symlink and create new one
    if op.isfile(config.LIB_SYMLINK):
        os.remove(config.LIB_SYMLINK)

    try:
        os.symlink(config.LIB_FILE, config.LIB_SYMLINK)
    except FileExistsError:
        pass

    # copy input file into output directory
    shutil.copy(config.DRAGON_INPUT_FILE, config.OUTPUT_DIR)
    
    if hasattr(config, "DRAGON_INPUT_SUPPORT_FILES"):
        for file in config.DRAGON_INPUT_SUPPORT_FILES:
            shutil.copy(file, config.OUTPUT_DIR)

    # check all paths/files exist
    assert op.isdir(config.LIB_DIR) == True, "library directory missing"
    assert op.isfile(config.LIB_FILE) == True, "library file is missing"
    assert op.isfile(config.LIB_SYMLINK) == True, "symlink is missing"
    assert op.isfile(config.DRAGON_INPUT_FILE) == True, "dragon input file is missing"
    assert op.isfile(config.DRAGON_EXE) == True, "dragon exe is missing"

    # write config file
    with open(op.join(config.OUTPUT_DIR, "config.json"), "w") as f:
        f.write(json.dumps({k: v for k, v in dict(vars(config)).items() if not k.startswith('__')}, indent=4))


def save_pid(file_dir, process_id):
    """save process id to file"""

    print("process id {}".format(process_id))
    file_name = op.join(file_dir, "{}.pid".format(process_id))
    with open(file_name, "w") as f:
        f.write("process id: {}".format(process_id))


def execute(config, background=False):
    """
    this will immitate the following behavior
    
    $ dragon_exe < file.in > file.out
    
    to run the script
    
    $ ./run.py
    
    which will return process id if `background=False`
    To follow up the process use top
    
    $ top -p process-id
    """
    
    init(config)
    
    input_ = open(config.DRAGON_INPUT_FILE)
    output_ = open(config.DRAGON_OUTPUT_FILE, 'w')

    if background:
        p = subprocess.Popen(
            config.DRAGON_EXE, 
            stdin=input_, 
            stdout=output_, 
            cwd=config.OUTPUT_DIR
        )
        save_pid(config.OUTPUT_DIR, p.pid)
    else:
        p = subprocess.Popen(
            config.DRAGON_EXE,
            stdout=subprocess.PIPE,
            stdin=input_,
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


class Config(object):
    INPUT = "UOX_TBH_eighth_2level_g2s"
    CWD = os.getcwd()
    OUTPUT_DIR = op.join(CWD, "output" + "_" + datetime.now().strftime("%Y-%m-%d_%H-%M-%S"))
    LIB_DIR = os.getenv("DRAGON_LIB_DIR") or "/home/legha/bin/libraries/l_endian"
    LIB_FILE = op.join(LIB_DIR, "draglibJeff3p1p1SHEM295")
    LIB_SYMLINK = op.join(OUTPUT_DIR, "DLIB_295")
    DRAGON_EXE = os.getenv("DRAGON_EXE") or "/home/legha/bin/Version5_ev1738/Dragon/bin/Linux_x86_64/Dragon"
    DRAGON_INPUT_FILE_NAME = INPUT + ".x2m"
    DRAGON_INPUT_FILE = op.join(CWD, DRAGON_INPUT_FILE_NAME)
    DRAGON_INPUT_SUPPORT_FILES = ['Geo_N1.c2m',
                                  'Geo_N2.c2m',
                                  'Geo_SS.c2m',
                                  'MultLIBEQ.c2m',
                                  'Mix_UOX.c2m',
                                  'assertS.c2m']
    DRAGON_OUTPUT_FILE = op.join(OUTPUT_DIR, INPUT + ".result")
    

execute(config=Config, background=True)  # .wait()
