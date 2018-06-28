#!/bin/bash
# ---------------------------------------------------------------------------------------
# Motif validation pipeline qsub array submission script
# Grid Engine options:
#$ -N MV_pipeline
#$ -cwd
#$ -l h_vmem=30G 
#$ -l h_rt=05:00:00
#$ -j y
#$ -b y 
#$ -V 
#$ -r y 
#$ -o /seq/epiprod/epstein_c/out_MV
#$ -e /seq/epiprod/epstein_c/out_MV
#$ -t 1-2 # NOTE: Number of lines in script goes here
# ---------------------------------------------------------------------------------------
# Alternatively, run as follows:
# bash
# INFOFILE="FILEHERE"
# NUM="1-5" # Range of lines to run
# SCHEDOPT="-l h_vmem=30G -l h_rt=05:00:00 -j y -b y -V -r y -N MVpipe"
# qsub -cwd -t 1-$NUM ${SCHEDOPT} -o $BINDIR/out "$BINDIR/run_MV_pipeline.sh ${INFOFILE}"
# BINDIR=/seq/epiprod/epstein_c/Motif_Validation/
# ---------------------------------------------------------------------------------------

# ----------------------------------------------------------
# 0. If the following environment does not exist, create it:
# conda create --name mv_env python=2.7 r-essentials r-base scipy scikit-learn numpy matplotlib 
# ----------------------------------------------------------
start=`date +%s` # For timing the pipeline
source config.sh  # Environment variables

if [[ $# -lt 1 ]]
    then
    echo "USAGE: $(basename $0) [INFOFILE] (optional [TASK])" >&2
    echo '  [INFOFILE]: Must include TFName, BED Filename, and UID for the dataset' >&2
    echo '  [TASK]: (OPTIONAL) line from file to run. Otherwise runs $SGE_TASK_ID)' >&2
    exit 1
fi
INFOFILE=$1

if [[ $# -gt 1 ]]
then
    TASK=$2
else
    TASK=${SGE_TASK_ID}
fi

# ------------------------------------------------------------
# 1. Process information for dataset (BED File):
# Reads record corresponding to $TASK ($SGE_TASK_ID or $2)
# Takes the following information from the information bedfile:
# EID="UID"
# EPITOPE="Alignment Post Processing:Epitopes"
# BEDFILE="BED Filename"
# ------------------------------------------------------------
eval $( awk -vOFS="\t" -F "," -f $BINDIR/by_header.awk -v cols="UID,Alignment Post Processing:Epitopes,BED Filename" $INFOFILE | sed "${TASK}q;d" - | awk '{printf("EID=%s; EPITOPE=%s; BEDFILE=%s;\n",$1,$2,$3)}' )
# NOTE: Can include antibody name if needed.
# TagFormat (must be): AbName_TFName_ExperimentID_TFName
export TAG=${EPITOPE}_${EPITOPE}_${EID}_${EPITOPE}
cp $BEDFILE ${WORKDIR}/${TAG}.bed

# ---------------------------------------------------
# 2. Run pipeline:
# Bedfiles should be sorted from weak to strong peaks 
# Currently not the case with CE's data.
# Arguments:
# - Bedfile
# - Genome (hg19, mm10)
# - topN (10000)
# - Username
# ---------------------------------------------------
# Must be in script directory for dir variables to work properly:
cd $BINDIR/pipeline_script
source activate mv_env;
# Update paths so that miniconda libraries are first:
MINICONDA_PATH=$HOME/.conda/envs/mv_env
export PATH=${MINICONDA_PATH}/bin/:$PATH
export LD_LIBRARY_PATH=${MINICONDA_PATH}/lib/:$LD_LIBRARY_PATH
export LIBRARY_PATH=${MINICONDA_PATH}/lib/:$LIBRARY_PATH
GENOME="hg19"
TOPN=10000
# Run pipeline:
python ${BINDIR}/pipeline_script/pipeline.py ${WORKDIR}/${TAG}.bed $GENOME $TOPN $USER
# Leave environment:
source deactivate

# --------------------------------
# 3. Put visualization on the web:
# --------------------------------
cp -r ${TMP}/motifpipeline/${TAG} ${JOBDATA_DIR}

# Timing info:
end=`date +%s`
runtime=$((end-start))
echo "Finished run $TASK of $INFOFILE sucessfully in $runtime seconds."
