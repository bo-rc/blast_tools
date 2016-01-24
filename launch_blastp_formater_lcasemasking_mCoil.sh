#!/bin/bash

# try all the evalues in the following list
for e in 1 0.01
do
~/Projects/blast/blast_tools/blastp_formater.sh \
    --input-fasta unknown_mCoilTransm.fasta \
    --output-filename unknown-mCoilTransm \
    --database Ecoli.fasta \
    --clean 1 \
    --evalue $e \
    --num-report-hits 3 \
    --backward-search 0 \
    --num-threads 6
done

for e in 1 0.01
do
~/Projects/blast/blast_tools/blastp_formater.sh \
    --input-fasta unknown_mCoilTransm.fasta \
    --output-filename unknown-mCoilTransm \
    --database Bsubtilis168.fasta \
    --clean 1 \
    --evalue $e \
    --num-report-hits 3 \
    --backward-search 0 \
    --num-threads 6
done

for e in 1 0.01
do
~/Projects/blast/blast_tools/blastp_formater.sh \
    --input-fasta unknown_mCoilTransm.fasta \
    --output-filename unknown-mCoilTransm \
    --database mycoplasma.fasta \
    --clean 1 \
    --evalue $e \
    --num-report-hits 3 \
    --backward-search 0 \
    --num-threads 6
done
