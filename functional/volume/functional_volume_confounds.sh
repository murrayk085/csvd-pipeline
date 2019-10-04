#!/bin/bash

# This script should be run at the end of the FSL FEAT preprocessing
# It creates a design matrix to regress out the counfounding variables
# It outputs the residual timecourse to later be used for networks
# Variables considered:
#   Motion (6DOF)
#   White Matter Average
#   CSF Average
#   Gray Matter Average (Global Signal) - This variable is taken into account twice (once with and once without). Note the outputs carefully.
# 
# Physiological variables are not considered yet. Update this when they are.
# Physio variables:
#   Et-CO2
#   Heart rate
#   Respirations
#

subj=${1}
out=${2}

# Define directories

anatdir=${out}/T1/${subj}/t1.anat
funcdir=${out}/Fun/${subj}/preproc.fnirt.feat
regdir=${funcdir}/reg

mkdir ${funcdir}/glm.residuals

resdir=${funcdir}/glm.residuals

# Create tissue masks

flirt -in ${anatdir}/T1_fast_pve_0.nii.gz -ref ${funcdir}/filtered_func_data.nii.gz -out ${resdir}/pve_csf -applyxfm -init ${regdir}/highres2example_func.mat

fslmaths ${resdir}/pve_csf.nii.gz -thr 0.5 -bin ${resdir}/csf_mask

flirt -in ${anatdir}/T1_fast_pve_1.nii.gz -ref ${funcdir}/filtered_func_data.nii.gz -out ${resdir}/pve_gm -applyxfm -init ${regdir}/highres2example_func.mat

fslmaths ${resdir}/pve_gm.nii.gz -thr 0.5 -bin ${resdir}/gm_mask

flirt -in ${anatdir}/T1_fast_pve_2.nii.gz -ref ${funcdir}/filtered_func_data.nii.gz -out ${resdir}/pve_wm -applyxfm -init ${regdir}/highres2example_func.mat

fslmaths ${resdir}/pve_wm.nii.gz -thr 0.5 -bin ${resdir}/wm_mask

# Create tissue time courses

fslmeants -i ${funcdir}/filtered_func_data.nii.gz -o ${resdir}/csf_ts.txt -m ${resdir}/csf_mask.nii.gz

fslmeants -i ${funcdir}/filtered_func_data.nii.gz -o ${resdir}/gm_ts.txt -m ${resdir}/gm_mask.nii.gz

fslmeants -i ${funcdir}/filtered_func_data.nii.gz -o ${resdir}/wm_ts.txt -m ${resdir}/wm_mask.nii.gz

# Create design matrices

cp ${funcdir}/mc/prefiltered_func_data_mcf.par ${resdir}/motion.txt

# Include global signal

paste -d' ' ${resdir}/csf_ts.txt ${resdir}/wm_ts.txt ${resdir}/gm_ts.txt ${resdir}/motion.txt > ${resdir}/nuisance_global_confounds.txt

Text2Vest ${resdir}/nuisance_global_confounds.txt ${resdir}/nuisance_global_confounds.mat

# Exclude global signal

paste -d' ' ${resdir}/csf_ts.txt ${resdir}/wm_ts.txt ${resdir}/motion.txt > ${resdir}/nuisance_confounds.txt

Text2Vest ${resdir}/nuisance_confounds.txt ${resdir}/nuisance_confounds.mat

# Perfrom regressions

fsl_glm -i ${funcdir}/filtered_func_data.nii.gz -d ${resdir}/nuisance_global_confounds.mat -o ${resdir}/nuisance_coef_global.nii.gz --out_res=${resdir}/nuisance_residual_global.nii.gz

fsl_glm -i ${funcdir}/filtered_func_data.nii.gz -d ${resdir}/nuisance_confounds.mat -o ${resdir}/nuisance_coef.nii.gz --out_res=${resdir}/nuisance_residual.nii.gz

# Register to MNI

flirt -in ${resdir}/nuisance_residual_global.nii.gz -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask.nii.gz -out ${resdir}/nuisance_residual_global2standard.nii.gz -applyxfm -init ${regdir}/example_func2standard.mat

flirt -in ${resdir}/nuisance_residual.nii.gz -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask.nii.gz -out ${resdir}/nuisance_residual2standard.nii.gz -applyxfm -init ${regdir}/example_func2standard.mat
