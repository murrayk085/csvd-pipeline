#!/bin/bash

# Written by Arun Venketaraman

cd $1
fmri_slices=$(fslhd fun.nii | grep -m 1 'dim3' | sed 's/dim3//')
start=$(cat fun.json | grep -n "SliceTiming" | sed 's/:.*//')
mb_factor=8
sed -n "$(( ${start} + 1 )),$(( ${start} + ${fmri_slices} ))p" fun.json > slice_timing_fmri.txt
read -d '' -r -a slc_time < slice_timing_fmri.txt
IFS=$'\n' sorted=($(sort <<<"${slc_time[*]}"))
unset IFS
ind=1
if [ -e slice_list_fmri.txt ]
then
  rm -f slice_list_fmri.txt
fi
touch slice_list_fmri.txt
while [ ${ind} -lt $(( ${#slc_time[@]} - 1 )) ]
do
  value=${sorted[${ind}]}
  value=${value%?}
  num=0
  for i in "${!slc_time[@]}"
  do
    if [ "${slc_time[$i]}" = "${value}" ] || [ "${slc_time[$i]}" = "${value}," ]
    then
      tmp[num]=${i}
      num=$(( ${num} + 1 ))
    fi
  done
  echo ${tmp[@]} >> slice_list_fmri.txt
  unset tmp
  ind=$(( ${ind} + ${mb_factor} ))
done
read -d '' -r -a slc < slice_list_fmri.txt
ind=0
j=0
while [ ${ind} -lt $(( ${fmri_slices} - 1 )) ]
do
i=0
while [ ${i} -lt ${mb_factor} ]
do
tmp[${slc[${ind}]}]=$(bc <<< "scale=4; (4 - ${j})/9")
i=$(( ${i} + 1 ))
ind=$(( ${ind} + 1 ))
done
j=$(( ${j} + 1 ))
done 
printf '%s\n' "${tmp[@]}" > slice_time_fmri.txt
rm -rf slice_timing_fmri.txt
