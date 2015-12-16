#!/bin/bash

for e in 0.01 0.005 0.001 0.0005 0.0001
do
./blastp_formater.sh \
    --input-fasta M_myc_aaRS.txt \
    --output-filename report \
    --database Ecoli.fasta \
    --evalue $e
done
