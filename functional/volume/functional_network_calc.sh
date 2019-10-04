#!/bin/bash

subj=${1}
out=${2}
scriptsdir=path/to/scripts

mkdir ${out}/Fun/${subj}/connectome

resdir=${out}/Fun/${subj}/preproc.fnirt.feat/glm.residuals
netdir=${out}/Fun/${subj}/connectome

cp ${scriptsdir}/functional/volume/functional_connectivity_networks.py ${netdir}/fc_cm.py

# Copy residuals to network directory

#cp ${resdir}/nuisance_residual_global2standard.nii.gz ${netdir}/mni_func_residual_global.nii.gz
#cp ${resdir}/nuisance_residual2standard.nii.gz ${netdir}/mni_func_residual.nii.gz

cd ${netdir}

python fc_cm.py
