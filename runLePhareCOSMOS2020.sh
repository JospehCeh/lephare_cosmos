#!/bin/env bash

if [ -z "${LEPHAREDIR+x}" ]; then
    export LEPHAREDIR="${PWD%/*}/LEPHARE"
fi
if [ -z "${LEPHAREWORK+x}" ]; then
    export LEPHAREWORK="${PWD}"
fi
if [ -z "${OMP_NUM_THREADS+x}" ]; then
    export OMP_NUM_THREADS='10'
fi


if [ -z "${SEDFORS2DIR+x}" ]; then
    export SEDFORS2DIR="${LEPHAREDIR}/sed/GAL/FORS2_KmeanClus_batch4"
fi


export CAT_FILE_IN="${LEPHAREWORK}/COSMOS2020.in"
if [ -z "${CAT_FILE_IN+x}" ]; then
    export CAT_FILE_IN="${LEPHAREWORK}/COSMOS2020.in"
fi

if [ ! -d "$LEPHAREWORK" ]; then
  mkdir -p "$LEPHAREWORK/lib_bin"
  mkdir "$LEPHAREWORK/lib_mag"
  mkdir "$LEPHAREWORK/filt"
else
  if [ ! -d "$LEPHAREWORK/lib_bin" ] ; then
    mkdir "$LEPHAREWORK/lib_bin"
  fi
  if [ ! -d "$LEPHAREWORK/lib_mag" ] ; then
    mkdir "$LEPHAREWORK/lib_mag"
  fi
  if [ ! -d "$LEPHAREWORK/filt" ] ; then
    mkdir "$LEPHAREWORK/filt"
  fi
fi

#############
##  LIBRARY

echo "Filters"
#$LEPHAREDIR/source/filter -c COSMOS2020.para

## read the galaxy templates (as used in Ilbert et al. 2013) and store them in `$LEPHAREWORK/lib_bin`

#GAL CWW
echo "CWW templates"
#$LEPHAREDIR/source/sedtolib -c COSMOS2020.para -t G -GAL_SED ${LEPHAREDIR}/sed/GAL/CFHTLS_230506/CFHTLS_MOD.list -GAL_LIB LIB_CWW2020
#$LEPHAREDIR/source/mag_gal  -c COSMOS2020.para -t G -GAL_LIB_IN LIB_CWW2020 -GAL_LIB_OUT CWW_COSMOS2020 -MOD_EXTINC 0,0

#GAL VISTA
echo "VISTA templates"
#$LEPHAREDIR/source/sedtolib -c COSMOS2020.para -t G -GAL_SED $LEPHAREDIR/sed/GAL/COSMOS_SED/COSMOS_MOD.list  -GAL_LIB LIB_VISTA2020 
#$LEPHAREDIR/source/mag_gal  -c COSMOS2020.para -t G -GAL_LIB_IN LIB_VISTA2020 -GAL_LIB_OUT VISTA_COSMOS2020 -MOD_EXTINC 18,26,26,33,26,33,26,33  -EXTINC_LAW SMC_prevot.dat,SB_calzetti.dat,SB_calzetti_bump1.dat,SB_calzetti_bump2.dat 
#$LEPHAREDIR/source/mag_gal  -c COSMOS2020.para -t G -GAL_LIB_IN LIB_VISTA2020 -GAL_LIB_OUT VISTA_COSMOS2020_noExt

#STAR
echo "Stars templates"
#$LEPHAREDIR/source/sedtolib -c COSMOS2020.para -t S -STAR_SED $LEPHAREDIR/sed/STAR/STAR_MOD_ALL.list -STAR_LIB ALLSTAR_LIB2020
#$LEPHAREDIR/source/mag_gal -c COSMOS2020.para -t S -LIB_ASCII YES -STAR_LIB_IN ALLSTAR_LIB2020 -STAR_LIB_OUT ALLSTAR_COSMOS2020 -LIB_ASCII YES
#$LEPHAREDIR/source/sedtolib -c COSMOS2020.para -t S
#$LEPHAREDIR/source/mag_gal -c COSMOS2020.para -t S -LIB_ASCII YES

#AGN
echo "AGN templates"
#$LEPHAREDIR/source/sedtolib -c COSMOS2020.para -t Q -QSO_SED  $LEPHAREDIR/sed/QSO/SALVATO09/AGN_MOD.list -QSO_LIB AGN_LIB2020
#$LEPHAREDIR/source/mag_gal -c COSMOS2020.para -t Q -QSO_LIB_IN AGN_LIB2020 -QSO_LIB_OUT ALLQSO_COSMOS2020 -MOD_EXTINC 0,1000  -EB_V 0.,0.1,0.2,0.3 -EXTINC_LAW SB_calzetti.dat -LIB_ASCII YES
#$LEPHAREDIR/source/sedtolib -c COSMOS2020.para -t Q
#$LEPHAREDIR/source/mag_gal -c COSMOS2020.para -t Q -MOD_EXTINC 0,1000  -EB_V 0.,0.1,0.2,0.3 -EXTINC_LAW SB_calzetti.dat -LIB_ASCII YES


#BC03
echo "BC03-synthetic templates"
#$LEPHAREDIR/source/sedtolib -c COSMOS2020.para -t G -GAL_SED BC03_ASCII.list  -GAL_LIB LIB_BC032020 -SEL_AGE $LEPHAREDIR/sed/GAL/BC03_CHAB/AGE_BC03.dat
#$LEPHAREDIR/source/mag_gal  -c COSMOS2020.para -t G -GAL_LIB_IN LIB_BC032020 -GAL_LIB_OUT BC03_COSMOS2020 -MOD_EXTINC 1,2 -EXTINC_LAW SB_calzetti.dat  -LIB_ASCII NO

#IR LIB DALE
echo "DALE IR templates"
#$LEPHAREDIR/source/sedtolib -c COSMOS2020.para -t G -GAL_SED $LEPHAREDIR/sed/GAL/DALE/DALE.list -GAL_LIB LIB_DALE2020 

## use the galaxy templates + filters to derive a library of predicted magnitudes and store it in `$LEPHAREWORK/lib_mag` (the parameters correspond to enabling emission lines correlated to UV light + free factor in scaling these lines, mo$
#echo "Magnitudes"
#$LEPHAREDIR/source/mag_gal -t G -c eric.para
#$LEPHAREDIR/source/mag_gal -t S -c eric.para


###################################################
# CALIBRATION
###################################################

## finally proceed to photometric redshift estimation
echo "Estimation"
#$LEPHAREDIR/source/zphota -c COSMOS2020.para -CAT_IN "$CAT_FILE_IN"  -CAT_OUT zphot2020_vista_adapt.out -ZPHOTLIB CWW_COSMOS2020,VISTA_COSMOS2020,ALLSTAR_COSMOS2020,QSO_COSMOS2020,BC03_COSMOS2020  -ADD_EMLINES 0,100 -AUTO_ADAPT YES  -EM_DISPERSION 50,5 -INP_TYPE F
#$LEPHAREDIR/source/zphota -c COSMOS2020.para -CAT_IN "$CAT_FILE_IN"  -CAT_OUT zphot2020_vista_adapt_noBC03.out -ZPHOTLIB CWW_COSMOS2020,VISTA_COSMOS2020,ALLSTAR_COSMOS2020,ALLQSO_COSMOS2020  -ADD_EMLINES 0,100 -AUTO_ADAPT YES  -EM_DISPERSION 50,5 -INP_TYPE F
#$LEPHAREDIR/source/zphota -c COSMOS2020.para -CAT_IN "$CAT_FILE_IN"  -CAT_OUT zphot2020_vista_adapt_noBC03_noExt.out -ZPHOTLIB CWW_COSMOS2020,VISTA_COSMOS2020_noExt,ALLSTAR_COSMOS2020,ALLQSO_COSMOS2020  -ADD_EMLINES 0,100 -AUTO_ADAPT YES  -EM_DISPERSION 50,5 -INP_TYPE F


#GAL FORS2
echo "FORS2-derived templates"
$LEPHAREDIR/source/sedtolib -c COSMOS2020.para -t G -GAL_SED ${LEPHAREWORK}/SED_FORS2_KinCalClus_SL_v6.list -GAL_LIB LIB2020_FORS2_SL_KinCalV6
$LEPHAREDIR/source/mag_gal  -c COSMOS2020.para -t G -GAL_LIB_IN LIB2020_FORS2_SL_KinCalV6 -GAL_LIB_OUT LIB2020_FORS2_SL_KinCalV6_CALetPREV -MOD_EXTINC 0,29,0,29 -EXTINC_LAW SB_calzetti.dat,SMC_prevot.dat
#$LEPHAREDIR/source/mag_gal  -c COSMOS2020.para -t G -GAL_LIB_IN LIB2020_FORS2_SL_KinCalV5 -GAL_LIB_OUT LIB2020_FORS2_SL_KinCalV5_noExt

#$LEPHAREDIR/source/sedtolib -c COSMOS2020.para -t G -GAL_SED ${LEPHAREWORK}/SED_FORS2_ColorSelect_SL_v5.list -GAL_LIB LIB2020_FORS2_SL_ColorSelectV5
#$LEPHAREDIR/source/mag_gal  -c COSMOS2020.para -t G -GAL_LIB_IN LIB2020_FORS2_SL_ColorSelectV5 -GAL_LIB_OUT LIB2020_FORS2_SL_ColorSelectV5_CALetPREV -MOD_EXTINC 0,59,0,59 -EXTINC_LAW SB_calzetti.dat,SMC_prevot.dat

echo "Estimation"
$LEPHAREDIR/source/zphota -c COSMOS2020.para -CAT_IN "$CAT_FILE_IN" -CAT_OUT zphot2020_fors2SL_KinCalClusV6_prevEtCal.out -ZPHOTLIB LIB2020_FORS2_SL_KinCalV6_CALetPREV,ALLSTAR_COSMOS2020,ALLQSO_COSMOS2020 -ADD_EMLINES 0,36 -AUTO_ADAPT YES -EM_DISPERSION 50,5 -INP_TYPE F
#$LEPHAREDIR/source/zphota -c COSMOS2020.para -CAT_IN "$CAT_FILE_IN" -CAT_OUT zphot2020_fors2SL_KinCalClusV5_noExt.out -ZPHOTLIB LIB2020_FORS2_SL_KinCalV5_noExt,ALLSTAR_COSMOS2020,ALLQSO_COSMOS2020 -ADD_EMLINES 0,36 -AUTO_ADAPT YES -EM_DISPERSION 50,5 -INP_TYPE F
#$LEPHAREDIR/source/zphota -c COSMOS2020.para -CAT_IN "$CAT_FILE_IN" -CAT_OUT zphot2020_fors2SL_ColorSelectV5_prevEtCal.out -ZPHOTLIB LIB2020_FORS2_SL_ColorSelectV5_CALetPREV,ALLSTAR_COSMOS2020,ALLQSO_COSMOS2020 -ADD_EMLINES 0,59 -AUTO_ADAPT YES -EM_DISPERSION 50,5 -INP_TYPE F

echo "FORS2-derived templates"
#$LEPHAREDIR/source/sedtolib -c COSMOS2020.para -t G -GAL_SED ${LEPHAREWORK}/SED_FORS2_KinCalClus_SL_v5_normed.list -GAL_LIB LIB2020_FORS2_SL_KinCalV5N
#$LEPHAREDIR/source/mag_gal  -c COSMOS2020.para -t G -GAL_LIB_IN LIB2020_FORS2_SL_KinCalV5N -GAL_LIB_OUT LIB2020_FORS2_SL_KinCalV5N_CALetPREV -MOD_EXTINC 0,36,0,36 -EXTINC_LAW SB_calzetti.dat,SMC_prevot.dat
#$LEPHAREDIR/source/mag_gal  -c COSMOS2020.para -t G -GAL_LIB_IN LIB2020_FORS2_SL_KinCalV5N -GAL_LIB_OUT LIB2020_FORS2_SL_KinCalV5N_noExt

#$LEPHAREDIR/source/sedtolib -c COSMOS2020.para -t G -GAL_SED ${LEPHAREWORK}/SED_FORS2_ColorSelect_SL_v5_normed.list -GAL_LIB LIB2020_FORS2_SL_ColorSelectV5N
#$LEPHAREDIR/source/mag_gal  -c COSMOS2020.para -t G -GAL_LIB_IN LIB2020_FORS2_SL_ColorSelectV5N -GAL_LIB_OUT LIB2020_FORS2_SL_ColorSelectV5N_CALetPREV -MOD_EXTINC 0,74,0,74 -EXTINC_LAW SB_calzetti.dat,SMC_prevot.dat

echo "Estimation"
#$LEPHAREDIR/source/zphota -c COSMOS2020.para -CAT_IN "$CAT_FILE_IN" -CAT_OUT zphot2020_fors2SL_KinCalClusV5N_prevEtCal.out -ZPHOTLIB LIB2020_FORS2_SL_KinCalV5N_CALetPREV,ALLSTAR_COSMOS2020,ALLQSO_COSMOS2020 -ADD_EMLINES 0,36 -AUTO_ADAPT YES -EM_DISPERSION 50,5 -INP_TYPE F
#$LEPHAREDIR/source/zphota -c COSMOS2020.para -CAT_IN "$CAT_FILE_IN" -CAT_OUT zphot2020_fors2SL_KinCalClusV5N_noExt.out -ZPHOTLIB LIB2020_FORS2_SL_KinCalV5N_noExt,ALLSTAR_COSMOS2020,ALLQSO_COSMOS2020 -ADD_EMLINES 0,36 -AUTO_ADAPT YES -EM_DISPERSION 50,5 -INP_TYPE F
#$LEPHAREDIR/source/zphota -c COSMOS2020.para -CAT_IN "$CAT_FILE_IN" -CAT_OUT zphot2020_fors2SL_ColorSelectV4N_prevEtCal.out -ZPHOTLIB LIB2020_FORS2_SL_ColorSelectV4N_CALetPREV,ALLSTAR_COSMOS2020,ALLQSO_COSMOS2020 -ADD_EMLINES 0,74 -AUTO_ADAPT YES -EM_DISPERSION 50,5 -INP_TYPE F

#echo "Estimation"
#$LEPHAREDIR/source/zphota -c eric.para -CAT_IN "$CAT_FILE_IN"  -CAT_OUT zphot_outliers_ref.out -ZPHOTLIB CWW_SCOSMOS,VISTA_SCOSMOS,ALLSTAR_SCOSMOS,QSO_SCOSMOS  -ADD_EMLINES 0,100 -AUTO_ADAPT YES  -EM_DISPERSION 50,5 -INP_TYPE F -SPEC_OUT YES

#$LEPHAREDIR/source/zphota -c eric.para -CAT_IN "$CAT_FILE_IN" -CAT_TYPE LONG -CAT_OUT zphot_long.out -AUTO_ADAPT YES
#$LEPHAREDIR/source/zphota -c LSST_specId.para -CAT_IN "$CAT_FILE_IN" -CAT_TYPE LONG -CAT_OUT zphot_long_specId.out -AUTO_ADAPT YES
#$LEPHAREDIR/source/zphota -c LSST.para -CAT_IN train_DC2_VALID_CAT_IN.in -CAT_TYPE LONG -CAT_OUT train_zphot_long.out -AUTO_ADAPT YES

#$LEPHAREDIR/source/zphota -c eric.para -CAT_IN "$CAT_FILE_IN" -CAT_OUT zphot_short.out -ZPHOTLIB VISTA_COSMOS_FREE,ALLSTAR_COSMOS,QSO_COSMOS -AUTO_ADAPT YES
#$LEPHAREDIR/source/zphota -c eric.para -CAT_IN "$CAT_FILE_IN" -CAT_OUT zphot_short.out -ZPHOTLIB CE_SCOSMOS,STAR_SCOSMOS -AUTO_ADAPT YES

## a python script is available to perform a quick diagnostics
echo "Plots"
#python figuresLPZ.py zphot_vista_adapt.out
#python figuresLPZ.py zphot_vista_adapt_fors2_SL_normed.out
#python figuresLPZ.py zphot_vista_adapt_noBC03.out
#python figuresLPZ.py train_zphot_long.out
