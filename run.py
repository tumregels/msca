#!/home/legha/bin/miniconda3/envs/jupyter/bin/python3
import os
import os.path as op
import sys
import os
import stat
from subprocess import Popen, PIPE, CalledProcessError
import shutil
import glob


class Config(object):
    CWD = os.getcwd()
    OUTPUT_DIR = op.join(CWD, "output")
    LIB_DIR = op.abspath(
        op.join(CWD, os.pardir, os.pardir, os.pardir, "libraries/l_endian")
    )
    LIB_FILE = op.join(LIB_DIR, "draglibJeff3p1p1SHEM295")
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
assert os.path.isfile(Config.LIB_FILE) == True, "draglibJeff3p1p1SHEM295 is missing"
assert os.path.isfile(Config.LIB_SYMLINK) == True, "DLIB_295 symlink is missing"
assert os.path.isfile(Config.DRAGON_INPUT_FILE) == True, "Dragon input file is missing"
assert os.path.isfile(Config.DRAGON_EXE) == True, "Dragon exe is missing"

# start calculation similar to $ dragon_exe < dragon_input.x2m 2>&1 | tee dragon_output.result
# https://stackoverflow.com/a/28319191, https://stackoverflow.com/a/163556
with open(Config.DRAGON_INPUT_FILE) as inp, open(
    Config.DRAGON_OUTPUT_FILE, "w"
) as out, Popen(
    Config.DRAGON_EXE,
    stdout=PIPE,
    stdin=PIPE,
    bufsize=1,
    universal_newlines=True,
    cwd=Config.OUTPUT_DIR,
    encoding="utf8",
) as p:
    p.stdin.write(inp.read())
    for line in p.stdout:
        out.write(line)
        print(line, end="")
        sys.stdout.flush()

if p.returncode != 0:
    raise CalledProcessError(p.returncode, p.args)
