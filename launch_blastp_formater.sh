#!/bin/bash

# try all the evalues in the following list
for db in "nr_prokaryotes"
do
  for e in 0.0001
  do
    ~/Projects/blast/blast_tools/blastp_formater.sh \
    --input-fasta unknown8.fasta \
    --output-filename blastp \
    --database $db \
    --clean 1 \
    --evalue $e \
    --num-report-hits 3 \
    --backward-search 1 \
    --num-threads 6 
  done
done
