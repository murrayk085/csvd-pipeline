#!/bin/bash
#SBATCH --time=5-00:00:00 --mem=24gb

subj=${1}
out=${2}
otherdir=path/to/csvd_process/other

${otherdir}/fmri/slice_time_mb_fmri.sh ${out}/Fun/${subj}

cd ${out}/fmaps/${subj}

# Prepare fieldmaps for fieldmap correction

fslmerge -t fmaps_merged fun_AP.nii fun_PA.nii
topup --imain=fmaps_merged.nii.gz --datain=${otherdir}/fmaps/datain.txt --config=b02b0.cnf --fout=my_fieldmap --iout=se_epi_unwarped
fslsplit my_fieldmap.nii.gz
mv vol0000.nii.gz my_fieldmap.nii.gz
mv vol0001.nii.gz extramap.nii.gz
fslmaths my_fieldmap.nii.gz -mul 6.28 my_fieldmap_rads
fslmaths fmaps_merged.nii.gz -Tmean my_fieldmap_mag
bet2 my_fieldmap_mag.nii.gz my_fieldmap_mag_brain

cd ../../Fun/${subj}

# Prepare feat design file

cp ${otherdir}/fmri/design.fsf ./design.fsf
sed -i -e "s/subjectname/${subj}/g" design.fsf

# Run FEAT

feat design.fsf
