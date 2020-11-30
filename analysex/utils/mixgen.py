"""mixture generator

This script parses Mix_UOX.c2m and MultiBEQ.c2m procedure files to extract mixture numbers.
Then uses those numbers to generate Mix_UOX77.c2m and MultiBEQ77.c2m
mixture procedures using the isotopic densities from isotope_dens_*.csv file.
"""

import csv
import pathlib
import re
from typing import List, Optional, Dict

from jinja2 import Template


def extract_mix_numbers(filename: str) -> Optional[List[int]]:
    s = pathlib.Path(filename).read_text()
    pat = re.compile(r'''
    (?P<mix>\bMIX\s*\d+)\s+.*?\n
    ''', flags=re.MULTILINE | re.DOTALL | re.X)

    m = pat.search(s)
    if m:
        mixtures = pat.findall(s)
        mixtures = [int(mix.split()[-1]) for mix in mixtures]
        return sorted(mixtures)
    else:
        raise Exception('Not found')


def load_csv(filename: str) -> Dict[int, Dict[str, float]]:
    data = {}
    with open(filename) as f:
        reader = csv.reader(f)
        next(reader)
        for row in reader:
            mixture_number = int(row[0])
            iso_name = row[1].split()[0]
            iso_dens = float(row[2])

            if mixture_number not in data:
                data[mixture_number] = {}

            data[mixture_number][iso_name] = iso_dens
    return data


def get_irset(isotope_name, mix):
    if isotope_name in ['Zr90', 'Zr91', 'Zr92'] and mix in [2, 8, 25]:
        irset = '2 IRSET PT 1'
    elif isotope_name in ['U235', 'U238', 'Pu238', 'Pu239', 'Pu240', 'Pu241', 'Pu242']:
        irset = '1 IRSET PT 1'
    elif isotope_name in ['U235Gd', 'U238Gd', 'Pu238Gd', 'Pu239Gd', 'Pu240Gd', 'Pu241Gd', 'Pu242Gd']:
        irset = '3 IRSET PT 1'
    elif isotope_name in ['Gd154', 'Gd155', 'Gd156', 'Gd157', 'Gd158']:
        irset = '3 IRSET PT NONE'
    else:
        irset = ''

    return irset


def get_noev(mix_number):
    noev = 'NOEV' if mix_number in [1, 2, 7, 8, 25] else ''
    return noev


def get_temp(mix_number):
    temperature = '600.0' if mix_number in [1, 2, 7, 8, 25] else '900.0'
    return temperature


def get_iso_name(iso_name, mix):
    if iso_name == 'H1' and mix == 1:
        iso_name = 'H1_H2O'
    elif iso_name.endswith('Gd'):
        iso_name = iso_name.replace('Gd', '')
    elif iso_name.endswith('Gd2'):
        iso_name = iso_name.replace('Gd2', '')
    return iso_name


def create_multlibeq_procedure(
        mix_numbers: List[int],
        nmix: int,
        mix_data: Dict[int, Dict[str, float]],
        file_name: str,
) -> None:
    data = """\
*DECK MultLIBEQ
*----
*  Name          : MultLIBEQ.c2m
*  Type          : DRAGON procedure
*  Use           : Increase the number of mixes in the microlib
*  Author        : A. Canbakan
*
*  Procedure called as:
*
*  LIBEQ := MultLIBEQ_32 LIBEQ ;
*
*  Input data   :
*    LIBEQ      : Microlib with the number of mixs of the 1st level
*
*  Output data  :
*    LIBEQ      : Microlib with the number of mixs of the 2nd level


PARAMETER  LIBEQ  ::
       EDIT 0
           ::: LINKED_LIST LIBEQ  ;
   ;
*
MODULE LIB: END: ;

LIBEQ := LIB: LIBEQ ::
  EDIT 0
  NMIX {{ nmix }}
  DEPL LIB: DRAGON FIL: LIBEQ
  MIXS LIB: MICROLIB FIL: LIBEQ
  
{%- for m in mix_numbers %}   

MIX {{ m }} {{ get_temp(m) }} {{ get_noev(m) }}
{%- for k, v in mix_data[m].items() %}
    {{ '{:7s}'.format(k) }} = {{ '{:7s}'.format(get_iso_name(k, m)) }}  {{ '{:.5E}'.format(v) }}  {{ get_irset(k, m) }}
{%- endfor %}

{%- endfor %}

;

END: ;
QUIT .
"""
    template = Template(data)
    template.globals['get_irset'] = get_irset
    template.globals['get_noev'] = get_noev
    template.globals['get_temp'] = get_temp
    template.globals['get_iso_name'] = get_iso_name
    output = template.render(
        nmix=nmix,
        mix_numbers=mix_numbers,
        mix_data=mix_data
    )
    print(output)
    with open(file_name, 'w') as f:
        output = '\n'.join([line.rstrip(' ') for line in output.splitlines()])
        f.write(output)


def create_mix_uox_procedure(
        mix_numbers: List[int],
        nmix: int,
        mix_data: Dict[int, Dict[str, float]],
        file_name: str,
):
    data = """\
*DECK Mix_UOX
*----
*  Name          : Mix_UOX.c2m
*  Type          : DRAGON procedure
*  Use           : Microlib generation with Draglibs for
*                  UOX calculation with {{ mix_numbers | length }} fuel regions
*  Author        : A. Canbakan
*
*  Procedure called as:
*
*  LIBRARY := Mix_UOX :: <<Library>> ;
*
*  Output data  :
*    LIBRARY    : Microlib with table of probabilities


PARAMETER  LIBRARY  ::
       EDIT 0
           ::: LINKED_LIST LIBRARY  ;
   ;

*----
*  Input data recovery
*----
STRING Library ;
:: >>Library<< ;

*----
*  Modules used in this procedure
*----
MODULE  LIB: UTL: DELETE: END: ABORT: ;

LIBRARY := LIB: ::
  EDIT 1
  DEPL LIB: DRAGON FIL: <<Library>>
  NMIX {{ nmix }} CTRA APOL ANIS 2
  PT
  MIXS LIB: DRAGON FIL: <<Library>>

{%- for m in mix_numbers %}   

MIX {{ m }} {{ get_temp(m) }} {{ get_noev(m) }}
{%- for k, v in mix_data[m].items() %}
    {{ '{:7s}'.format(k) }} = {{ '{:7s}'.format(get_iso_name(k, m)) }}  {{ '{:.5E}'.format(v) }}  {{ get_irset(k, m) }}
{%- endfor %}

{%- endfor %}

;

END: ;
QUIT .

"""
    template = Template(data)
    template.globals['get_irset'] = get_irset
    template.globals['get_noev'] = get_noev
    template.globals['get_temp'] = get_temp
    template.globals['get_iso_name'] = get_iso_name
    output = template.render(
        nmix=nmix,
        mix_numbers=mix_numbers,
        mix_data=mix_data
    )
    print(output)
    with open(file_name, 'w') as f:
        output = '\n'.join([line.rstrip(' ') for line in output.splitlines()])
        f.write(output)


def create_mix_gad_procedure(
        mix_numbers: List[int],
        nmix: int,
        mix_data: Dict[int, Dict[str, float]],
        file_name: str,
):
    data = """\
*DECK Mix_Gad
*----
*  Name          : Mix_Gad.c2m
*  Type          : DRAGON procedure
*  Use           : Microlib generation with Draglibs for
*                  UOX/GD calculation with {{ mix_numbers | length }} fuel regions
*  Author        : A. Canbakan
*
*  Procedure called as:
*
*  LIBRARY := Mix_Gad :: <<Library>> ;
*
*  Output data  :
*    LIBRARY    : Microlib with table of probabilities


PARAMETER  LIBRARY  ::
       EDIT 0
           ::: LINKED_LIST LIBRARY  ;
   ;

*----
*  Input data recovery
*----
STRING Library ;
:: >>Library<< ;

*----
*  Modules used in this procedure
*----
MODULE  LIB: UTL: DELETE: END: ABORT: ;

LIBRARY := LIB: ::
  EDIT 1
  DEPL LIB: DRAGON FIL: <<Library>>
  NMIX {{ nmix }} CTRA APOL ANIS 2
  PT
  MIXS LIB: DRAGON FIL: <<Library>>

{%- for m in mix_numbers %}   

MIX {{ m }} {{ get_temp(m) }} {{ get_noev(m) }}
{%- for k, v in mix_data[m].items() %}
    {{ '{:7s}'.format(k) }} = {{ '{:7s}'.format(get_iso_name(k, m)) }}  {{ '{:.5E}'.format(v) }}  {{ get_irset(k, m) }}
{%- endfor %}

{%- endfor %}

;

END: ;
QUIT .

"""
    template = Template(data)
    template.globals['get_irset'] = get_irset
    template.globals['get_noev'] = get_noev
    template.globals['get_temp'] = get_temp
    template.globals['get_iso_name'] = get_iso_name
    output = template.render(
        nmix=nmix,
        mix_numbers=mix_numbers,
        mix_data=mix_data
    )
    print(output)
    with open(file_name, 'w') as f:
        output = '\n'.join([line.rstrip(' ') for line in output.splitlines()])
        f.write(output)


def create_multlibeq_for_full_lib(
        mix_numbers: List[int],
        nmix: int,
        file_name: str,
):
    data = """\
*DECK MultLIBEQ
*----
*  Name          : MultLIBEQ.c2m
*  Type          : DRAGON procedure
*  Use           : Increase the number of mixes in the microlib
*  Author        : A. Canbakan
*
*  Procedure called as:
*
*  LIBEQ := MultLIBEQ_32 LIBEQ ;
*
*  Input data   :
*    LIBEQ      : Microlib with the number of mixs of the 1st level
*
*  Output data  :
*    LIBEQ      : Microlib with the number of mixs of the 2nd level


PARAMETER  LIBEQ  ::
       EDIT 0
           ::: LINKED_LIST LIBEQ  ;
   ;
*
MODULE LIB: END: ;

LIBEQ := LIB: LIBEQ ::
  EDIT 0
  NMIX {{ nmix }}
  DEPL LIB: DRAGON FIL: LIBEQ
  MIXS LIB: MICROLIB FIL: LIBEQ

{%- for m in mix_numbers %}   

MIX {{ m }}
    COMB {{ m }} 1.0
{%- endfor %}

;

END: ;
QUIT .

"""
    template = Template(data)
    output = template.render(
        nmix=nmix,
        mix_numbers=mix_numbers,
    )
    print(output)
    with open(file_name, 'w') as f:
        f.write(output)


def assbly_a():
    mix_input_file = p / 'Dragon/ASSBLY_A/output_2020-08-09_13-00-41/Mix_UOX.c2m'
    mix_multlibeq_input_file = p / 'Dragon/ASSBLY_A/output_2020-07-27_10-34-53/MultLIBEQ.c2m'
    nmix = 161

    # first
    mix_data_first = load_csv(p / 'data/isotope_dens_case_a_first_cut.csv')
    mix_uox_numbers = extract_mix_numbers(mix_input_file)
    mix_multlibeq_numbers = extract_mix_numbers(mix_multlibeq_input_file)
    mix_numbers = sorted(list(set(mix_uox_numbers + mix_multlibeq_numbers)))
    create_mix_uox_procedure(mix_uox_numbers, nmix, mix_data_first, p / 'data/A_Mix_UOX_first.c2m')
    create_mix_uox_procedure(mix_numbers, nmix, mix_data_first, p / 'data/A_Mix_UOX_first_full.c2m')
    # create_multlibeq_for_full_lib(mix_multlibeq_numbers, nmix, p / 'data/A_MultLIBEQ_first_full.c2m')
    # create_multlibeq_procedure(mix_multlibeq_numbers, nmix, mix_data_first, p / 'data/A_MultLIBEQ_first.c2m')

    # last
    mix_data_last = load_csv(p / 'data/isotope_dens_case_a_last_cut.csv')
    mix_uox_numbers = extract_mix_numbers(mix_input_file)
    mix_multlibeq_numbers = extract_mix_numbers(mix_multlibeq_input_file)
    mix_numbers = sorted(list(set(mix_uox_numbers + mix_multlibeq_numbers)))
    create_mix_uox_procedure(mix_uox_numbers, nmix, mix_data_last, p / 'data/A_Mix_UOX_last.c2m')
    create_mix_uox_procedure(mix_numbers, nmix, mix_data_last, p / 'data/A_Mix_UOX_last_full.c2m')
    # create_multlibeq_for_full_lib(mix_multlibeq_numbers, nmix, p / 'data/A_MultLIBEQ_last_full.c2m')
    # create_multlibeq_procedure(mix_multlibeq_numbers, nmix, mix_data_last, p / 'data/A_MultLIBEQ_last.c2m')


def assbly_b():
    mix_input_file = p / 'Dragon/ASSBLY_B/output_2020-07-26_22-37-17/Mix_Gad.c2m'
    mix_multlibeq_input_file = p / 'Dragon/ASSBLY_B/output_2020-07-26_22-37-17/MultLIBEQ.c2m'
    nmix = 163

    # first
    mix_data_first = load_csv(p / 'data/isotope_dens_case_b_first_cut.csv')
    mix_uox_numbers = extract_mix_numbers(mix_input_file)
    mix_multlibeq_numbers = extract_mix_numbers(mix_multlibeq_input_file)
    mix_numbers = sorted(list(set(mix_uox_numbers + mix_multlibeq_numbers)))
    create_mix_gad_procedure(mix_uox_numbers, nmix, mix_data_first, p / 'data/B_Mix_Gad_first.c2m')
    create_mix_gad_procedure(mix_numbers, nmix, mix_data_first, p / 'data/B_Mix_Gad_first_full.c2m')

    # last
    mix_data_last = load_csv(p / 'data/isotope_dens_case_b_last_cut.csv')
    mix_uox_numbers = extract_mix_numbers(mix_input_file)
    mix_multlibeq_numbers = extract_mix_numbers(mix_multlibeq_input_file)
    mix_numbers = sorted(list(set(mix_uox_numbers + mix_multlibeq_numbers)))
    create_mix_gad_procedure(mix_uox_numbers, nmix, mix_data_last, p / 'data/B_Mix_Gad_last.c2m')
    create_mix_gad_procedure(mix_numbers, nmix, mix_data_last, p / 'data/B_Mix_Gad_last_full.c2m')


def assbly_c():
    mix_input_file = p / 'Dragon/ASSBLY_C/output_2020-07-26_22-40-10/Mix_Gad.c2m'
    mix_multlibeq_input_file = p / 'Dragon/ASSBLY_C/output_2020-07-26_22-40-10/MultLIBEQ.c2m'
    nmix = 165

    # first
    mix_data_first = load_csv(p / 'data/isotope_dens_case_c_first_cut.csv')
    mix_uox_numbers = extract_mix_numbers(mix_input_file)
    mix_multlibeq_numbers = extract_mix_numbers(mix_multlibeq_input_file)
    mix_numbers = sorted(list(set(mix_uox_numbers + mix_multlibeq_numbers)))
    create_mix_gad_procedure(mix_uox_numbers, nmix, mix_data_first, p / 'data/C_Mix_Gad_first.c2m')
    create_mix_gad_procedure(mix_numbers, nmix, mix_data_first, p / 'data/C_Mix_Gad_first_full.c2m')

    # last
    mix_data_last = load_csv(p / 'data/isotope_dens_case_c_last_cut.csv')
    mix_uox_numbers = extract_mix_numbers(mix_input_file)
    mix_multlibeq_numbers = extract_mix_numbers(mix_multlibeq_input_file)
    mix_numbers = sorted(list(set(mix_uox_numbers + mix_multlibeq_numbers)))
    create_mix_gad_procedure(mix_uox_numbers, nmix, mix_data_last, p / 'data/C_Mix_Gad_last.c2m')
    create_mix_gad_procedure(mix_numbers, nmix, mix_data_last, p / 'data/C_Mix_Gad_last_full.c2m')


def assbly_d():
    mix_input_file = p / 'Dragon/ASSBLY_D/output_2020-07-26_22-41-20/Mix_Gad.c2m'
    mix_multlibeq_input_file = p / 'Dragon/ASSBLY_D/output_2020-07-26_22-41-20/MultLIBEQ.c2m'
    nmix = 171

    # first
    mix_data_first = load_csv(p / 'data/isotope_dens_case_d_first_cut.csv')
    mix_uox_numbers = extract_mix_numbers(mix_input_file)
    mix_multlibeq_numbers = extract_mix_numbers(mix_multlibeq_input_file)
    mix_numbers = sorted(list(set(mix_uox_numbers + mix_multlibeq_numbers)))
    create_mix_gad_procedure(mix_uox_numbers, nmix, mix_data_first, p / 'data/D_Mix_Gad_first.c2m')
    create_mix_gad_procedure(mix_numbers, nmix, mix_data_first, p / 'data/D_Mix_Gad_first_full.c2m')

    # last
    mix_data_last = load_csv(p / 'data/isotope_dens_case_d_last_cut.csv')
    mix_uox_numbers = extract_mix_numbers(mix_input_file)
    mix_multlibeq_numbers = extract_mix_numbers(mix_multlibeq_input_file)
    mix_numbers = sorted(list(set(mix_uox_numbers + mix_multlibeq_numbers)))
    create_mix_gad_procedure(mix_uox_numbers, nmix, mix_data_last, p / 'data/D_Mix_Gad_last.c2m')
    create_mix_gad_procedure(mix_numbers, nmix, mix_data_last, p / 'data/D_Mix_Gad_last_full.c2m')


if __name__ == '__main__':
    p = pathlib.Path(__file__).resolve().parent.parent.parent
    assbly_a()
    assbly_b()
    assbly_c()
    assbly_d()
