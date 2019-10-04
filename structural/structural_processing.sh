#!/bin/bash
#SBATCH --time=5-00:00:00 --mem=24gb
#
# Created by Kyle Murray
#

###############################
# Structural Image Processing #
###############################

subj=${1}
out=${2}

cd ${out}

# Load modules
module load fsl
module load freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export SUBJECTS_DIR=${out}/T1free

#######
# FSL #
#######

# T1 image
fsl_anat \
    -i T1/${subj}/t1.nii \
    -t T1 \
    -o T1/${subj}/t1

##############
# Freesurfer #
##############

recon-all \
    -subject ${subj} \
    -i T1/${subj}/t1.nii \
    -all
