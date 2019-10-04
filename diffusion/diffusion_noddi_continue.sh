#!/bin/bash
#SBATCH --time=5-00:00:00 --mem=24gb

subj=${1}
out=${2}

cd ${out}/DTI/NODDI/${subj}

module load matlab

matlab -r csvd_noddi
