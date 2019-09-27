#!/bin/bash

#~ND~FORMAT~MARKDOWN~
#~ND~START~
#
# # QualityControlAll.sh
#
# ## Author
#
# * Kyle D. Murray, Department of Physics
#   University of Rochester
#
# ## Description:
#
# Perform automated portion of quality control on CSVD datasets directly from the data server.
#
# ## Prerequisites
#
# * dcm2niix
#
#~ND~END~

# Function: get_batch_options
# Description
#
#   Retrieve the following command line parameter values if secified
#
#   --SubjectFolder=  - subject data folder containing all scanner data
#   --NiftiFolder=    - location to create output folder
#

get_batch_options() {
    local arguments=($@)

    unset command_line_specified_subject_folder
    unset command_line_specified_nifti_folder

    local index=0
    local numArgs=${#arguments[@]}
    local argument

    while [ ${index} -lt ${numArgs} ]; do
	argument=${arguments[index]}

	case ${argument} in
	    --SubjectFolder=*)
                command_line_specified_subject_folder=${argument#*=}
		index=$(( index + 1 ))
		;;
	    --SubjectDIR=*)
	        command_line_specified_subject_folder=${argument#*=}
		index=$(( index + 1 ))
		;;
	    --NiftiFolder=*)
	        command_line_specified_nifti_folder=${argument#*=}
		index=$(( index + 1 ))
		;;
	    --NiftiDIR=*)
	        command_line_specified_nifti_folder=${argument#*=}
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
    if [ -z "${command_line_specified_subject_folder}" ]; then
	echo "Subject Directory (--SubjectFolder= or --SubjectDIR=) required"
	error_count=$(( error_count + 1 ))
	exit 1
    fi
}

# Function: main
# Description: main processing work of this script
main()
{
    get_batch_options "$@"

    # Set variable values that locate and specificy data and output location
    SubjectDIR="${command_line_specified_subject_folder}"
    RootDIR=`echo ${SubjectDIR} | cut -d "/" -f1-3`
    Study=`echo ${SubjectDIR} | rev | cut -d "/" -f3 | rev `
    NiftiDIR="${RootDIR}/${Study}/NIFTI_${Study}"

    #Use optional named output location
    if [ -n "${command_line_specified_nifti_folder}" ]; then
	NiftiDIR=${command_line_specified_nifti_folder}
    fi

    subdir=`echo ${SubjectDIR} | rev | cut -d "/" -f1 | rev `
    if [ "${Study}" == "CSVD" ]; then
	SubjectID=`echo $subdir | head -c 5`
    else
	SubjectID=`echo $subdir | head -c 4`
    fi

    visitvar=`echo -n $subdir | tail -c 3`

    echo ${visitvar}

    if [ "${Study}" == "CSVD" ]; then
	if [ "${visitvar}" == "TRY" ]; then
	    Visit="Baseline"
	    Sequences="T1 FLAIR DTI ASL BOLD T2 QSM fmaps"
	elif [ "${visitvar}" == "18M" ]; then
	    Visit="18 Months"
	    Sequences="T1 FLAIR DTI ASL BOLD fmaps"
	else
	    echo "Visit is not valid."
	    exit 1
	fi
    elif [ "${Study}" == "PrEP" ]; then
	Visit="Baseline"
	Sequences="T1 DTI ASL BOLD fmaps"
    fi

    echo "Study: ${Study}"
    echo "SubjectDIR: ${SubjectDIR}"
    echo "NiftiDIR: ${NiftiDIR}"
    echo "SubjectID: ${SubjectID}"
    echo "Visit: ${Visit}"

    # Check for or create output folder
    if [ -d ${NiftiDIR}/${subdir} ]; then
	echo "Subject folder already exists."
	exit 1
    else
	echo "Creating subject folder."
    fi

    mkdir ${NiftiDIR}/${subdir}
    OutDIR=${NiftiDIR}/${subdir}
    
    # Convert dicoms to nifti and check for correct conversion
    for seq in $Sequences; do
	if [ "${seq}" == "T1" ]; then
	    dcm2niix -f T1 -o ${OutDIR}/ ${SubjectDIR}/*/*t1_mprage*
	    echo "`fslinfo ${OutDIR}/T1.nii`" > ${OutDIR}/temp.txt
	    tmp=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim1' | sed 's/dim1//')
	    if [ $tmp != 192 ]; then echo "T1 dimensions are not correct." >> ${OutDIR}/qc_issues.txt; fi
	fi
	if [ "${seq}" == "T2" ]; then
            dcm2niix -f T2 -o ${OutDIR}/ ${SubjectDIR}/*/*axial_t2*
            echo "`fslinfo ${OutDIR}/T2.nii`" > ${OutDIR}/temp.txt
            tmp=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim3' | sed 's/dim3//')
            if [ $tmp != 27 ]; then echo "T2 dimensions are not correct." >> ${OutDIR}/qc_issues.txt; fi
	fi
	if [ "${seq}" == "FLAIR" ]; then
            dcm2niix -f FLAIR -o ${OutDIR}/ ${SubjectDIR}/*/*3d_flair
            echo "`fslinfo ${OutDIR}/FLAIR.nii`" > ${OutDIR}/temp.txt
            tmp=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim1' | sed 's/dim1//')
            if [ $tmp != 192 ]; then echo "FLAIR dimensions are not correct." >> ${OutDIR}/qc_issues.txt; fi
        fi
	if [ "${seq}" == "ASL" ]; then
            dcm2niix -f ASL -o ${OutDIR}/ ${SubjectDIR}/*/*mbPCASL*
            echo "`fslinfo ${OutDIR}/ASL.nii`" > ${OutDIR}/temp.txt
            tmp=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim3' | sed 's/dim3//')
	    tmp2=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim4' | sed 's/dim4//')
            if [ $tmp != 60 ] && [ $tmp != 72 ]; then echo "ASL dimensions are not correct." >> ${OutDIR}/qc_issues.txt; fi
        fi
	if [ "${seq}" == "BOLD" ]; then
            dcm2niix -f BOLD -o ${OutDIR}/ ${SubjectDIR}/*/*bold_s6*
            echo "`fslinfo ${OutDIR}/BOLD.nii`" > ${OutDIR}/temp.txt
            tmp=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim3' | sed 's/dim3//')
	    tmp2=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim4' | sed 's/dim4//')
            if [ $tmp != 72 ] && [ $tmp != 300 ]; then echo "BOLD dimensions are not correct." >> ${OutDIR}/qc_issues.txt; fi
        fi
	if [ "${seq}" == "QSM" ]; then
            dcm2niix -f QSM -o ${OutDIR}/ ${SubjectDIR}/*/2?.AdjGre
            echo "`fslinfo ${OutDIR}/QSM_e1.nii`" > ${OutDIR}/temp.txt
            tmp=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim3' | sed 's/dim3//')
            if [ $tmp != 64 ]; then echo "QSM dimensions are not correct." >> ${OutDIR}/qc_issues.txt; fi
        fi
	if [ "${seq}" == "fmaps" ]; then
	    dcm2niix -f fmaps_AP -o ${OutDIR}/ ${SubjectDIR}/*/*2mm_AP
	    dcm2niix -f fmaps_PA -o ${OutDIR}/ ${SubjectDIR}/*/*2mm_PA
	fi
	if [ "${seq}" == "DTI" ]; then
            dcm2niix -f DTI_b0 -o ${OutDIR}/ ${SubjectDIR}/*/*PA_b0
	    dcm2niix -f DTI_b1000 -o ${OutDIR}/ ${SubjectDIR}/*/*AP_b1000
	    dcm2niix -f DTI_b2000 -o ${OutDIR}/ ${SubjectDIR}/*/*AP_b2000
            echo "`fslinfo ${OutDIR}/DTI_b0.nii`" > ${OutDIR}/temp.txt
            tmp=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim3' | sed 's/dim3//')
            tmp2=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim4' | sed 's/dim4//')
            if [ $tmp != 96 ] && [ $tmp2 != 3]; then echo "DTI_b0 dimensions are not correct." >> ${OutDIR}/qc_issues.txt; fi
            echo "`fslinfo ${OutDIR}/DTI_b1000.nii`" > ${OutDIR}/temp.txt
            tmp=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim3' | sed 's/dim3//')
            tmp2=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim4' | sed 's/dim4//')
            if [ $tmp != 96 ] && [ $tmp2 != 71]; then echo "DTI_b1000 dimensions are not correct." >> ${OutDIR}/qc_issues.txt; fi
	    echo "`fslinfo ${OutDIR}/DTI_b2000.nii`" > ${OutDIR}/temp.txt
            tmp=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim3' | sed 's/dim3//')
            tmp2=$(cat ${OutDIR}/temp.txt | grep -m 1 'dim4' | sed 's/dim4//')
            if [ $tmp != 96 ] && [ $tmp2 != 71]; then echo "DTI_b2000 dimensions are not correct." >> ${OutDIR}/qc_issues.txt; fi
	fi
    done

    # Clean up
    rm ${OutDIR}/temp.txt
}

# Invoke the main function to start script
main "$@"

echo "Complete"
exit 0