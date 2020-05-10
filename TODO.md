# CGN_ASSEMBLY

- [x] check isotopes
- [ ] prepare input maps for assemblies in excel sheet
- [x] create short calculation inputs with 2 burnup steps for assemblies
- [x] check pin materials
- [x] rm U234 from the list
- [x] fix assembly A and D
- [ ] check low keff for assembly D
- [ ] launch full calculation for all assemblies
- [ ] rm unused variables i and iNext
- [x] organise CALC rows in x2m files

# Serpent

- [ ] prepare initial inputs
- [ ] perform calculations

# Data Analyses

- [ ] generate plots for Dragon calculations
- [ ] plots for serpent
- [ ] plots for both

## Questions

- [ ] `2 IRSET PT 1` for `CGN_PIN_A` in 3 places for Zn (lines 105, 106, 107), whereas 1 place in CGN_ASSEMBLY_A/Mix_UOX.c2m (line 56)
- [ ] lines 56 and 86 in Mix_UOX.c2m (why `3 IRSET PT 1` for fuel and `2 IRSET PT 1` for TI)
- [ ] remove Rtub1 Rtub2 (ask Hebert)
- [ ] `RADIUS 0.0 <<Rtub1>> <<Rtub2>> <<R_int_TI>> <<R_ext_TI>>` in CGN_ASSEMBLY_B/Geo_N2.c2m and
      `RADIUS 0.0 <<Rtub1>> <<Rtub2>> <<R_int_TG>> <<R_ext_TG>>` in CGN_ASSEMBLY_A/Geo_N2.c2m

- [ ] ask logic behind `DONNEES := UTL: DONNEES :: CREA AUTOP <<maxautop>> = `...
- [x] ask if NMIX value should be adjusted in Mix_Gad.c2m and MultLIBEQ.c2m 
