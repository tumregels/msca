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
    DRAGON_OUTPUT_FILE = op.join(OUTPUT_DIR, INPUT + ".result")
    
    
execute(config=ConfigShortA, background=True)# .wait()


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
    DRAGON_OUTPUT_FILE = op.join(OUTPUT_DIR, INPUT + ".result")


#execute(config=ConfigPinA, background=True).wait()


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
    DRAGON_OUTPUT_FILE = op.join(OUTPUT_DIR, INPUT + ".result")

    
#execute(config=ConfigPinB, background=True).wait()


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
    DRAGON_OUTPUT_FILE = op.join(OUTPUT_DIR, INPUT + ".result")


#execute(config=ConfigPinC, background=True).wait()


class ConfigAssembly(object):
    INPUT = "UOX_TBH_eighth_1level"
    CWD = os.getcwd()
    OUTPUT_DIR = op.join(CWD, "output" + "_" + INPUT + "_" + datetime.now().strftime("%Y-%m-%d_%H-%M-%S"))
    LIB_DIR = op.join(CWD, os.pardir, os.pardir, os.pardir, "libraries/l_endian")
    LIB_FILE = op.abspath(op.join(LIB_DIR, "draglibJeff3p1p1SHEM295"))
    LIB_SYMLINK = op.join(OUTPUT_DIR, "DLIB_295")
    DRAGON_EXE = op.abspath(op.join(CWD, os.pardir, "bin/Linux_x86_64/Dragon"))
    DRAGON_INPUT_FILE_NAME = INPUT + ".x2m"
    DRAGON_INPUT_FILE = op.join(CWD, 'level1', DRAGON_INPUT_FILE_NAME)
    DRAGON_INPUT_SUPPORT_FILES = ['level1/Geo_SS_32.c2m', 'level1/MultLIBEQ_32.c2m', 
                                  'level1/Mix_UOX_32.c2m', 'level1/UOX_TBH.dat', 'assertS.c2m']
    DRAGON_OUTPUT_FILE = op.join(OUTPUT_DIR, INPUT + ".result")
    
#execute(config=ConfigAssembly, background=True)# .wait()