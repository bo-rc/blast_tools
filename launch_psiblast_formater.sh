#!/bin/bash

# Here is your local database path
export BLASTDB="$HOME/blast/db"

# At least one profile database must be set
# Different databases can be used to construct an initial profile.
# You can use the same database as profile PSSM building and target
# which means:
#     1. Use the target database for initial profile construction.
#     2. The first iteration of psiblast uses standard scoring matrix,
#        effectively a blastp search using the target database.
export P_PSI_BLAST_DB_1="Ecoli"
export NUM_DESCRIPTIONS_P_PSI_BLAST_DB_1=1

export P_PSI_BLAST_DB_2="Bsubtilis168"
export NUM_DESCRIPTIONS_P_PSI_BLAST_DB_2=1

# Launch psiblast
# searches performed for all e-values in the following list
for db in "pdbaa"
do
    for e in 0.01
    do
        ~/Projects/blast/blast_tools/psiblast_formater.sh \
        --input-fasta two.fasta \
        --output-filename psiblast-report \
        --database $db \
        --clean 0 \
        --evalue $e \
        --num-report-hits 3 \
        --backward-search 0 \
        --num-threads 6 \
        --max-num-psi-iteration 5
    done
done

