#!/bin/bash
#SBATCH --time=5-00:00:00 --mem=24gb
#
# Created by Kyle Murray
#
# Process CSVD data through NODDI Pipeline
#

subj=${1}
out=${2}
scriptsdir=path/to/scripts

cd ${out}

# Copy all relevant preprocessed DTI data to NODDI folder and name them according to csvd_noddi.m
cp DTI/preproc/${subj}/bvals DTI/NODDI/${subj}/NODDI_protocol.bval
cp DTI/preproc/${subj}/eddy_unwarped_images.eddy_rotated_bvecs DTI/NODDI/${subj}/NODDI_protocol.bvec
cp DTI/preproc/${subj}/eddy_unwarped_images.nii.gz DTI/NODDI/${subj}/NODDI_DWI.nii.gz
cp DTI/preproc/${subj}/hifi_nodif_brain_mask.nii.gz DTI/NODDI/${subj}/brain_mask.nii.gz

# Copy NODDI MATLAB script to subject folder
cp ${scriptsdir}/csvd_noddi.m DTI/NODDI/${subj}/csvd_noddi.m

cd ${out}/DTI/NODDI/${subj}

# Unzip *.nii.gz, we only need *.nii images
gunzip brain_mask.nii.gz

gunzip NODDI_DWI.nii.gz

# Run NODDI
module load matlab

matlab -r csvd_noddi
