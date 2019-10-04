#!/bin/bash
#SBATCH --time=5-00:00:00 --mem=24gb
#


subj=${1}
out=${2}

SUBJECTS_DIR=${out}/T1free

# Prepare FSFAST analyses
cd ${out}

#Prepare FSFAST Analysis Directory
mkdir FunDiff/${subj}

# Determine BOLD run number
dcmunpack -src ./Funraw/${subj} -index-out Funfree/${subj}/dcm.inddex.dat | grep -E 'series:' | sed 's/Found\ 1\ unique\ series: //' > Funfree/${subj}/tmp

read -d '' -r -a temp < FunDiff/${subj}/tmp

# Create directory for subject
dcmunpack -src ./Funraw/${subj} -targ ./Funfree/${subj} -run `echo $temp` bold nii f.nii

# Clean-up
rm Funfree/${subj}/tmp
rm Funfree/${subj}/dcm.inddex.dat

# Connect functional data to SUBJECTS_DIR
echo "$subj" > Funfree/${subj}/subjectname

cd FunDiff

# Preprocess Functional Data
preproc-sess -s ${subj} -sdf ${out}/Fun/${subj}/slice_time_fmri.txt -fwhm 5 -surface fsaverage lhrh -mni305-2mm -per-run -fsd bold

# Create nuisance regressors
fcseed-sess -s ${subj} -cfg wm.config

fcseed-sess -s ${subj} -cfg vcsf.config

# Perform Regressions to leave residual hemispheres
selxavg3-sess -s ${subj} -s ${subj} -a lh.nuisance

selxavg3-sess -s ${subj} -s ${subj} -a rh.nuisance

