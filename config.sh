#!/bin/bash
# Variables for running motif validation pipeline
export BINDIR=/seq/epiprod/epstein_c/Motif_Validation
export WEBDIR=/web/personal/$USER
export TMP=/broad/hptmp/${USER}
export WORKDIR=$TMP/working
export PATH=${BINDIR}/bin/:$PATH  # Add scripts to $PATH
mkdir -p $TMP $WORKDIR $TMP/motifpipeline


export JOBDATA_DIR=$WEBDIR/motifpipeline/jobdata
mkdir -p $WEBDIR $WEBDIR/motifpipeline ${JOBDATA_DIR}

# Get motif data if not there:
if [[ ! -e $WEBDIR/logo_pdf/ ]]; then
    cd $WEBDIR
    wget https://personal.broadinstitute.org/cboix/motif_data.tar.gz -O $WEBDIR/motif_data.tar.gz
    tar -xvzf motif_data.tar.gz
fi
