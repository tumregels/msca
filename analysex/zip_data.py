import os
import pathlib
from os import PathLike
from typing import Union
from zipfile import ZIP_DEFLATED, ZipFile


def zip_dir(zip_name: str, zip_mode: str, source_dir: Union[str, PathLike]):
    src_path = pathlib.Path(source_dir).expanduser().resolve(strict=True)
    with ZipFile(zip_name, zip_mode, ZIP_DEFLATED) as zf:
        if src_path.is_file():
            zf.write(src_path, src_path.relative_to(src_path.cwd()))
        else:
            for file in src_path.rglob('*'):
                if file.is_symlink():
                    continue
                zf.write(file, file.relative_to(src_path.cwd()))


# def convert_to_html(nb_name) -> None:
#    jupyter_path = pathlib.Path(sys.executable).parent.joinpath('jupyter')
#    get_ipython().system(f'{jupyter_path} nbconvert --to html {nb_name}')

# convert_to_html(nb_name)

# def convert_to_py(nb_name) -> None:
#     jupyter_path = pathlib.Path(sys.executable).parent.joinpath('jupyter')
#     get_ipython().system(f'{jupyter_path} nbconvert {nb_name}  --to python')

# convert_to_py('analyse_pins.ipynb')


if __name__ == '__main__':
    os.chdir(pathlib.Path(__file__).parent.parent)

    nb_name = 'analyse_pins.ipynb'
    zip_name = nb_name.replace('.ipynb', '.zip')

    zip_dir(zip_name, 'w', nb_name)
    zip_dir(zip_name, 'a', nb_name.replace('.ipynb', '.html'))

    drag_output_files = [
        'Dragon/PIN_A/output_2020-05-01_23-02-16/CGN_PIN_A.result',
        'Dragon/PIN_B/output_2020-05-02_00-15-18/CGN_PIN_B.result',
        'Dragon/PIN_C/output_2020-05-02_00-16-03/CGN_PIN_C.result',

    ]

    serp_output_files = [
        'Serpent/PIN_A/output_2020-05-11_22-39-35/PIN_CASEA_mc_res.m',
        'Serpent/PIN_B/output_2020-05-11_22-39-42/PIN_CASEB_mc_res.m',
        'Serpent/PIN_C/output_2020-05-11_22-39-48/PIN_CASEC_mc_res.m',
    ]

    for dir_ in drag_output_files:
        zip_dir(zip_name, 'a', pathlib.Path(dir_).parent)
    for dir_ in serp_output_files:
        zip_dir(zip_name, 'a', pathlib.Path(dir_).parent)
