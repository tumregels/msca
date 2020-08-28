# Dragon

- [x] check isotopes
- [x] create short calculation inputs with 2 burnup steps for assemblies
- [x] check pin materials
- [x] rm U234 from the list
- [x] fix assembly A and D
- [x] check low keff for assembly D
- [ ] rm unused variables i and iNext
- [x] organise CALC rows in x2m files
- [x] fix merg mix mapping
- [x] fix Fuelpwr in ASSBLY inputs, should be 39 W/gU
- [x] pack assembly inputs into standard format
- [x] reread Canbakan paper
- [x] add BURN2 to assembly inputs
- [x] parse Mix_UOX.c2m and MultiBEQ.c2m
- [x] fix fortran scripts for capture
- [x] add CLE-2000 IF statements in the dataset to produce 
      the 3 corresponding BCOND2 files. 
      Continuous data with burnup can be found in the Multicompo.
- [ ] compare densities of a few pins
- [x] convert fortran code to matlab script
- [ ] rename CP to SYS CALC to FLUX in PIN inputs

# Serpent

- [x] prepare initial inputs
- [x] check serp input materials
- [x] fix pin burnup steps
- [ ] plot atomic dens vs burnup for serpent
- [ ] sync burnup steps with Dragon

# Data Analyses

- [x] generate plots for pin dragon/serpent calculations
- [x] create analysex package for data analyses scripts
- [ ] fix MWd/tU to GWd/t

## Questions

- [ ] `2 IRSET PT 1` for `PIN_A` in 3 places for Zn (lines 105, 106, 107), whereas 1 place in ASSEMBLY_A/Mix_UOX.c2m (line 56)
- [ ] lines 56 and 86 in Mix_UOX.c2m (why `3 IRSET PT 1` for fuel and `2 IRSET PT 1` for TI)
- [ ] remove Rtub1 Rtub2 (ask Hebert)
- [ ] `RADIUS 0.0 <<Rtub1>> <<Rtub2>> <<R_int_TI>> <<R_ext_TI>>` in ASSEMBLY_B/Geo_N2.c2m and
      `RADIUS 0.0 <<Rtub1>> <<Rtub2>> <<R_int_TG>> <<R_ext_TG>>` in ASSEMBLY_A/Geo_N2.c2m

- [ ] ask logic behind `DONNEES := UTL: DONNEES :: CREA AUTOP <<maxautop>> = `...
- [x] ask if NMIX value should be adjusted in Mix_Gad.c2m and MultLIBEQ.c2m 

- [ ] got `SYBILF: EXPECTING IFTRAK=0` for `UOX_AIC_eighth_2level_g2s`
- [x] how to convert int to string in cle2000. Answer, use I_TO_S
