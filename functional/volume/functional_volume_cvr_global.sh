#!/bin/sh

subj=${1}
out=${2}
scriptsdir=path/to/scripts

featdir=${out}/Fun/${subj}/preproc.feat

cd ${out}/Fun/${subj}

mkdir cvr
mkdir cvr/native_space
mkdir cvr/std_space

cp preproc.feat/filtered_func_data.nii.gz cvr/native_space/func_data.nii.gz
cp preproc.feat/filtered_func_data.nii.gz cvr/std_space/func_data_native.nii.gz

# CVR calculation in Native Space

cd cvr/native_space

# Threshold func_data for global signal mask
fslmaths func_data.nii.gz -thr 7500 func_data_brain.nii.gz
fslmaths func_data_brain.nii.gz -bin global_mask.nii.gz

# Create "Final" BOLD signal
fslmaths func_data_brain.nii.gz -Tmean func_data_mean.nii.gz
fslmaths func_data_brain.nii.gz -sub func_data_mean.nii.gz func_data_num.nii.gz
fslmaths func_data_num.nii.gz -div func_data_mean.nii.gz func_final.nii.gz

# Prepare Global Signal regression
# Create global average time course
fslmeants -i func_final.nii.gz -o global_final_ts.txt -m global_mask.nii.gz
Text2Vest global_final_ts.txt global_final_ts.mat

#Perform regression
fsl_glm -i func_final.nii.gz -d global_final_ts.mat -o cvr_final_global.nii.gz

# CVR calucation in standard space

cd ../std_space

# Register to MNI
flirt -in func_data_native.nii.gz -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz -out func_data.nii.gz -applyxfm -init ${featdir}/reg/example_func2standard.mat

# Create Func Brain
fslmaths func_data.nii.gz -mul ${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask.nii.gz func_data_brain.nii.gz


# Create "Final" BOLD signal
fslmaths func_data_brain.nii.gz -Tmean func_data_mean.nii.gz
fslmaths func_data_brain.nii.gz -sub func_data_mean.nii.gz func_data_num.nii.gz
fslmaths func_data_num.nii.gz -div func_data_mean.nii.gz func_final.nii.gz

# Prepare Global Signal regression                                                           
# Create global average time course                                                   
fslmeants -i func_final.nii.gz -o global_final_ts.txt -m ${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask.nii.gz
Text2Vest global_final_ts.txt global_final_ts.mat

# Perform regression for CVR index                                                                        
fsl_glm -i func_final.nii.gz -d global_final_ts.mat -o cvr_final_global.nii.gz

# Normalize CVR index
fslmaths cvr_final_global.nii.gz -div `fslstats cvr_final_global.nii.gz -M` cvr_final_global_norm.nii.gz

# Demedian CVR
cp ${scriptsdir}/csvd_mednorm.sh ./

./csvd_mednorm.sh
