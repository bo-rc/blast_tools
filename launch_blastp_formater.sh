#!/bin/bash

for e in 0.01
do
./blastp_formater.sh \
    --input-fasta M_myc_aaRS.txt \
    --output-filename report \
    --database Ecoli.fasta \
    --clean \
    --num-report-hits 2 \
    --evalue $e
done
