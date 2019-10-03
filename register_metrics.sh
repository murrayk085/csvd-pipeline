#!/bin/bash

#~ND~FORMAT~MARKDOWN~
#~ND~START~
#
# # register_metrics.sh
#
# ## Author
#
# * Kyle D. Murray, Department of Physics
#   University of Rochester
#
# ## Description
#
# Perform linear and nonlinear registrations from native metric spaces 
#   to high-resolution structural space and 2mm MNI template space.
#
# ## Prerequisites
#
# * FSL
#
#~ND~END~

# Function: get_batch_options
# Desription
#
#   Retrieve the following command line parameter values if specified
#
#   --SubjectName=  - Subject Name
#   --StudyFolder=  - Study Folder
#

get_batch_options() {
    local arguments=($@)

    unset cls_subject_name
    unset cls_study_folder

    local index=0
    local numArgs=${#arguments[@]}
    local argument

    while [ ${index} -lt ${numArgs} ]; do
	argument=${arguments[index]}

	case ${argument} in
	    --SubjectName=*)
                cls_subject_name=${argument#*=}
	        index=$(( index + 1))
	        ;;
	    --StudyFolder=*)
	        cls_study_folder=${argument#*=}
		index=$(( index + 1 ))
		;;
	    *)
	        echo ""
		echo "ERROR: Unrecognized Option: ${argument}"
		echo ""
		exit 1
		;;
	esac
    done

    local error_count=0

    # Check required parameter
    if [ -z "${cls_subject_name}" ]; then
	echo "Subject Name (--SubjectName=) required"
	error_count=$(( error_count + 1 ))
	exit 1
    fi
}

# Function: main
# Description: main processing work of this script
main()
{
    get_batch_options "$@"

    # Set variable values
    subj=${cls_subject_name}
    out=${cls_study_folder}

    # Display variables
    echo "Script: register_metrics.sh"
    echo "Subject Name: ${subj}"
    echo "Study Folder: ${out}"

    # Check for output folders
    if [ ! -d ${out} ]; then
	echo "Study Folder does not exist."
	exit 1
    fi
    
    if [ ! -f ${out}/reg ]; then
	echo ${out}/reg
    fi
    
    if [ ! -f ${out}/reg/${subj} ]; then
	mkdir ${out}/reg/${subj}
	mkdir ${out}/reg/${subj}/DTI
	mkdir ${out}/reg/${subj}/QSM

	mkdir ${out}/reg/${subj}/DTI/native_space
	mkdir ${out}/reg/${subj}/DTI/struct_space
	mkdir ${out}/reg/${subj}/DTI/std_space

	mkdir ${out}/reg/${subj}/QSM/native_space
	mkdir ${out}/reg/${subj}/QSM/struct_space
	mkdir ${out}/reg/${subj}/QSM/std_space
    fi

    # Copy ASL metrics
    cp -r ${out}/ASL/${subj}/cbf ${out}/reg/${subj}/ASL

    # Define directory shortcuts
    dtidir=${out}/DTI/preproc/${subj}
    dkidir=${out}/DTI/DKE/${subj}
    noddidir=${out}/DTI/NODDI${subj}
    qsmdir=${out}/QSM/${subj}/results
    anatdir=${out}/T1/${subj}/t1.anat

    # Register metrics to each space (T1 and MNI152_2mm)
    for metric in qsm r2s dti_FA dti_MD dti_AD dti_RD dki_AK dki_MK dki_RK noddi_fiso noddi_ficvf noddi_odi; do
	if [ "${metric}" == "qsm" ] || [ "${metric}" == "r2s" ]; then
	    nativedir=${out}/reg/${subj}/QSM/native_space
	    structdir=${out}/reg/${subj}/QSM/struct_space
	    stddir=${out}/reg/${subj}/QSM/std_space
	    clevername=mag

	    # Copy Susceptibility metrics into native_space
	    if [ ! -f ${nativedir}/qsm.nii.gz ]; then
		cp ${qsmdir}/qsm.nii ${nativedir}/qsm.nii
		fslchfiletype NIFTI_GZ ${nativedir}/qsm.nii
	    fi
	    if [ ! -f ${nativedir}/r2s.nii.gz ]; then
		cp ${qsmdir}/r2s.nii ${nativedir}/r2s.nii
		fslchfiletype NIFTI_GZ ${nativedir}/r2s.nii
	    fi

	elif [ "${metric}" == "dti*" ] || [ "${metric}" == "dki*" ] || [ "${metric}" == "noddi*" ]; then
	    nativedir=${out}/reg/${subj}/DTI/native_space
	    structdir=${out}/reg/${subj}/DTI/struct_space
	    stddir=${out}/reg/${subj}/DTI/std_space
	    clevername=dti

	    # Copy Diffusion metrics into native_space
	    if [ ! -f ${nativedir}/dti_FA.nii.gz ]; then
		cp ${dtidir}/dti_FA.nii.gz ${nativedir}/dti_FA.nii.gz
	    fi
	    if [ ! -f ${nativedir}/dti_MD.nii.gz ]; then
		cp ${dtidir}/dti_MD.nii.gz ${nativedir}/dti_MD.nii.gz	    
	    fi
	    if [ ! -f ${nativedir}/dti_AD.nii.gz ]; then
		cp ${dkidir}/dki_AD.nii.gz ${nativedir}/dti_AD.nii.gz
	    fi
	    if [ ! -f ${nativedir}/dti_RD.nii.gz ]; then
		cp ${dkidir}/dki_RD.nii.gz ${nativedir}/dti_RD.nii.gz
	    fi
	    if [ ! -f ${nativedir}/dki_AK.nii.gz ]; then
		cp ${dkidir}/dki_AK.nii.gz ${nativedir}/dki_AK.nii.gz
	    fi
	    if [ ! -f ${nativedir}/dki_MK.nii.gz ]; then
		cp ${dkidir}/dki_MK.nii.gz ${nativedir}/dki_MK.nii.gz
	    fi
	    if [ ! -f ${nativedir}/dki_RK.nii.gz ]; then
		cp ${dkidir}/dki_RK.nii.gz ${nativedir}/dki_RK.nii.gz
	    fi
	    if [ ! -f ${nativedir}/noddi_fiso.nii.gz ]; then
		cp ${noddidir}/NODDI_out_fiso.nii ${nativedir}/noddi_fiso.nii
		fslchfiletype NIFTI_GZ ${nativedir}/noddi_fiso.nii
	    fi
	    if [ ! -f ${nativedir}/noddi_ficvf.nii.gz ]; then
		cp ${dtidir}/NODDI_out_ficvf.nii.gz ${nativedir}/noddi_ficvf.nii
		fslchfiletype NIFTI_GZ ${nativedir}/noddi_ficvf.nii
	    fi
	    if [ ! -f ${nativedir}/noddi_odi.nii.gz ]; then
		cp ${noddidir}/NODDI_out_odi.nii.gz ${nativedir}/noddi_odi.nii
		fslchfiletype NIFTI_GZ ${nativedir}/noddi_odi.nii
	    fi
	fi

	# Create Affine Matrix files for Linear Registration
	if [ ! -f ${structdir}/${clevername}2struct.mat ]; then
	    flirt \
		-in ${nativedir}/dti_FA.nii.gz \
		-ref ${anatdir}/T1_biascorr_brain.nii.gz \
		-omat ${structdir}/${clevername}2struct.mat
	fi
	
	# Register from Native to Structural Space
	if [ ! -f ${structdir}/${metric}.nii.gz ]; then
	    flirt \
		-in ${nativedir}/${metric}.nii.gz \
		-ref ${anatdir}/T1_biascorr_brain.nii.gz \
		-out ${structdir}/${metric}2struct.nii.gz \
		-applyxfm -init ${structdir}/${clevername}2struct.mat
	fi

	# Register from Structural to Standard Space
	if [ ! -f ${stddir}/${metric}2std.nii.gz ]; then
	    applywarp \
		--ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz \
		--in=${structdir}/${metric}2struct.nii.gz \
		--warp=${anatdir}/T1_to_MNI_nonlin_field.nii.gz \
		--out=${stddir}/${metric}2std.nii.gz
	fi
	# Apply brain masks to images
	if [ ! -f ${structdir}/${metric}2struct_brain.nii.gz ]; then
	    fslmaths ${structdir}/${metric}2struct.nii.gz -mul ${anatdir}/T1_biascorr_brain_mask.nii.gz ${structdir}/${metric}2struct_brain.nii.gz
	fi
	if [ ! -f ${stddir}/${metric}2std_brain.nii.gz ]; then
	    fslmaths ${stddir}/${metric}2std.nii.gz -mul ${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask.nii.gz ${stddir}/${metric}2std_brain.nii.gz
	fi