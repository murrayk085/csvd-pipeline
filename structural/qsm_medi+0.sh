#!/bin/bash
#SBATCH --time=2:00:00 --mem=24gb
#
# Created by Kyle Murray
#
# Batch process QSM data with MEDI Toolbox
# Call this from QSM folder on HPC
#

#module load matlab

subj=${1}
out=${2}
scriptsdir=/path/to/scripts

cp ${scriptsdir}/csvd_qsm.m ${out}/QSM/${subj}/
 
cd ${out}/QSM/${subj}

/Applications/MATLAB_R2018a.app/bin/matlab -r csvd_qsm
