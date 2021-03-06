#!/bin/bash

# SLURM
#SBATCH --job-name=wVCCcor
#SBATCH --cpus-per-task=2
#SBATCH --mem=12000
#SBATCH --nice=1000
#SBATCH --license=scratch-highio
#SBATCH --output=cortex-%A_%a.out
#SBATCH --error=cortex-%A_%a.err

. /etc/profile

# read config file(variant.config) within the same directory
CURRENT_DIR=$(pwd)
# open project specific config file
CONFIG_FILE=$CURRENT_DIR/variant.config
. $CONFIG_FILE
# open system/program settings config file in varcap main dir
SYSTEM_CONFIG=${PATH_VARCAP}/program.config
. $SYSTEM_CONFIG

BAM_MOD=$1
OUTDIR=$2
i=$3
BAM_BASE=$4


# prepare files
echo "Create cortex dir: $PATH_CORTEX_DATA"
mkdir -p $PATH_CORTEX_DATA

mkdir -p $PATH_CORTEX_DATA/$OUTDIR
mkdir -p $PATH_CORTEX_DATA/$OUTDIR/$BAM_BASE.$i
cd $PATH_CORTEX_DATA/$OUTDIR
## replace/add read group header
java -Xmx4g -Djava.io.tmpdir=/tmp -jar $PATH_PICARD/picard.jar AddOrReplaceReadGroups I=$BAM_MOD O=${BAM_BASE}${i}.rgroup.bam LB=D PL=illumina PU=S SM=B VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=false
##convert bam file to fastq reads
java -jar -Xmx3g $PATH_PICARD/picard.jar SamToFastq INPUT=${BAM_BASE}${i}.rgroup.bam FASTQ=${BAM_BASE}${i}_1.fastq SECOND_END_FASTQ=${BAM_BASE}${i}_2.fastq INCLUDE_NON_PF_READS=true VALIDATION_STRINGENCY=SILENT

# run cortex
bash $PATH_SCRIPTS/run_cortex.sh  $PATH_CORTEX_DATA/$OUTDIR/${BAM_BASE}${i}_1.fastq $PATH_CORTEX_DATA/$OUTDIR/${BAM_BASE}${i}_2.fastq $PATH_CORTEX_DATA/$OUTDIR/$BAM_BASE.$i $PATH_CORTEX_DATA \
$REF_FA $PATH_VCFTOOLS $PATH_STAMPY $PATH_CORTEX_DIR $PATH_CORTEX $PATH_RUN_CALLS $PATH_SCRIPTS

rm ${BAM_BASE}${i}.rgroup.bam
