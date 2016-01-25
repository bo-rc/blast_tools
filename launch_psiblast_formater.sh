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
# export NUM_DESCRIPTIONS_P_PSI_BLAST_DB_1=9 # not used

#export P_PSI_BLAST_DB_2="Bsubtilis168"
# export NUM_DESCRIPTIONS_P_PSI_BLAST_DB_2=9 # not used

# Launch psiblast
# searches performed for all e-values in the following list
for db in pdbaa
do
    for e in 0.0001
    do
        ~/Projects/blast/blast_tools/psiblast_formater.sh \
        --input-fasta unknown8.fasta \
        --output-filename psiblast \
        --database $db \
        --clean 3 \
        --initial-evalue 0.1 \
        --evalue $e \
        --num-report-hits 3 \
	--backward-search 1 \
        --num-threads 6 \
        --max-num-psi-iteration 5
    done
done

