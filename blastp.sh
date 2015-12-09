#!/bin/bash
if [[ ($1 == "-h") || ($1 == "--help") ]]
then
    echo "Usage:"
    echo "$0 [-h,-help] [-i,-input] [-d,-database] <-e,--evalue> <-nd,--num_descriptions> <-na,--num_alignments> 

    where:
        -h, --help  show this help text
	-i, --input the input FASTA file
	-d, --database database FASTA file
	-e, --evalue the E value
	-nd, --num_descriptions 
	-na, --num_alignments "
    exit 0
fi
    
while [[ $# > 1 ]]
do
    key="$1"

    case $key in
	-i|--input)
	    INPUT_FASTA="$2"
	    shift
	    ;;
	
	-d|--database)
	    DATABASE="$2"
	    shift
	    ;;
		    *) # unknown option
	    ;;
	-e|--evalue)
	    EVALUE_SET="$2"
	    shift
	    ;;
	-nd|--num_descriptions)
	    NUM_DESCRIPTIONS_SET="$2"
	    shift
	    ;;
	-na|--num_alignments)
	    NUM_ALIGNMENTS_SET="$2"
	    shift
	    ;;
    esac
    shift
done

DATABASE_NAME=${DATABASE%.*}
EVALUE=${EVALUE_SET:-0.001}
NUM_DESCRIPTIONS=${NUM_DESCRIPTIONS_SET:-9}
NUM_ALIGNMENTS=${NUM_ALIGNMENTS_SET:-9}

############################################
# do the work

makeblastdb -in $DATABASE -out $DATABASE_NAME -dbtype prot -parse_seqids

COUNT=0
while read line
do
    echo $line > entry.$COUNT.fasta
    # Blast sequence against database and return top 9 matches
    blastp -query entry.$COUNT.fasta -out OUTPUT.$COUNT.log -db $DATABASE_NAME -evalue $EVALUE -num_descriptions $NUM_DESCRIPTIONS -num_alignments $NUM_ALIGNMENTS
    grep "ref|\|gi|" OUTPUT.$COUNT.log | awk 'BEGIN { FS="|" } { print $2 }' > REF.$COUNT
    blastdbcmd -db $DATABASE_NAME -entry_batch REF.$COUNT -out PROFILE.$COUNT.fasta

    COUNT=$((COUNT+1))
done <$INPUT_FASTA


# cleanup
unset INPUT_FASTA DATABASE DATABASE_NAME COUNT EVALUE_SET EVALUE NUM_DESCRIPTIONS_SET NUM_DESCRIPTIONS NUM_ALIGNMENTS_SET NUM_ALIGNMENTS
  
