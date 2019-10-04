#!/bin/sh
#
#Created by Kyle Murray
#
#Create a directory for the masks for each subject.
#Create masks for the segmented regions of interest using fslplit.
#Correctly name each region of interest.

for i in $(cat file); 
do 
    echo ${i}
    mkdir masks/struct_space/${i}
    cp T1/${i}/T1.anat/first_results/*origsegs.nii.gz masks/struct_space/${i}/origsegs.nii.gz
    cd masks/struct_space/${i}
    fslsplit origsegs.nii.gz
    mv ./*0000.nii.gz ./L_ACC.nii.gz
    mv ./*0001.nii.gz ./L_AMY.nii.gz
    mv ./*0002.nii.gz ./L_CAU.nii.gz
    mv ./*0003.nii.gz ./L_HIP.nii.gz
    mv ./*0004.nii.gz ./L_PAL.nii.gz
    mv ./*0005.nii.gz ./L_PUT.nii.gz
    mv ./*0006.nii.gz ./L_THA.nii.gz
    mv ./*0007.nii.gz ./R_ACC.nii.gz
    mv ./*0008.nii.gz ./R_AMY.nii.gz
    mv ./*0009.nii.gz ./R_CAU.nii.gz
    mv ./*0010.nii.gz ./R_HIP.nii.gz
    mv ./*0011.nii.gz ./R_PAL.nii.gz
    mv ./*0012.nii.gz ./R_PUT.nii.gz
    mv ./*0013.nii.gz ./R_THA.nii.gz
    mv ./*0014.nii.gz ./brain_stem.nii.gz

    for j in ACC AMY CAU HIP PAL PUT THA;
    do
        fslmaths L_${j}.nii.gz -add R_${j}.nii.gz ${j}.nii.gz
        fslmaths ${j}.nii.gz -bin ${j}_mask.nii.gz
    done
    cd ../../../
done

