import os
import pathlib
import re
import sys


def parse_mat_names(filename):
    s = pathlib.Path(filename).read_text()

    pattern = re.compile(r"""
    mat\s*([A-Z0-9_]*?)\s*sum
    """, flags=re.MULTILINE | re.DOTALL | re.X)

    match = pattern.search(s)

    if match:
        data = {}
        for match in pattern.finditer(s):
            # print('   dm ' + m.group(1))
            if match.group(1)[:-2] in data:
                data[match.group(1)[:-2]].append(match.group(1))
            else:
                data[match.group(1)[:-2]] = [match.group(1)]
    else:
        raise Exception('No match found')

    print("---------------")
    for key in data:
        print("   ", end="")
        for det in data[key]:
            print(f"dm {det}", end=" ")
        print()
    print("---------------")
    for key in data:
        for det in data[key]:
            print(f"   {det} -1")
    print("---------------")


def parse_det_names(filename):
    s = pathlib.Path(filename).read_text()

    pattern = re.compile("""
    ^det\s+([A-Z0-9_]*?)\s+de\s+([A-Z0-9_]*?)\s+dm\s+(.*?)$
    """, flags=re.MULTILINE | re.DOTALL | re.X)

    match = pattern.search(s)

    if match:
        data = {}
        for match in pattern.finditer(s):
            # print('   dm ' + m.group(1))
            if match.group(1)[:-2] in data:
                data[match.group(1)[:-2]].append(match.group(3))
            else:
                data[match.group(1)[:-2]] = [match.group(3)]
        return data
    else:
        raise Exception('No match found')


def create_detectors(data):
    materials = ""
    for k, v in data.items():
        materials += f"    {' '.join([f'dm {m}' for m in v])}\n"

    print("""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FUEL POWER 2 GROUPS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- energy grid for the detectors (2g)
ene 2 1 1.1E-11 6.25E-7 1.9640E+1
""".rstrip())
    for k, v in data.items():
        print(f"""
det {k + '_2G'}
    de 2
    dt -4
    {' '.join([f'dm {m}' for m in v])}
    dr 102 U235
    dr 102 U238
    dr -6 U235
    dr -6 U238
""".rstrip())

    print(f"""
det _FUEL_2G
    de 2
    dr 102 U235
    dr 102 U238
    dr -6 U235
    dr -6 U238
{materials}
""".rstrip())

    print("""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FUEL POWER 1 GROUP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- energy grid for the detectors (1g)
ene 3 1 1.1E-11 1.9640E+1
""".rstrip())

    for k, v in data.items():
        print(f"""
det {k + '_1G'}
    de 3
    dt -4
    {' '.join([f'dm {m}' for m in v])}
    dr 102 U235
    dr 102 U238
    dr -6 U235
    dr -6 U238
""".rstrip())

    print(f"""
det _FUEL_1G
    de 3
    dr 102 U235
    dr 102 U238
    dr -6 U235
    dr -6 U238
{materials}
""".rstrip())


def main():
    for serp_input in [
        ('CASEA', 'Serpent/ASSEMBLY_A/ASSBLY_CASEA_mc'),
        ('CASEB', 'Serpent/ASSEMBLY_B/ASSBLY_CASEB_mc'),
        ('CASEC', 'Serpent/ASSEMBLY_C/ASSBLY_CASEC_mc'),
        ('CASED', 'Serpent/ASSEMBLY_D/ASSBLY_CASED_mc'),
    ]:
        p = pathlib.Path(serp_input[1]).resolve().parent
        with open(p / f'DETS_{serp_input[0]}', 'w') as file:
            sys.stdout = file
            data = parse_det_names(serp_input[1])
            create_detectors(data)


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).resolve().parent.parent)
    main()
