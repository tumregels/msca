# MScA project

## Requirements

Major requirement is to install [miniconda for python3](https://docs.conda.io/en/latest/miniconda.html)

Now create conda virtual environment which will setup octave and specific python libraries.

    $ make create-environment
    $ source activate msca
    (msca) $

## Processing isotopic densities
   
To process isotopic densities MATLAB was used.
The matlab source code is written using MATLAB Version: 8.4 (R2014b).
The instructions below are provided for MATLAB.

To process isotopic densities

    $ make process_iso_dens
    
To generate keff plots

    $ make plot-burnup-vs-keff

To plot pin and assembly data use

    $ make plot-iso-pin-data
    $ make plot-iso-assbly-data
    
To plot ring errors in assembly calculations

    $ make plot-iso-assbly-rings
    
## Processing fission and capture rates

To process fission and capture reaction rates

    $ make process-fc-rates

To plot fission/capture rates

    (msca) $ make plot-fc-data
