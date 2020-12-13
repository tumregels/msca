# MScA project

Download the source code and simulation results from [here](https://github.com/tumregels/msca/releases/latest)
and follow the instructions to unzip the data.

## Requirements

Major requirement is to install [miniconda for python3](https://docs.conda.io/en/latest/miniconda.html)

Now create conda virtual environment which will setup octave and specific python libraries.

    $ make create-environment
    $ source activate msca
    (msca) $

Matlab source code was written using Matlab Version: 8.4 (R2014b) on Ubuntu 18.04 and
formatted with [MBeautifier](https://github.com/davidvarga/MBeautifier)

## Process and plot simulation results

Isotopic density and fission/capture rate parsers have been validated with both Octave and Matlab.

To run fission/capture rate parser with Octave use

    (msca) $ make process-fc-rates-octave
    
To run isotopic density parser with Octave use

    (msca) $ make process-iso-dens-octave

The instructions below require Matlab (R2014b) or higher.

To process isotopic densities (faster than in Octave)

    $ make process-iso-dens
    
To generate keff plots

    $ make plot-burnup-vs-keff

To plot pin and assembly data use

    $ make plot-iso-pin-data
    $ make plot-iso-assbly-data
    
To plot ring errors in assembly calculations

    $ make plot-iso-assbly-rings

To process fission and capture reaction rates (faster than in Octave)

    $ make process-fc-rates

To plot fission/capture rates

    (msca) $ make plot-fc-data

## Rerun simulations

To rerun PIN_A calculation with DRAGON5
adjust `LIB_DIR`, `LIB_FILE` and `DRAGON_EXE` parameters inside `scripts/run_dragon.py` and call

    (msca) $ make run_dragon_pin_a
    
To rerun PIN_A calculations with SERPENT2
adjust `XS_LIB_DIR`, `XS_ACELIB_FILE`, `XS_DECLIB_FILE`, `XS_NFYLIB_FILE` and `SERPENT_EXE` parameters inside
`scripts/run_serpent.py` and call

    (msca) $ make run_serpent_pin_a
    
For the other cases use one of the following commands

    (msca) $ make run-dragon-pin-b          # run PIN_B simulation with DRAGON5
    (msca) $ make run-serpent-pin-b         # run PIN_B simulation with SERPENT2
    (msca) $ make run-dragon-pin-c          # run PIN_C simulation with DRAGON5
    (msca) $ make run-serpent-pin-c         # run PIN_C simulation with SERPENT2
    (msca) $ make run-dragon-assbly-a-1l    # run ASSBLY_A 1L simulation with DRAGON5
    (msca) $ make run-dragon-assbly-a-2l    # run ASSBLY_A 2L simulation with DRAGON5
    (msca) $ make run-serpent-assbly-a      # run ASSBLY_A simulation with SERPENT2
    (msca) $ make run-dragon-assbly-b-1l    # run ASSBLY_B 1L simulation with DRAGON5
    (msca) $ make run-dragon-assbly-b-2l    # run ASSBLY_B 2L simulation with DRAGON5
    (msca) $ make run-serpent-assbly-b      # run ASSBLY_B simulation with SERPENT2
    (msca) $ make run-dragon-assbly-c-1l    # run ASSBLY_C 1L simulation with DRAGON5
    (msca) $ make run-dragon-assbly-c-2l    # run ASSBLY_C 2L simulation with DRAGON5
    (msca) $ make run-serpent-assbly-c      # run ASSBLY_C simulation with SERPENT2
    (msca) $ make run-dragon-assbly-d-1l    # run ASSBLY_D 1L simulation with DRAGON5
    (msca) $ make run-dragon-assbly-d-2l    # run ASSBLY_D 2L simulation with DRAGON5
    (msca) $ make run-serpent-assbly-d      # run ASSBLY_D simulation with SERPENT2

