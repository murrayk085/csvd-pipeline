#!/bin/sh
#SBATCH --time=5-00:00:00 --mem=24gb
#

# Start in Subject analysis directory.

subj=${1}
out=${2}
ox=~/Desktop/oxford_asl

#module load fsl

cd ${out}/ASL/${subj}

# Separate data into individual time delays
fslroi asl.nii asl_noise.nii.gz 86 2
fslroi asl.nii asl_m0.nii.gz 88 2

# Create average m0 image for calibration
fslmaths asl_m0.nii.gz \
    -Tmean asl_m0_avg.nii.gz

fslroi asl.nii.gz asl_tag_control.nii.gz 0 86

# quantify perfusion in absolute units (ml/100g/min) then the next step is to invert the kinetic model
#Labelling was performed for 1.5 seconds (--bolus 1.5).
#The post-labeling delay was 0.2, 0.7, 1.2, 1.7, 2.2 seconds.

# The post-labelling delay corresponds to an 'inversion time' of 1.7 seconds, i.e. 1.5 + 0.2.... Thus we set --tis 1.7 - this is the list of TIs, where we only have one in this case). 
#Here we have data with only a single delay (and BASIL includes various features for multi-delay data) - oxford_asl sets a number of other options that are appropriate for single delay data (--artoff --fixbolus). 

${ox}/oxford_asl \
    -i asl_tag_control.nii.gz \
    -c asl_m0_avg.nii.gz \
    --iaf tc \
    --ibf tis \
    --tis 1.7,1.7,1.7,1.7,1.7,1.7,2.2,2.2,2.2,2.2,2.2,2.7,2.7,2.7,2.7,2.7,2.7,3.2,3.2,3.2,3.2,3.2,3.2,3.2,3.2,3.2,3.2,3.2,3.7,3.7,3.7,3.7,3.7,3.7,3.7,3.7,3.7,3.7,3.7,3.7,3.7,3.7,3.7 \
    -o cbf2 \
    --bolus 1.5 \
    --bat 0.7 \
    --spatial \
    --casl \
    --sliceband 6 \
    --fslanat ${out}/T1/${subj}/t1.anat
