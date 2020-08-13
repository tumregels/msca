import os
import pathlib
import re

import jinja2
import pandas as pd


def parse_mix_map(filename, debug=False):
    s = pathlib.Path(filename).read_text()

    pat = re.compile(r'''
    \s+:::\s+(?P<name>(?:La|C|T|G).*?)\s+ # get names e.g. C0202 Lame_C TI
    :=\s+GEO:\s+
    (?P<parent>.*?)                     # get parent name
    MIX\s+(?P<mix>.*?);                 # get mixture numbers
    ''', flags=re.MULTILINE | re.DOTALL | re.X)

    if debug:
        for i in pat.finditer(s):
            print(i.groupdict())

    return [i.groupdict() for i in pat.finditer(s)]


def clean_mix_map(data, debug=False):
    for item in data:
        if item['name'].startswith('L'):
            item['mix'] = item['mix'].strip()
        if item['name'].startswith('C'):
            item['mix'] = re.findall('(\d+\s+\d+\s+\d+\s+\d+)', item['mix'])[0]
        if item['name'].startswith('G'):
            item['mix'] = re.findall('(\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+)', item['mix'])[0]
        if item['name'].startswith('T'):
            item['mix'] = item['mix'].replace('\n', '').replace('1', '').strip().split()[0]

        if debug:
            print(f"{item['name']: <7} {item['parent'][:6].strip(): <7} {item['mix']: <7}")
    return data


def get_name_mix_dict(filename, debug=False):
    data = parse_mix_map(filename)
    data = clean_mix_map(data)
    dict_ = {}
    for item in data:
        dict_[item['name']] = item['mix']

    if debug:
        print(pd.DataFrame(dict_.items(), columns=['name', 'mix']).to_string())
    return dict_


def export_map_to_matlab_struct(filename, data):
    s = """\
{{ name }} = struct( ...
{%- for i in data %}
    '{{ i['name'] }}', [ {{ i['mix'] }} ]{{ "," if not loop.last }} ...
{%- endfor %}
    );
"""

    template = jinja2.Template(s)
    output = template.render(data=data, name=str(filename.stem))
    (filename.parent / 'map').mkdir(parents=True, exist_ok=True)
    save_filename = filename.parent / 'map' / (str(filename.stem) + '.map')
    with open(save_filename, 'w') as f:
        output = '\n'.join([line.rstrip(' ') for line in output.splitlines()])
        f.write(output)


def main():
    for p in pathlib.Path('Dragon').glob('ASS*/Geo_??.c2m'):
        print(p)
        data = parse_mix_map(p, debug=True)
        data = clean_mix_map(data, debug=True)
        export_map_to_matlab_struct(p, data)
        get_name_mix_dict(p, debug=True)


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).resolve().parent.parent.parent)
    main()
