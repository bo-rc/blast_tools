#!/bin/bash

# try all the evalues in the following list
for e in 0.01 0.005 0.001
do
~/Projects/blast/blast_tools/blastp_formater.sh \
    --input-fasta M_myc_aaRS.fasta \
    --output-filename test-report \
    --database Ecoli.fasta \
    --clean \
    --evalue $e \
    --num-report-hits 1 \
    --num-threads 6 \
    --backward-search
done
