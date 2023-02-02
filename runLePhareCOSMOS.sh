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
    export SEDFORS2DIR="${LEPHAREWORK}/../fors2_templates/KmeanClus_PCA"
fi

export CAT_FILE_IN="${LEPHAREDIR}/examples/COSMOS.in"
if [ -z "${CAT_FILE_IN+x}" ]; then
    #export CAT_FILE_IN='DC2_VALID_CAT_IN.in'
    export CAT_FILE_IN="${LEPHAREWORK}/ultravista_flux2_zcosmos.in"
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
$LEPHAREDIR/source/filter -c eric.para

## read the galaxy templates (as used in Ilbert et al. 2013)and store them in `$LEPHAREWORK/lib_bin`



#GAL CWW
echo "CWW templates"
$LEPHAREDIR/source/sedtolib -c eric.para -t G -GAL_SED ${LEPHAREDIR}/sed/GAL/CFHTLS_230506/CFHTLS_MOD.list  -GAL_LIB LIB_CWW 
$LEPHAREDIR/source/mag_gal  -c eric.para -t G -GAL_LIB_IN LIB_CWW -GAL_LIB_OUT CWW_SCOSMOS -MOD_EXTINC 0,0

#$LEPHAREDIR/source/sedtolib -t G -c eric.para
#$LEPHAREDIR/source/sedtolib -t S -c eric.para

#GAL FORS2
echo "FORS2-derived templates"
$LEPHAREDIR/source/sedtolib -c eric.para -t G -GAL_SED ${LEPHAREWORK}/SED_AVG_FORS2_normed.list -GAL_LIB LIB_FORS2_NORM
#$LEPHAREDIR/source/mag_gal  -c eric.para -t G -GAL_LIB_IN LIB_FORS2 -GAL_LIB_OUT FORS2_SCOSMOS -MOD_EXTINC 1,30,1,30 -EXTINC_LAW SMC_prevot.dat,SB_calzetti.dat -EM_LINES EMP_UV -Z_STEP 0.04,0.,6. -LIB_ASCII YES
$LEPHAREDIR/source/mag_gal  -c eric.para -t G -GAL_LIB_IN LIB_FORS2_NORM -GAL_LIB_OUT FORS2_SCOSMOS_NORM -EM_LINES EMP_UV -LIB_ASCII YES

#GAL VISTA
echo "VISTA templates"
$LEPHAREDIR/source/sedtolib -c eric.para -t G -GAL_SED $LEPHAREDIR/sed/GAL/COSMOS_SED/COSMOS_MOD.list  -GAL_LIB LIB_VISTA 
$LEPHAREDIR/source/mag_gal  -c eric.para -t G -GAL_LIB_IN LIB_VISTA -GAL_LIB_OUT VISTA_SCOSMOS -MOD_EXTINC 18,26,26,33,26,33,26,33  -EXTINC_LAW SMC_prevot.dat,SB_calzetti.dat,SB_calzetti_bump1.dat,SB_calzetti_bump2.dat

#STAR
echo "Stars templates"
$LEPHAREDIR/source/sedtolib -c eric.para -t S -STAR_SED $LEPHAREDIR/sed/STAR/STAR_MOD_ALL.list
$LEPHAREDIR/source/mag_gal -c eric.para -t S -LIB_ASCII YES -STAR_LIB_OUT ALLSTAR_SCOSMOS -LIB_ASCII YES

#AGN
echo "AGN templates"
$LEPHAREDIR/source/sedtolib -c eric.para -t Q -QSO_SED  $LEPHAREDIR/sed/QSO/SALVATO09/AGN_MOD.list
$LEPHAREDIR/source/mag_gal -c eric.para -t Q -MOD_EXTINC 0,1000  -EB_V 0.,0.1,0.2,0.3 -EXTINC_LAW SB_calzetti.dat -LIB_ASCII YES


#BC03
echo "BC03-synthetic templates"
$LEPHAREDIR/source/sedtolib -c eric.para -t G -GAL_SED BC03_ASCII.list  -GAL_LIB LIB_BC03 -SEL_AGE $LEPHAREDIR/sed/GAL/BC03_CHAB/AGE_BC03.dat
$LEPHAREDIR/source/mag_gal  -c eric.para -t G -GAL_LIB_IN LIB_BC03 -GAL_LIB_OUT BC03_SCOSMOS -MOD_EXTINC 1,2 -EXTINC_LAW SB_calzetti.dat  -LIB_ASCII NO -Z_STEP 0.04,0.,6.

#IR LIB DALE
echo "DALE IR templates"
$LEPHAREDIR/source/sedtolib -c eric.para -t G -GAL_SED $LEPHAREDIR/sed/GAL/DALE/DALE.list  -GAL_LIB LIB_DALE

## use the galaxy templates + filters to derive a library of predicted magnitudes and store it in `$LEPHAREWORK/lib_mag` (the parameters correspond to enabling emission lines correlated to UV light + free factor in scaling these lines, mo$
#echo "Magnitudes"
#$LEPHAREDIR/source/mag_gal -t G -c eric.para
#$LEPHAREDIR/source/mag_gal -t S -c eric.para


###################################################
# CALIBRATION
###################################################

## finally proceed to photometric redshift estimation
#echo "Estimation"
#$LEPHAREDIR/source/zphota -c eric.para -CAT_IN "$CAT_FILE_IN"  -CAT_OUT zphot_vista_adapt.out -ZPHOTLIB CWW_SCOSMOS,VISTA_SCOSMOS,ALLSTAR_SCOSMOS,QSO_SCOSMOS,BC03_SCOSMOS  -ADD_EMLINES 0,100 -AUTO_ADAPT YES  -EM_DISPERSION 50,5 -INP_TYPE F

echo "Estimation"
$LEPHAREDIR/source/zphota -c eric.para -CAT_IN "$CAT_FILE_IN"  -CAT_OUT zphot_vista_adapt_fors2_normed.out -ZPHOTLIB FORS2_SCOSMOS_NORM,ALLSTAR_SCOSMOS,QSO_SCOSMOS  -ADD_EMLINES 1,30 -AUTO_ADAPT YES  -EM_DISPERSION 50,5 -INP_TYPE F

#echo "Estimation"
#$LEPHAREDIR/source/zphota -c eric.para -CAT_IN "$CAT_FILE_IN"  -CAT_OUT zphot_vista_adapt_noBC03.out -ZPHOTLIB CWW_SCOSMOS,VISTA_SCOSMOS,ALLSTAR_SCOSMOS,QSO_SCOSMOS  -ADD_EMLINES 0,100 -AUTO_ADAPT YES  -EM_DISPERSION 50,5 -INP_TYPE F

#$LEPHAREDIR/source/zphota -c eric.para -CAT_IN "$CAT_FILE_IN" -CAT_TYPE LONG -CAT_OUT zphot_long.out -AUTO_ADAPT YES
#$LEPHAREDIR/source/zphota -c LSST_specId.para -CAT_IN "$CAT_FILE_IN" -CAT_TYPE LONG -CAT_OUT zphot_long_specId.out -AUTO_ADAPT YES
#$LEPHAREDIR/source/zphota -c LSST.para -CAT_IN train_DC2_VALID_CAT_IN.in -CAT_TYPE LONG -CAT_OUT train_zphot_long.out -AUTO_ADAPT YES

#$LEPHAREDIR/source/zphota -c eric.para -CAT_IN "$CAT_FILE_IN" -CAT_OUT zphot_short.out -ZPHOTLIB VISTA_COSMOS_FREE,ALLSTAR_COSMOS,QSO_COSMOS -AUTO_ADAPT YES
#$LEPHAREDIR/source/zphota -c eric.para -CAT_IN "$CAT_FILE_IN" -CAT_OUT zphot_short.out -ZPHOTLIB CE_SCOSMOS,STAR_SCOSMOS -AUTO_ADAPT YES

## a python script is available to perform a quick diagnostics
echo "Plots"
#python figuresLPZ.py zphot_vista_adapt.out
python figuresLPZ.py zphot_vista_adapt_fors2_normed.out
#python figuresLPZ.py zphot_vista_adapt_noBC03.out
#python figuresLPZ.py train_zphot_long.out
