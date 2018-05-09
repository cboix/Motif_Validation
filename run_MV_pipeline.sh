#!/bin/bash
# Motif validation pipeline:
# Run with the following options:
# TODO update for ce:
# BINDIR=/broad/compbio/cboix/MOTIF_VALIDATION/
# mkdir -p $BINDIR/out
# SCHEDOPT="-l h_vmem=30G -l h_rt=05:00:00 -j y -b y -V -r y -N MVpipe_${DESC}"
# qsub -cwd -t 1-$NUM ${SCHEDOPT} -o $BINDIR/out "$BINDIR/run_MV_pipeline.sh ${INFOFILE}"

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
eval $( awk -vOFS="\t" -F "\t" -f $BINDIR/by_header.awk -v cols="UID,Alignment Post Processing:Epitopes,BED Filename" $INFOFILE | sed "${TASK}q;d" - | awk '{printf("EID=%s; EPITOPE=%s; BEDFILE=%s;\n",$1,$2,$3)}' )
# TagFormat (must be): AbName_TFName_ExperimentID_TFName.bed 
# TODO Process antibody name
export TAG=${EPITOPE}_${EPITOPE}_${EID}_${EPITOPE}.bed
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
cd $BINDIR/pipeline_script
source activate mv_env;
# Update paths so that miniconda libraries are first:
export PATH=${MINICONDA_PATH}/bin/:$PATH
export LD_LIBRARY_PATH=${MINICONDA_PATH}/lib/:$LD_LIBRARY_PATH
export LIBRARY_PATH=${MINICONDA_PATH}/lib/:$LIBRARY_PATH
# Run pipeline:
python ${BINDIR}/pipeline_script/pipeline.py ${WORKDIR}/${TAG}.bed $GENOME $TOPN $USER
# Leave environment:
source deactivate

# --------------------------------
# 3. Put visualization on the web:
# --------------------------------
cp -r ${TMP}/motifpipeline/${TAG} ${WEBDIR}/motifpipeline/jobdata/

# Timing info:
end=`date +%s`
runtime=$((end-start))
echo "Finished run $TASK of $INFOFILE sucessfully in $runtime seconds."
