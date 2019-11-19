#!/home/legha/bin/miniconda3/envs/jupyter/bin/python3
import os
import os.path as op
import sys
import os
import stat
import subprocess
import shutil
import glob


class Config(object):
    CWD = os.getcwd()
    OUTPUT_DIR = op.join(CWD, "output")
    LIB_DIR = op.join(CWD, os.pardir, os.pardir, os.pardir, "libraries/l_endian")
    LIB_FILE = op.abspath(op.join(LIB_DIR, "draglibJeff3p1p1SHEM295"))
    LIB_SYMLINK = op.join(OUTPUT_DIR, "DLIB_295")
    DRAGON_EXE = op.abspath(op.join(CWD, os.pardir, "bin/Linux_x86_64/Dragon"))
    DRAGON_INPUT_FILE = op.join(CWD, "CGN_PIN_A.x2m")
    DRAGON_OUTPUT_FILE = op.join(OUTPUT_DIR, "CGN_PIN_A.result")


# create output directory if missing
os.makedirs(Config.OUTPUT_DIR, exist_ok=True)

# cleanup previous calculation results
files = glob.glob(os.path.join(Config.OUTPUT_DIR, "*"))
for f in files:
    os.remove(f)

# remove old symlink and create new one
if os.path.isfile(Config.LIB_SYMLINK):
    os.remove(Config.LIB_SYMLINK)

try:
    os.symlink(Config.LIB_FILE, Config.LIB_SYMLINK)
except FileExistsError:
    pass

# check all paths/files exist
assert os.path.isdir(Config.LIB_DIR) == True, "library directory missing"
assert os.path.isfile(Config.LIB_FILE) == True, "library file is missing"
assert os.path.isfile(Config.LIB_SYMLINK) == True, "symlink is missing"
assert os.path.isfile(Config.DRAGON_INPUT_FILE) == True, "dragon input file is missing"
assert os.path.isfile(Config.DRAGON_EXE) == True, "dragon exe is missing"


def execute(background=False):
    """
    this will immitate the following behavior
    
    $ dragon_exe < file.in > file.out
    """
    input_ = open(Config.DRAGON_INPUT_FILE)
    output_ = open(Config.DRAGON_OUTPUT_FILE, 'w')

    if background:
        p = subprocess.Popen(
            Config.DRAGON_EXE, 
            stdin=input_, 
            stdout=output_, 
            cwd=Config.OUTPUT_DIR
        )
        print("process id {}".format(p.pid))
    else:
        p = subprocess.Popen(
            Config.DRAGON_EXE,
            stdout=subprocess.PIPE,
            stdin=input_,
            bufsize=1,
            universal_newlines=True,
            cwd=Config.OUTPUT_DIR
        )
        for line in p.stdout:
            output_.write(line)
            print(line, end="")
            sys.stdout.flush()
            
        p.wait()
        if p.returncode != 0:
            raise subprocess.CalledProcessError(p.returncode, p.args)

        
execute(background=True)