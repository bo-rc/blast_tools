#!/bin/bash

# try all the evalues in the following list
for e in 0.01 0.005 0.001
do
./blastp_formater.sh \
    --input-fasta M_myc_aaRS.txt \
    --output-filename report \
    --database Ecoli.fasta \
    --clean \
    --num-report-hits 2 \
    --evalue $e
done
