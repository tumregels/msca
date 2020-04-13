## msca/CGN_ASSEMBLY_A/UOX+B_TBH_eighth_2level_g2s.x2m

```fortran
*----
* 295-group/26group eighth assembly in DRAGON
* Author: A. Canbakan
*----
LINKED_LIST GEOSS GEON1 GEON2 TRACKSS TRACKN1 TRACKN2 LIBRARY LIBRARY2
            SYS FLUX FLUX2 EDITION LIBEQ DONNEES LIBHOM BURNUP 
	    EDIHOM RES ;
MODULE SYBILT: G2S: SALT: MCCGT: USS: ASM: FLU: EDI: SPH: UTL: DELETE:
       END: EVO: GREP: LIB: ;
REAL Rcomb1 Rcomb2 Rcomb3 Rcomb4 R_int_TG R_ext_TG R_int_TI R_ext_TI
     R_int_G R_ext_G Cote CoteL RmodeN1 Lame Rtub1 Rtub2 ;
SEQ_ASCII UOX_TBH :: FILE './UOX_TBH_g2s.txt' ;
SEQ_ASCII BCOND2 :: FILE './UOX_R_BCOND2.txt' ;
SEQ_ASCII FIG_UOX :: FILE './FIG_UOX.ps' ;
SEQ_BINARY TF_EXC ;
INTEGER an2d := 8 ;
REAL densur := 20.0 ;
INTEGER istep maxstep istepNext maxautop iAutop := 0 73 0 7 1 ;
REAL delr BUbeg BUend Tbeg Tend := 0.01 0.0 0.0 0.0 0.0 ;
REAL Fuelpwr Keff := 36.8 0.0 ;
REAL BU BUautop  := 0.0 0.0 ;
STRING Library := "DLIB_295" ;
PROCEDURE Geo_SS Geo_N1 Geo_N2 Mix_UOX MultLIBEQ ;
PROCEDURE assertS ;

************************************************************************
*  BEGIN GEOMETRY                                                      *
************************************************************************
EVALUATE Rcomb4 := 0.4083 ;
EVALUATE Rcomb1 := 0.5 SQRT Rcomb4 * ;
EVALUATE Rcomb2 := 0.8 SQRT Rcomb4 * ;
EVALUATE Rcomb3 := 0.95 SQRT Rcomb4 * ;
EVALUATE Rtub1  := 0.1897 ;
EVALUATE Rtub2  := 0.3794 ;
EVALUATE R_int_TG := 0.5691 ;
EVALUATE R_ext_TG := 0.6095 ;
EVALUATE R_int_TI := 0.5691 ;
EVALUATE R_ext_TI := 0.6095 ;
EVALUATE R_int_G := 0.4165 ;
EVALUATE R_ext_G := 0.4775 ;
EVALUATE Cote := 1.26 ;
EVALUATE CoteL := 1.302 ;
EVALUATE Lame := CoteL Cote - ;
EVALUATE RmodeN1 := 0.670 ;

GEOSS := Geo_SS :: <<Rcomb1>> <<Rcomb2>> <<Rcomb3>> <<Rcomb4>>
                      <<R_int_TG>> <<R_ext_TG>> <<R_int_TI>> 
                      <<R_ext_TI>> <<R_int_G>> <<R_ext_G>> <<Cote>>
                      <<CoteL>> ;

GEON1 := Geo_N1 :: <<Rcomb1>> <<Rcomb2>> <<Rcomb3>> <<Rcomb4>>
                      <<R_int_TG>> <<R_ext_TG>> <<R_int_TI>> 
                      <<R_ext_TI>> <<R_int_G>> <<R_ext_G>> <<Cote>>
                      <<CoteL>> <<RmodeN1>> ;

GEON2 := Geo_N2 :: <<Rcomb1>> <<Rcomb2>> <<Rcomb3>> <<Rcomb4>>
                      <<R_int_TG>> <<R_ext_TG>> <<R_int_TI>> 
                      <<R_ext_TI>> <<R_int_G>> <<R_ext_G>> <<Cote>>
                      <<Lame>> <<Rtub1>> <<Rtub2>> ;
UOX_TBH FIG_UOX := G2S: GEON2 ;
************************************************************************
*  END GEOMETRY                                                        *
************************************************************************
 
************************************************************************
*  BEGIN DECLARATION                                                   *
************************************************************************
DONNEES := UTL: ::
    CREA
      BURN <<maxstep>> =
            0.0       9.375    18.75     37.5      75.0     150.0
          237.5     325.0     412.5     500.0     625.0     750.0
         1000.0    1250.0    1500.0    1750.0    2000.0    2500.0
         3000.0    3500.0    4000.0    4500.0    5000.0    5500.0
         6000.0    6500.0    7000.0    7500.0    8000.0    8500.0
         9000.0    9500.0   10000.0   10500.0   11000.0   11500.0
        12000.0   12500.0   13000.0   13500.0   14000.0   14500.0
        15000.0   15500.0   16000.0   16500.0   17000.0   17500.0
        18000.0   18500.0   19000.0   19500.0   20000.0   22000.0
        24000.0   26000.0   28000.0   30000.0   32000.0   34000.0
        36000.0   38000.0   40000.0   42000.0   44000.0   46000.0
	48000.0   50000.0   52000.0   54000.0   56000.0   58000.0
        60000.0
    ;
DONNEES := UTL: DONNEES ::
    CREA
          AUTOP <<maxautop>> =
         4000.0    8000.0   12000.0   24000.0   36000.0   48000.0
        60000.0
    ;
************************************************************************
*  END DECLARATION                                                     *
************************************************************************
************************************************************************
*  BEGIN TRACKING                                                      *
************************************************************************
! Level One
TRACKSS := SYBILT: GEOSS ::
  EDIT 0
  MAXR 500
  MAXZ  1000000
  TITLE 'TRACKING FOR ASSEMBLY SS'
  QUA2 20 3
  DP01  ;
TRACKN1 := SYBILT: GEON1 ::
  EDIT 0
  MAXR 500
  MAXZ  1000000
  TITLE 'TRACKING FOR ASSEMBLY N1'
  QUA2 20 3
  DP01  ;
! Level two
TRACKN2 TF_EXC := SALT: UOX_TBH ::
  EDIT 3
  ALLG
  TSPC EQW2 <<an2d>> <<densur>> REND
;
TRACKN2 := MCCGT: TRACKN2 TF_EXC ::
  CACB 4 AAC 80 TMT EPSI 1E-5 MCU 10000 ;

************************************************************************
*  END TRACKING                                                        *
************************************************************************
************************************************************************
*  BEGIN LIBRARY READING                                               *
************************************************************************
LIBRARY := Mix_UOX :: <<Library>>  ;

************************************************************************
*  END LIBRARY READING                                                 *
************************************************************************
************************************************************************
*  BEGIN DEPLETION                                                     *
************************************************************************
WHILE istep maxstep < DO

************************************************************************
*  BEGIN FIRST LEVEL FLUX CALCULATION                                  *
************************************************************************

 EVALUATE istep := istep 1 + ;
 ECHO "istep: " istep "/" maxstep ;
 
 EVALUATE BUbeg Tbeg := BUend Tend ;
 GREP: DONNEES :: GETVAL 'BURN' <<istep>> >>BUend<< ;
 EVALUATE Tend := BUend Fuelpwr / ;
 ECHO Tbeg ;
 ECHO Tend ;

*----
* USS
*----
  IF istep 1 = THEN
       LIBRARY2 := USS: LIBRARY TRACKSS :: EDIT 1 PASS 2 ARM 
    
          CALC REGI W1 U235 ALL

               REGI W1 U238 3
               REGI W2 U238 4
               REGI W3 U238 5
               REGI W4 U238 6

               REGI W1 U238 9
               REGI W2 U238 10
               REGI W3 U238 11
               REGI W4 U238 12

               REGI W1 U238 13
               REGI W2 U238 14
               REGI W3 U238 15
               REGI W4 U238 16

               REGI W1 U238 17
               REGI W2 U238 16
               REGI W3 U238 19
               REGI W4 U238 20

               REGI W1 U238 21
               REGI W2 U238 22
               REGI W3 U238 23
               REGI W4 U238 24

               REGI W1 U238 26
               REGI W2 U238 27
               REGI W3 U238 28
               REGI W4 U238 29

               REGI W1 U238 30
               REGI W2 U238 31
               REGI W3 U238 32
               REGI W4 U238 33

               REGI W1 U238 34
               REGI W2 U238 35
               REGI W3 U238 36
               REGI W4 U238 37
               
          ENDC ;  
  ELSE
    GREP: DONNEES :: GETVAL "AUTOP" <<iAutop>> >>BUautop<< ;
    GREP: DONNEES :: GETVAL "BURN" <<istep>> >>BU<< ;
        IF BUautop BU = THEN
       LIBRARY2 := USS: LIBRARY LIBRARY2 TRACKSS BURNUP :: EDIT 1 PASS 2 
     
          CALC REGI W1 U235 ALL

               REGI W1 U238 3
               REGI W2 U238 4
               REGI W3 U238 5
               REGI W4 U238 6

               REGI W1 U238 9
               REGI W2 U238 10
               REGI W3 U238 11
               REGI W4 U238 12

               REGI W1 U238 13
               REGI W2 U238 14
               REGI W3 U238 15
               REGI W4 U238 16

               REGI W1 U238 17
               REGI W2 U238 16
               REGI W3 U238 19
               REGI W4 U238 20

               REGI W1 U238 21
               REGI W2 U238 22
               REGI W3 U238 23
               REGI W4 U238 24

               REGI W1 U238 26
               REGI W2 U238 27
               REGI W3 U238 28
               REGI W4 U238 29

               REGI W1 U238 30
               REGI W2 U238 31
               REGI W3 U238 32
               REGI W4 U238 33

               REGI W1 U238 34
               REGI W2 U238 35
               REGI W3 U238 36
               REGI W4 U238 37
              
          ENDC ;
       EVALUATE iAutop := iAutop 1 + ;
     ENDIF ;
  ENDIF ;   

************************************************************************
*  BEGIN FIRST LEVEL FLUX CALCULATION                                  *
************************************************************************
IF istep 1 > THEN
  EDIHOM := EDI: FLUX2 LIBEQ TRACKN2 ::
   EDIT 0
   MICR ALL
   COND
   MERG MIX
      1   2   3   4   5   6   7   8   9  10  11  12   3   4   5   6   9
     10  11  12   9  10  11  12  25   3   4   5   6   3   4   5   6   3
      4   5   6   9  10  11  12   9  10  11  12   3   4   5   6   9  10
     11  12   3   4   5   6   9  10  11  12   9  10  11  12   3   4   5
      6   3   4   5   6   3   4   5   6   3   4   5   6   3   4   5   6
      3   4   5   6   9  10  11  12  17  18  19  20   9  10  11  12   9
     10  11  12  17  18  19  20   9  10  11  12  13  14  15  16  13  14
     15  16  21  22  23  24  26  27  28  29  26  27  28  29  26  27  28
     29  26  27  28  29  26  27  28  29  26  27  28  29  26  27  28  29
     30  31  32  33  34  35  36  37
   SAVE ON HOMOGENE 
  ; 
 LIBHOM := EDIHOM ::
  STEP UP HOMOGENE
 ;
 
 EDIHOM := DELETE: EDIHOM ;
 LIBRARY2 := LIB: LIBRARY2 LIBHOM ::
   EDIT 0
   MAXS
  MIX   1 MIX   2 MIX   3 MIX   4 MIX   5 MIX   6  
  MIX   7 MIX   8 MIX   9 MIX  10 MIX  11 MIX  12 
  MIX  13 MIX  14 MIX  15 MIX  16 MIX  17 MIX  18
  MIX  19 MIX  20 MIX  21 MIX  22 MIX  23 MIX  24
  MIX  25 MIX  26 MIX  27 MIX  28 MIX  29 MIX  30
  MIX  31 MIX  32 MIX  33 MIX  34 MIX  35 MIX  36
  MIX  37  
  ;
 LIBEQ LIBHOM := DELETE: LIBEQ LIBHOM ;
ENDIF ;

SYS := ASM: LIBRARY2 TRACKN1 :: ARM EDIT 0 ;    
FLUX := FLU: LIBRARY2 SYS TRACKN1 :: 
     EDIT 1 TYPE K ;

*----
*  26 groups energy condensation
*----
  EDITION := EDI: FLUX LIBRARY2 TRACKN1 ::
    EDIT 0
    MICR ALL
    MERG MIX
    COND  10  14  18  26  33  40  49  56  66 84 150 210 241 244 247
    252 255 258 261 268 273 277 281 286 291
    SAVE ON COND26
  ;
  LIBEQ := EDITION ::
    STEP UP COND26
  ;
 LIBEQ := SPH: LIBEQ TRACKN1 :: EDIT 2 ;

 FLUX SYS EDITION := DELETE: FLUX SYS EDITION ;
************************************************************************
*  END FIRST LEVEL FLUX CALCULATION                                    *
************************************************************************
************************************************************************
*  BEGIN SECOND LEVEL FLUX CALCULATION                                 *
************************************************************************
LIBEQ := MultLIBEQ LIBEQ ;
SYS := ASM: LIBEQ TRACKN2 TF_EXC :: ARM EDIT 1 ;    

IF istep 1 = THEN     
FLUX2 := FLU: LIBEQ SYS TRACKN2 TF_EXC :: 
     EDIT 1 TYPE K ;
ELSE
   FLUX2 := FLU: FLUX2 LIBEQ SYS TRACKN2 TF_EXC :: 
     EDIT 1 TYPE K ;
ENDIF ;

IF istep 1 = THEN
  RES := EDI: FLUX2 LIBEQ TRACKN2 :: EDIT 5                              
  MICR 4 U234 U235 U238 O16
  MERG MIX                                                               
  COND 19                               
  SAVE ON COND2                                                        
  ;
  BCOND2 := RES :: STEP UP COND2 ;
ENDIF ;

GREP: FLUX2 :: GETVAL 'K-EFFECTIVE  ' 1 1 1 >>Keff<< ;
ECHO "Resultat Keff= " Keff " at burnup= " BUend ;

 IF istep maxstep < THEN
  EVALUATE istepNext := istep 1 + ;
  GREP: DONNEES :: GETVAL 'BURN' <<istepNext>> >>BUend<< ;
  EVALUATE Tend := BUend Fuelpwr / ;
  
  IF istep 1 = THEN
     BURNUP LIBEQ := EVO: LIBEQ FLUX2 TRACKN2 ::
      EDIT 3 DEPL <<Tbeg>> <<Tend>> DAY POWR <<Fuelpwr>> 
      EXPM 1.0E15 GLOB ;
  ELSE
     BURNUP LIBEQ := EVO: BURNUP LIBEQ FLUX2 TRACKN2 ::
      EDIT 3 DEPL <<Tbeg>> <<Tend>> DAY POWR <<Fuelpwr>> 
      EXPM 1.0E15 GLOB ;
  ENDIF ;
 
  SYS := DELETE: SYS ;
  
 ENDIF ;
 
************************************************************************
*  END SECOND LEVEL FLUX CALCULATION                                   *
************************************************************************

ENDWHILE ;
assertS FLUX2 :: K-EFFECTIVE 1 0.8194671 ;
************************************************************************
*  END SECOND LEVEL FLUX CALCULATION                                   *
************************************************************************

ECHO "test UOX+B_TBH_eighth_2level_g2s completed" ;
END: ;

```

## msca/CGN_ASSEMBLY_A/Geo_N1.c2m

```fortran
*DECK Geo_N1
*----
*  Name          : Geo_N1.c2m
*  Type          : DRAGON procedure
*  Use           : Geometry generation for 1st Level Flux Calculation
*                  with 32 fuel regions
*  Author        : A. Canbakan
*
*  Procedure called as: 
*
*GEON1 := Geo_N1 :: <<Rcomb1>> <<Rcomb2>> <<Rcomb3>> <<Rcomb4>>
*                   <<R_int_TG>> <<R_ext_TG>> <<R_int_TI>> 
*                   <<R_ext_TI>> <<R_int_G>> <<R_ext_G>> <<Cote>>
*                   <<CoteL>> <<RmodeN1>> ;
*
*  Input data   :
*    Rcomb1     :  50/100 of outer radius of fuel (cm)
*    Rcomb2     :  80/100 of outer radius of fuel (cm)
*    Rcomb3     :  95/100 of outer radius of fuel (cm)
*    Rcomb4     : 100/100 of outer radius of fuel (cm)
*    R_int_TG   : Inner radius of cladding of guide tube (cm)
*    R_ext_TG   : Outer radius of cladding of guide tube (cm)
*    R_int_TI   : Inner radius of cladding of guide tube (cm)
*    R_ext_TI   : Outer radius of cladding of guide tube (cm)
*    R_int_G    : Inner radius of cladding of fuel tube (cm)
*    R_ext_G    : Outer radius of cladding of fuel tube (cm)
*    Cote       : Lattice pitch (cm)
*    CoteL      : Lattice pitch + Water space (cm)
*    RmodeN1    : Parameter for flux calculation in Level 1 (cm)
*
*  Output data  :
*    GEON1      : Geometry for 1st Level Flux Calculation

PARAMETER  GEON1  ::  
       EDIT 0 
           ::: LINKED_LIST GEON1  ; 
   ;
*----
*  Modules used in this procedure
*----
MODULE  GEO: END: ;

*----
*  Input data recovery
*----
*                                                                      ;
REAL Rcomb1       Rcomb2       Rcomb3       Rcomb4     ;
:: >>Rcomb1<<   >>Rcomb2<<   >>Rcomb3<<   >>Rcomb4<<   ;
REAL R_int_TG     R_ext_TG     R_int_TI     R_ext_TI   ;
:: >>R_int_TG<< >>R_ext_TG<< >>R_int_TI<< >>R_ext_TI<< ;
REAL R_int_G      R_ext_G      Cote         CoteL      ;
:: >>R_int_G<<  >>R_ext_G<<  >>Cote<<     >>CoteL<<    ;
REAL RmodeN1   ;
:: >>RmodeN1<< ;

GEON1 := GEO: :: CAR2D 9 9
  EDIT 0
  X- DIAG X+ REFL
  Y- SYME Y+ DIAG
  CELL TI C1 C1 T1 C1 C1 T2 C4 C6
          C2 C2 C1 C2 C2 C1 C2 C6
             C2 C1 C2 C2 C1 C2 C6
                T1 C1 C1 T2 C4 C6
                   C2 C1 C1 C2 C6
                      T2 C1 C3 C6
                         C2 C3 C6
                            C5 C7
                               C8

  MERGE 11 1  1 10  1  1  9  4  6
           2  2  1  2  2  1  2  6
              2  1  2  2  1  2  6
                10  1  1  9  4  6
                    2  1  1  2  6
                       9  1  3  6
                          2  3  6
                             5  7
                                8

* T2 -> 9 , T1 ->  10 , TI -> 11

  TURN  A  A  E  A  A  E  A  A  A
           A  E  F  A  E  D  A  A
              C  B  G  C  H  G  A
                 A  G  C  A  G  A
                    A  B  D  A  A
                       A  A  A  A
                          A  G  A
                             A  A
                                A


  ::: C1 := GEO: CARCEL 7
         MESHX 0.0 <<Cote>>
         MESHY 0.0 <<Cote>>
         RADIUS 0.0 <<Rcomb1>> <<Rcomb2>> <<Rcomb3>> <<Rcomb4>>
                <<R_int_G>> <<R_ext_G>> <<RmodeN1>>
         MIX  3 4 5 6   7 8 1 1
  ;
  ::: C2 := GEO: C1
         MIX 9 10 11 12   7 8 1 1
  ;
  ::: C3 := GEO: C1
         MIX 114 115 116 117   7 8 1 1
  ;
  ::: C4 := GEO: C1
         MIX 94 95 96 97   7 8 1 1
  ;
  ::: C5 := GEO: C1
         MIX 122 123 124 125   7 8 1 1
  ;
  ::: C6 := GEO: CARCEL 7
         MESHX 0.0 <<CoteL>>
         MESHY 0.0 <<Cote>>
         RADIUS 0.0 <<Rcomb1>> <<Rcomb2>> <<Rcomb3>> <<Rcomb4>>
                <<R_int_G>> <<R_ext_G>> <<RmodeN1>>
         MIX 126 127 128 129   7 8 1 1
  ;
  ::: C7 := GEO: C6
         MIX 154 155 156 157   7 8 1 1
  ;
  ::: C8 := GEO: CARCEL 7
         MESHX 0.0 <<CoteL>>
         MESHY 0.0 <<CoteL>>
         RADIUS 0.0 <<Rcomb1>> <<Rcomb2>> <<Rcomb3>> <<Rcomb4>>
                <<R_int_G>> <<R_ext_G>> <<RmodeN1>>
         MIX 158 159 160 161   7 8 1 1
  ;
  ::: T2 := GEO: CARCEL 2
         MESHX 0.0 <<Cote>>
         MESHY 0.0 <<Cote>>
         RADIUS 0.0 <<R_int_TG>> <<R_ext_TG>>
         MIX 1 25 1
  ;
  ::: T1 := GEO: T2
         MIX 1 25 1
  ;
  ::: TI := GEO: CARCEL 2
         MESHX 0.0 <<Cote>>
         MESHY 0.0 <<Cote>>
         RADIUS 0.0 <<R_int_TI>> <<R_ext_TI>>
         MIX 1 2 1
  ;
;

END: ;
QUIT .

```


## msca/CGN_ASSEMBLY_A/Geo_N2.c2m

```fortran
*DECK Geo_N2
*----
*  Name          : Geo_N2.c2m
*  Type          : DRAGON procedure
*  Use           : Geometry generation for 2nd Level Flux Calculation
*                  with 156 fuel regions and windmill discretization
*  Author        : A. Hebert
*
*  Procedure called as: 
*
*GEON2 := Geo_N2 :: <<Rcomb1>> <<Rcomb2>> <<Rcomb3>> <<Rcomb4>>
*                   <<R_int_TG>> <<R_ext_TG>> <<R_int_TI>> 
*                   <<R_ext_TI>> <<R_int_G>> <<R_ext_G>> <<Cote>>
*                   <<Lame>> <<Rtub1>> <<Rtub2>> ;
*
*  Input data   :
*    Rcomb1     :  50/100 of outer radius of fuel (cm)
*    Rcomb2     :  80/100 of outer radius of fuel (cm)
*    Rcomb3     :  95/100 of outer radius of fuel (cm)
*    Rcomb4     : 100/100 of outer radius of fuel (cm)
*    R_int_TG   : Inner radius of cladding of guide tube (cm)
*    R_ext_TG   : Outer radius of cladding of guide tube (cm)
*    R_int_TI   : Inner radius of cladding of guide tube (cm)
*    R_ext_TI   : Outer radius of cladding of guide tube (cm)
*    R_int_G    : Inner radius of cladding of fuel tube (cm)
*    R_ext_G    : Outer radius of cladding of fuel tube (cm)
*    Cote       : Lattice pitch (cm)
*    Lame       : Water space (cm)
*    Rtub1      : first radius of empty tube (cm)
*    Rtub2      : second radius of empty tube (cm)
*
*  Output data  :
*    GEON2      : Geometry for 2nd Level Flux Calculation

PARAMETER  GEON2  ::  
       EDIT 0 
           ::: LINKED_LIST GEON2  ; 
   ;
*----
*  Modules used in this procedure
*----
MODULE  GEO: END: ;

*----
*  Input data recovery
*----
*                                                                      ;
REAL Rcomb1       Rcomb2       Rcomb3       Rcomb4     ;
:: >>Rcomb1<<   >>Rcomb2<<   >>Rcomb3<<   >>Rcomb4<<   ;
REAL R_int_TG     R_ext_TG     R_int_TI     R_ext_TI   ;
:: >>R_int_TG<< >>R_ext_TG<< >>R_int_TI<< >>R_ext_TI<< ;
REAL R_int_G      R_ext_G      Cote         Lame       ;
:: >>R_int_G<<  >>R_ext_G<<  >>Cote<<     >>Lame<<     ;
REAL Rtub1        Rtub2                                ;
:: >>Rtub1<<    >>Rtub2<<                              ;

REAL mesh1 := Cote ;
REAL mesh2 := mesh1 Cote + ;
REAL mesh3 := mesh2 Cote + ;
REAL mesh4 := mesh3 Cote + ;
REAL mesh5 := mesh4 Cote + ;
REAL mesh6 := mesh5 Cote + ;
REAL mesh7 := mesh6 Cote + ;
REAL mesh8 := mesh7 Cote + ;
REAL mesh9 := mesh8 Cote + ;
REAL mesh10 := mesh9 Lame + ;
*
GEON2 := GEO: :: CAR2D 10 10
  EDIT 0
  X- DIAG X+ REFL
  Y- SYME Y+ DIAG
  CELL
  TI C0201 C0301     TG  C0501  C0601     TG   C0801 C0901 Lame_V
     C0202 C0302  C0402  C0502  C0602  C0702   C0802 C0902 Lame_V
           C0303  C0403  C0503  C0603  C0703   C0803 C0903 Lame_V
                     TG  C0504  C0604     TG   C0804 C0904 Lame_V
                         C0505  C0605  C0705   C0805 C0905 Lame_V
                                   TG  C0706   C0806 C0906 Lame_V
                                       C0707   C0807 C0907 Lame_V
                                               C0808 C0908 Lame_V
                                                     C0909 Lame_V
                                                           Lame_C
  MESHX 0.0 <<mesh1>> <<mesh2>> <<mesh3>> <<mesh4>> <<mesh5>> <<mesh6>>
        <<mesh7>> <<mesh8>> <<mesh9>> <<mesh10>>
  MESHY 0.0 <<mesh1>> <<mesh2>> <<mesh3>> <<mesh4>> <<mesh5>> <<mesh6>>
        <<mesh7>> <<mesh8>> <<mesh9>> <<mesh10>>
  ::: Lame_C := GEO: CAR2D 1 1
    MESHX 0.0 <<Lame>> MESHY 0.0 <<Lame>>
    MIX 1 ;

  ::: Lame_V := GEO: CAR2D 1 1
    MESHX 0.0 <<Lame>> MESHY 0.0 <<Cote>>
    SPLITY 3 MIX 1 ;

  ::: C0201 := GEO: CARCEL 6
         MESHX 0.0 <<Cote>>
         MESHY 0.0 <<Cote>>
         SECT 4 6
         RADIUS 0.0 <<Rcomb1>> <<Rcomb2>> <<Rcomb3>> <<Rcomb4>>
                <<R_int_G>> <<R_ext_G>>
         MIX  3 4 5 6   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0202 := GEO: C0201
         MIX  9 10 11 12   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0301 := GEO: C0201
         MIX  13 14 15 16   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0302 := GEO: C0201
         MIX  17 18 19 20   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0303 := GEO: C0201
         MIX  21 22 23 24   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0402 := GEO: C0201
         MIX  26 27 28 29   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0403 := GEO: C0201
         MIX  30 31 32 33   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0501 := GEO: C0201
         MIX  34 35 36 37   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0502 := GEO: C0201
         MIX  38 39 40 41   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0503 := GEO: C0201
         MIX  42 43 44 45   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0504 := GEO: C0201
         MIX  46 47 48 49   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0505 := GEO: C0201
         MIX  50 51 52 53   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0601 := GEO: C0201
         MIX  54 55 56 57   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0602 := GEO: C0201
         MIX  58 59 60 61   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0603 := GEO: C0201
         MIX  62 63 64 65   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0604 := GEO: C0201
         MIX  66 67 68 69   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0605 := GEO: C0201
         MIX  70 71 72 73   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0702 := GEO: C0201
         MIX  74 75 76 77   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0703 := GEO: C0201
         MIX  78 79 80 81   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0705 := GEO: C0201
         MIX  82 83 84 85   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0706 := GEO: C0201
         MIX  86 87 88 89   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0707 := GEO: C0201
         MIX  90 91 92 93   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0801 := GEO: C0201
         MIX  94 95 96 97   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0802 := GEO: C0201
         MIX  98 99 100 101   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0803 := GEO: C0201
         MIX  102 103 104 105   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0804 := GEO: C0201
         MIX  106 107 108 109   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0805 := GEO: C0201
         MIX  110 111 112 113   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0806 := GEO: C0201
         MIX  114 115 116 117   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0807 := GEO: C0201
         MIX  118 119 120 121   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0808 := GEO: C0201
         MIX  122 123 124 125   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0901 := GEO: C0201
         MIX  126 127 128 129   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0902 := GEO: C0201
         MIX  130 131 132 133   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0903 := GEO: C0201
         MIX  134 135 136 137   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0904 := GEO: C0201
         MIX  138 139 140 141   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0905 := GEO: C0201
         MIX  142 143 144 145   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0906 := GEO: C0201
         MIX  146 147 148 149   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0907 := GEO: C0201
         MIX  150 151 152 153   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0908 := GEO: C0201
         MIX  154 155 156 157   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: C0909 := GEO: C0201
         MIX  158 159 160 161   7 8 1 1 1 1 1 1 1 1 1 1 1 1 ;

  ::: TG := GEO: CARCEL 4
         MESHX 0.0 <<Cote>>
         MESHY 0.0 <<Cote>>
         SECT 3 1
         RADIUS 0.0 <<Rtub1>> <<Rtub2>> <<R_int_TG>> <<R_ext_TG>>
         MIX 1
             1  1  1  1  1  1  1  1
             1  1  1  1  1  1  1  1
             25 25 25 25 25 25 25 25
             1  1  1  1  1  1  1  1 ;

  ::: TI := GEO: CARCEL 4
         MESHX 0.0 <<Cote>>
         MESHY 0.0 <<Cote>>
         SECT 3 1
         RADIUS 0.0 <<Rtub1>> <<Rtub2>> <<R_int_TI>> <<R_ext_TI>>
         MIX 1
             1  1  1  1  1  1  1  1
             1  1  1  1  1  1  1  1
             2  2  2  2  2  2  2  2
             1  1  1  1  1  1  1  1 ;
;
```

## msca/CGN_ASSEMBLY_A/Geo_SS.c2m

```fortran
*DECK Geo_SS
*----
*  Name          : Geo_SS.c2m
*  Type          : DRAGON procedure
*  Use           : Geometry generation for Self-Shielding Calculation
*                  with 32 fuel regions
*  Author        : A. Canbakan
*
*  Procedure called as: 
*
*GEOSS := Geo_SS :: <<Rcomb1>> <<Rcomb2>> <<Rcomb3>> <<Rcomb4>>
*                   <<R_int_TG>> <<R_ext_TG>> <<R_int_TI>> 
*                   <<R_ext_TI>> <<R_int_G>> <<R_ext_G>> <<Cote>>
*                   <<CoteL>> ;
*
*  Input data   :
*    Rcomb1     :  50/100 of outer radius of fuel (cm)
*    Rcomb2     :  80/100 of outer radius of fuel (cm)
*    Rcomb3     :  95/100 of outer radius of fuel (cm)
*    Rcomb4     : 100/100 of outer radius of fuel (cm)
*    R_int_TG   : Inner radius of cladding of guide tube (cm)
*    R_ext_TG   : Outer radius of cladding of guide tube (cm)
*    R_int_TI   : Inner radius of cladding of guide tube (cm)
*    R_ext_TI   : Outer radius of cladding of guide tube (cm)
*    R_int_G    : Inner radius of cladding of fuel tube (cm)
*    R_ext_G    : Outer radius of cladding of fuel tube (cm)
*    Cote       : Lattice pitch (cm)
*    CoteL      : Lattice pitch + Water space (cm)
*
*  Output data  :
*    GEOSS      : Geometry for Self-Shielding Calculation

PARAMETER  GEOSS  ::  
       EDIT 0 
           ::: LINKED_LIST GEOSS  ; 
   ;
*----
*  Modules used in this procedure
*----
MODULE  GEO: END: ;

*----
*  Input data recovery
*----
*                                                                      ;
REAL Rcomb1       Rcomb2       Rcomb3       Rcomb4     ;
:: >>Rcomb1<<   >>Rcomb2<<   >>Rcomb3<<   >>Rcomb4<<   ;
REAL R_int_TG     R_ext_TG     R_int_TI     R_ext_TI   ;
:: >>R_int_TG<< >>R_ext_TG<< >>R_int_TI<< >>R_ext_TI<< ;
REAL R_int_G      R_ext_G      Cote         CoteL      ;
:: >>R_int_G<<  >>R_ext_G<<  >>Cote<<     >>CoteL<<    ;



GEOSS := GEO: :: CAR2D 9 9
  EDIT 0
  X- DIAG X+ REFL
  Y- SYME Y+ DIAG
  CELL TI C1 C1 T1 C1 C1 T2 C4 C6
          C2 C2 C1 C2 C2 C1 C2 C6
             C2 C1 C2 C2 C1 C2 C6
                T1 C1 C1 T2 C4 C6
                   C2 C1 C1 C2 C6
                      T2 C1 C3 C6
                         C2 C3 C6
                            C5 C7
                               C8

  MERGE 11 1  1 10  1  1  9  4  6
           2  2  1  2  2  1  2  6
              2  1  2  2  1  2  6
                10  1  1  9  4  6
                    2  1  1  2  6
                       9  1  3  6
                          2  3  6
                             5  7
                                8

* T2 -> 9 , T1 ->  10 , TI -> 11

  TURN  A  A  E  A  A  E  A  A  A
           A  E  F  A  E  D  A  A
              C  B  G  C  H  G  A
                 A  G  C  A  G  A
                    A  B  D  A  A
                       A  A  A  A
                          A  G  A
                             A  A
                                A


  ::: C1 := GEO: CARCEL 6
         MESHX 0.0 <<Cote>>
         MESHY 0.0 <<Cote>>
         RADIUS 0.0 <<Rcomb1>> <<Rcomb2>> <<Rcomb3>> <<Rcomb4>>
                <<R_int_G>> <<R_ext_G>>
         MIX  3 4 5 6   7 8 1
  ;
  ::: C2 := GEO: C1
         MIX 9 10 11 12   7 8 1
  ;
  ::: C3 := GEO: C1
         MIX 114 115 116 117    7 8 1
  ;
  ::: C4 := GEO: C1
         MIX 94 95 96 97   7 8 1
  ;
  ::: C5 := GEO: C1
         MIX 122 123 124 125   7 8 1
  ;
  ::: C6 := GEO: CARCEL 6
         MESHX 0.0 <<CoteL>>
         MESHY 0.0 <<Cote>>
         RADIUS 0.0 <<Rcomb1>> <<Rcomb2>> <<Rcomb3>> <<Rcomb4>>
                <<R_int_G>> <<R_ext_G>>
         MIX 126 127 128 129   7 8 1
  ;
  ::: C7 := GEO: C6
         MIX 154 155 156 157   7 8 1
  ;
  ::: C8 := GEO: CARCEL 6
         MESHX 0.0 <<CoteL>>
         MESHY 0.0 <<CoteL>>
         RADIUS 0.0 <<Rcomb1>> <<Rcomb2>> <<Rcomb3>> <<Rcomb4>>
                <<R_int_G>> <<R_ext_G>>
         MIX 158 159 160 161   7 8 1
  ;
  ::: T2 := GEO: CARCEL 2
         MESHX 0.0 <<Cote>>
         MESHY 0.0 <<Cote>>
         RADIUS 0.0 <<R_int_TG>> <<R_ext_TG>>
         MIX 1 25 1
  ;
  ::: T1 := GEO: T2
         MIX 1 25 1
  ;
  ::: TI := GEO: CARCEL 2
         MESHX 0.0 <<Cote>>
         MESHY 0.0 <<Cote>>
         RADIUS 0.0 <<R_int_TI>> <<R_ext_TI>>
         MIX 1 2 1
  ;
;

END: ;
QUIT .
```

## msca/CGN_ASSEMBLY_A/Mix_UOX.c2m

```fortran
*DECK Mix_Assb_DRA
*----
*  Name          : Mix_UOX.c2m
*  Type          : DRAGON procedure
*  Use           : Microlib generation with Draglibs for
*                  UOX calculation with 37 fuel regions
*  Author        : A. Canbakan
*
*  Procedure called as: 
*
*  LIBRARY := Mix_Assb_DRA ::
*    <<dens_mod>> <<pbore>> <<N_U5_UOX>> <<densU_UOX>>
*    <<temp_comb>> <<temp_mode>> <<temp_clad>> ;
*
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
  NMIX 161 CTRA APOL ANIS 2
  PT
  MIXS LIB: DRAGON FIL: <<Library>>

*----
*    Moderator
*----
  MIX 1 574.0 NOEV
    H1        = H1_H2O   4.857179E-2
    O16       = O16      2.432236E-2
    B10       = B10      4.841415E-6
    B11       = B11      1.948730E-5

*----
*    Cladding TI
*----
  MIX 2 574.0 NOEV
    Zr90     = Zr90     2.17736E-2 
    Zr91     = Zr91     4.74830E-3 2 IRSET PT 1
    Zr92     = Zr92     7.25788E-3
    Zr94     = Zr94     7.35521E-3
    Zr96     = Zr96     1.18496E-3

*----
*    Fuel -> 8 * 4 evolving mixes
*----
* C1 Cell
  MIX 3 874.0
    U234  = U234  6.9950E-6
    U235  = U235  9.2868E-4 1 IRSET PT 1
    U238  = U238  2.2000E-2 1 IRSET PT 1
    Pu238 = Pu238 1.E-20    1 IRSET PT 1
    Pu239 = Pu239 1.E-20    1 IRSET PT 1
    Pu240 = Pu240 1.E-20    1 IRSET PT 1
    Pu241 = Pu241 1.E-20    1 IRSET PT 1
    Pu242 = Pu242 1.E-20    1 IRSET PT 1
    O16   = O16   4.5871E-2
  MIX 4 
    COMB 3 1.0
  MIX 5 
    COMB 3 1.0
  MIX 6 
    COMB 3 1.0

*----
*    Gap
*----
  MIX 7 574.0 NOEV
    Al27     = Al27    1.00E-08

*----
*    Cladding fuel
*----
  MIX 8 574.0 NOEV
    Zr90     = Zr90     2.17736E-2 
    Zr91     = Zr91     4.74830E-3 3 IRSET PT 1
    Zr92     = Zr92     7.25788E-3
    Zr94     = Zr94     7.35521E-3
    Zr96     = Zr96     1.18496E-3

* C2 Cell
  MIX 9
    COMB 3 1.0
  MIX 10
    COMB 3 1.0
  MIX 11
    COMB 3 1.0
  MIX 12
    COMB 3 1.0

*----
*    Cladding TG
*----
  MIX 25 COMB 2 1.0

* C4 Cell
  MIX 94
    COMB 3 1.0
  MIX 95
    COMB 3 1.0
  MIX 96
    COMB 3 1.0
  MIX 97
    COMB 3 1.0

* C3 Cell
  MIX 114
    COMB 3 1.0
  MIX 115
    COMB 3 1.0
  MIX 116
    COMB 3 1.0
  MIX 117
    COMB 3 1.0

* C5 Cell
  MIX 122
    COMB 3 1.0
  MIX 123
    COMB 3 1.0
  MIX 124
    COMB 3 1.0
  MIX 125
    COMB 3 1.0

* C6 Cell
  MIX 126
    COMB 3 1.0
  MIX 127
    COMB 3 1.0
  MIX 128
    COMB 3 1.0
  MIX 129
    COMB 3 1.0

* C7 Cell
  MIX 154
    COMB 3 1.0
  MIX 155
    COMB 3 1.0
  MIX 156
    COMB 3 1.0
  MIX 157
    COMB 3 1.0

* C8 Cell
  MIX 158
    COMB 3 1.0
  MIX 159
    COMB 3 1.0
  MIX 160
    COMB 3 1.0
  MIX 161
    COMB 3 1.0
;

END: ;
QUIT .
```

## msca/CGN_ASSEMBLY_A/MultLIBEQ.c2m

```fortran
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
*                                                                      ;
MODULE LIB: END: ;

LIBEQ := LIB: LIBEQ ::
  EDIT 0
  NMIX 161
  DEPL LIB: DRAGON FIL: LIBEQ
  MIXS LIB: MICROLIB FIL: LIBEQ

*******
*C0301*  *C1
*******
MIX 13
	COMB 3 1.0
MIX 14
	COMB 4 1.0
MIX 15
	COMB 5 1.0
MIX 16
	COMB 6 1.0
*******
*C0302*  *C2
*******
MIX 17
	COMB 9 1.0
MIX 18
	COMB 10 1.0
MIX 19
	COMB 11 1.0
MIX 20
	COMB 12 1.0
*******
*C0303*  *C2
*******
MIX 21
	COMB 9 1.0
MIX 22
	COMB 10 1.0
MIX 23
	COMB 11 1.0
MIX 24
	COMB 12 1.0
*******
*C0402*  *C1
*******
MIX 26
	COMB 3 1.0
MIX 27
	COMB 4 1.0
MIX 28
	COMB 5 1.0
MIX 29
	COMB 6 1.0
*******
*C0403*  *C1
*******
MIX 30
	COMB 3 1.0
MIX 31
	COMB 4 1.0
MIX 32
	COMB 5 1.0
MIX 33
	COMB 6 1.0
*******
*C0501*  *C1
*******
MIX 34
	COMB 3 1.0
MIX 35
	COMB 4 1.0
MIX 36
	COMB 5 1.0
MIX 37
	COMB 6 1.0
*******
*C0502*  *C2
*******
MIX 38
	COMB 9 1.0
MIX 39
	COMB 10 1.0
MIX 40
	COMB 11 1.0
MIX 41
	COMB 12 1.0
*******
*C0503*  *C2
*******
MIX 42
	COMB 9 1.0
MIX 43
	COMB 10 1.0
MIX 44
	COMB 11 1.0
MIX 45
	COMB 12 1.0
*******
*C0504*  *C1
*******
MIX 46
	COMB 3 1.0
MIX 47
	COMB 4 1.0
MIX 48
	COMB 5 1.0
MIX 49
	COMB 6 1.0
*******
*C0505*  *C2
*******
MIX 50
	COMB 9 1.0
MIX 51
	COMB 10 1.0
MIX 52
	COMB 11 1.0
MIX 53
	COMB 12 1.0
*******
*C0601*  *C1
*******
MIX 54
	COMB 3 1.0
MIX 55
	COMB 4 1.0
MIX 56
	COMB 5 1.0
MIX 57
	COMB 6 1.0
*******
*C0602*  *C2
*******
MIX 58
	COMB 9 1.0
MIX 59
	COMB 10 1.0
MIX 60
	COMB 11 1.0
MIX 61
	COMB 12 1.0
*******
*C0603*  *C2
*******
MIX 62
	COMB 9 1.0
MIX 63
	COMB 10 1.0
MIX 64
	COMB 11 1.0
MIX 65
	COMB 12 1.0
*******
*C0604*  *C1
*******
MIX 66
	COMB 3 1.0
MIX 67
	COMB 4 1.0
MIX 68
	COMB 5 1.0
MIX 69
	COMB 6 1.0
*******
*C0605*  *C1
*******
MIX 70
	COMB 3 1.0
MIX 71
	COMB 4 1.0
MIX 72
	COMB 5 1.0
MIX 73
	COMB 6 1.0
*******
*C0702*  *C1
*******
MIX 74
	COMB 3 1.0
MIX 75
	COMB 4 1.0
MIX 76
	COMB 5 1.0
MIX 77
	COMB 6 1.0
*******
*C0703*  *C1
*******
MIX 78
	COMB 3 1.0
MIX 79
	COMB 4 1.0
MIX 80
	COMB 5 1.0
MIX 81
	COMB 6 1.0
*******
*C0705*  *C1
*******
MIX 82
	COMB 3 1.0
MIX 83
	COMB 4 1.0
MIX 84
	COMB 5 1.0
MIX 85
	COMB 6 1.0
*******
*C0706*  *C1
*******
MIX 86
	COMB 3 1.0
MIX 87
	COMB 4 1.0
MIX 88
	COMB 5 1.0
MIX 89
	COMB 6 1.0
*******
*C0707*  *C2
*******
MIX 90
	COMB 9 1.0
MIX 91
	COMB 10 1.0
MIX 92
	COMB 11 1.0
MIX 93
	COMB 12 1.0
*******
*C0801*  *C4
*******		
*******
*C0802*  *C2
*******
MIX 98
	COMB 9 1.0
MIX 99
	COMB 10 1.0
MIX 100
	COMB 11 1.0
MIX 101
	COMB 12 1.0
*******
*C0803*  *C2
*******
MIX 102
	COMB 9 1.0
MIX 103
	COMB 10 1.0
MIX 104
	COMB 11 1.0
MIX 105
	COMB 12 1.0
*******
*C0804*   *C4
*******
MIX 106
	COMB 94 1.0
MIX 107
	COMB 95 1.0
MIX 108
	COMB 96 1.0
MIX 109
	COMB 97 1.0
*******
*C0805*  *C2
*******
MIX 110
	COMB 9 1.0
MIX 111
	COMB 10 1.0
MIX 112
	COMB 11 1.0
MIX 113
	COMB 12 1.0
*******
*C0807*  *C3
*******
MIX 118
	COMB 114 1.0
MIX 119
	COMB 115 1.0
MIX 120
	COMB 116 1.0
MIX 121
	COMB 117 1.0
*******
*C0902*  *C6
*******
MIX 130
	COMB 126 1.0
MIX 131
	COMB 127 1.0
MIX 132
	COMB 128 1.0
MIX 133
	COMB 129 1.0
*******
*C0903*  *C6
*******
MIX 134
	COMB 126 1.0
MIX 135
	COMB 127 1.0
MIX 136
	COMB 128 1.0
MIX 137
	COMB 129 1.0
*******
*C0904*  *C6
*******
MIX 138
	COMB 126 1.0
MIX 139
	COMB 127 1.0
MIX 140
	COMB 128 1.0
MIX 141
	COMB 129 1.0
*******
*C0905*  *C6
*******
MIX 142
	COMB 126 1.0
MIX 143
	COMB 127 1.0
MIX 144
	COMB 128 1.0
MIX 145
	COMB 129 1.0
*******
*C0906*  *C6
*******
MIX 146
	COMB 126 1.0
MIX 147
	COMB 127 1.0
MIX 148
	COMB 128 1.0
MIX 149
	COMB 129 1.0
*******
*C0907*  *C6
*******
MIX 150
	COMB 126 1.0
MIX 151
	COMB 127 1.0
MIX 152
	COMB 128 1.0
MIX 153
	COMB 129 1.0
;

END: ;
QUIT .
```

## the end