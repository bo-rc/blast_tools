#!/bin/bash

# try all the evalues in the following list
for e in 0.01
do
~/Projects/blast/blast_tools/blastp_formater.sh \
    --input-fasta M_myc_aaRS.fasta \
    --output-filename report-back-full \
    --database Ecoli.fasta \
    --clean 1 \
    --evalue $e \
    --num-report-hits 1 \
    --backward-search 1 \
    --num-threads 6 
done
