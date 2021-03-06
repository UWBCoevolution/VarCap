#!/bin/bash

module load vmatch

REGEX_FILTER=$1
MRA=$2
CURR_WD=$( pwd | sed 's/\/$//')

# collect variants
for file in $( ls -d */ | grep -Ev 'reference|batch|bwa_index' |grep -E "${REGEX_FILTER}" ); do 
  echo $file;
  # create projects
  cd $CURR_WD/$file
  
  # 1. check for variant calling jobs
  if  ls logs/SLURM_C01* 1> /dev/null 2>&1 ; then
    JOBLIST=$( cat logs/SLURM_C01* | grep -o 'Submitted batch job [0-9]\+' | cut -d" " -f4 | tr "\n" ":" | sed 's/:$//' )
  else
    # echo "$( ls ${PATH_LOGS} )"
    echo -e "VARCAP_EXIT: No mapping job_id, in $PATH_LOGS/SLURM_C01* found.\nAssuming no mapping: Exiting.\n"
    # exit 1
  fi
  
  # 2. if supplied set MRA, else use from config file
  if [[ -z $MRA ]]; then
    MRA=$( cat variant.config | grep -e '^MRA=' | cut -d'=' -f2 )
  fi
  
  # 3. run scripts
  bash D01_collect_raw_variant_files.sh
  bash D02_filter_vcf.sh $MRA

done
