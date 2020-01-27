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
    files = glob.glob(os.path.join(config.OUTPUT_DIR, "*"))
    for f in files:
        os.remove(f)

    # remove old symlink and create new one
    if os.path.isfile(config.LIB_SYMLINK):
        os.remove(config.LIB_SYMLINK)

    try:
        os.symlink(config.LIB_FILE, config.LIB_SYMLINK)
    except FileExistsError:
        pass

    # copy input file into output directory
    shutil.copyfile(config.DRAGON_INPUT_FILE, config.DRAGON_INPUT_FILE_COPY)

    # write config file
    with open(config.CONFIG_FILE, "w") as f:
        f.write(json.dumps({k: v for k, v in dict(vars(config)).items() if not k.startswith('__')}, indent=4))

    # check all paths/files exist
    assert os.path.isdir(config.LIB_DIR) == True, "library directory missing"
    assert os.path.isfile(config.LIB_FILE) == True, "library file is missing"
    assert os.path.isfile(config.LIB_SYMLINK) == True, "symlink is missing"
    assert os.path.isfile(config.DRAGON_INPUT_FILE) == True, "dragon input file is missing"
    assert os.path.isfile(config.DRAGON_INPUT_FILE_COPY) == True, "copy of dragon input file is missing"
    assert os.path.isfile(config.DRAGON_EXE) == True, "dragon exe is missing"


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
        print("process id {}".format(p.pid))
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


class ConfigShortA(object):
    INPUT = "CGN_PIN_A_SHORT"
    CWD = os.getcwd()
    OUTPUT_DIR = op.join(CWD, "output" + "_" + INPUT + "_" + datetime.now().strftime("%Y-%m-%d_%H-%M-%S"))
    LIB_DIR = op.join(CWD, os.pardir, os.pardir, os.pardir, "libraries/l_endian")
    LIB_FILE = op.abspath(op.join(LIB_DIR, "draglibJeff3p1p1SHEM295"))
    LIB_SYMLINK = op.join(OUTPUT_DIR, "DLIB_295")
    DRAGON_EXE = op.abspath(op.join(CWD, os.pardir, "bin/Linux_x86_64/Dragon"))
    DRAGON_INPUT_FILE_NAME = INPUT + ".x2m"
    DRAGON_INPUT_FILE = op.join(CWD, DRAGON_INPUT_FILE_NAME)
    DRAGON_INPUT_FILE_COPY = op.join(OUTPUT_DIR, DRAGON_INPUT_FILE_NAME)
    DRAGON_OUTPUT_FILE = op.join(OUTPUT_DIR, INPUT + ".result")
    CONFIG_FILE = op.join(OUTPUT_DIR, "config.json")
    
    
# execute(config=ConfigShortA, background=True).wait()


class ConfigPinA(object):
    INPUT = "CGN_PIN_A"
    CWD = os.getcwd()
    OUTPUT_DIR = op.join(CWD, "output" + "_" + INPUT + "_" + datetime.now().strftime("%Y-%m-%d_%H-%M-%S"))
    LIB_DIR = op.join(CWD, os.pardir, os.pardir, os.pardir, "libraries/l_endian")
    LIB_FILE = op.abspath(op.join(LIB_DIR, "draglibJeff3p1p1SHEM295"))
    LIB_SYMLINK = op.join(OUTPUT_DIR, "DLIB_295")
    DRAGON_EXE = op.abspath(op.join(CWD, os.pardir, "bin/Linux_x86_64/Dragon"))
    DRAGON_INPUT_FILE_NAME = INPUT + ".x2m"
    DRAGON_INPUT_FILE = op.join(CWD, DRAGON_INPUT_FILE_NAME)
    DRAGON_INPUT_FILE_COPY = op.join(OUTPUT_DIR, DRAGON_INPUT_FILE_NAME)
    DRAGON_OUTPUT_FILE = op.join(OUTPUT_DIR, INPUT + ".result")
    CONFIG_FILE = op.join(OUTPUT_DIR, "config.json")


execute(config=ConfigPinA, background=True).wait()


class ConfigPinB(object):
    INPUT = "CGN_PIN_B"
    CWD = os.getcwd()
    OUTPUT_DIR = op.join(CWD, "output" + "_" + INPUT + "_" + datetime.now().strftime("%Y-%m-%d_%H-%M-%S"))
    LIB_DIR = op.join(CWD, os.pardir, os.pardir, os.pardir, "libraries/l_endian")
    LIB_FILE = op.abspath(op.join(LIB_DIR, "draglibJeff3p1p1SHEM295"))
    LIB_SYMLINK = op.join(OUTPUT_DIR, "DLIB_295")
    DRAGON_EXE = op.abspath(op.join(CWD, os.pardir, "bin/Linux_x86_64/Dragon"))
    DRAGON_INPUT_FILE_NAME = INPUT + ".x2m"
    DRAGON_INPUT_FILE = op.join(CWD, DRAGON_INPUT_FILE_NAME)
    DRAGON_INPUT_FILE_COPY = op.join(OUTPUT_DIR, DRAGON_INPUT_FILE_NAME)
    DRAGON_OUTPUT_FILE = op.join(OUTPUT_DIR, INPUT + ".result")
    CONFIG_FILE = op.join(OUTPUT_DIR, "config.json")

    
execute(config=ConfigPinB, background=True).wait()


class ConfigPinC(object):
    INPUT = "CGN_PIN_C"
    CWD = os.getcwd()
    OUTPUT_DIR = op.join(CWD, "output" + "_" + INPUT + "_" + datetime.now().strftime("%Y-%m-%d_%H-%M-%S"))
    LIB_DIR = op.join(CWD, os.pardir, os.pardir, os.pardir, "libraries/l_endian")
    LIB_FILE = op.abspath(op.join(LIB_DIR, "draglibJeff3p1p1SHEM295"))
    LIB_SYMLINK = op.join(OUTPUT_DIR, "DLIB_295")
    DRAGON_EXE = op.abspath(op.join(CWD, os.pardir, "bin/Linux_x86_64/Dragon"))
    DRAGON_INPUT_FILE_NAME = INPUT + ".x2m"
    DRAGON_INPUT_FILE = op.join(CWD, DRAGON_INPUT_FILE_NAME)
    DRAGON_INPUT_FILE_COPY = op.join(OUTPUT_DIR, DRAGON_INPUT_FILE_NAME)
    DRAGON_OUTPUT_FILE = op.join(OUTPUT_DIR, INPUT + ".result")
    CONFIG_FILE = op.join(OUTPUT_DIR, "config.json")


execute(config=ConfigPinC, background=True).wait()
