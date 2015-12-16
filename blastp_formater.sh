#!/bin/bash
if [[ ($1 == "-h") || ($1 == "--help") ]]
then
    echo "Usage:"
    echo "$0 [-h,-help] [-i,-input] [-d,-database] <-e,--evalue>
    <-nd,--num_descriptions> <-na,--num_alignments> <-o --output_report>

    where:
        -h, --help  show this help text
	-i, --input the input FASTA file
	-d, --database database FASTA file
	-e, --evalue the E value
	-nd, --num_descriptions 
	-na, --num_alignments
	-o, --output_report "
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
	-o|--output_report)
	    OUTPUTREPORT="$2"
	    shift
	    ;;
		    *) # unknown option
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

# final report
echo "# blastp table task final report" > $OUTPUTREPORT

ENTRY=0
while read line
do
    echo ">MMSYN seq. $ENTRY" > query.$ENTRY.fasta
    echo $line >> query.$ENTRY.fasta
    # Blast outputs archive
    blastp -outfmt \
	"7 sseqid scinames len slen length evalue bitscore pident" \
	-query query.$ENTRY.fasta -out blastp.$ENTRY.report \
	-db $DATABASE_NAME -evalue $EVALUE \
	#-num_descriptions $NUM_DESCRIPTIONS -num_alignments $NUM_ALIGNMENTS

    # build a fasta file for all hits
    grep "ref|\|gi|" blastp.$ENTRY.report | awk 'BEGIN { FS="|" } { print $2 }' > REF.$ENTRY.fasta
    blastdbcmd -db $DATABASE_NAME -entry_batch REF.$ENTRY.fasta -out blastdbcmd.$ENTRY.fasta

    # align query sequence with all hits
    cat query.$ENTRY.fasta blastdbcmd.$ENTRY.fasta > Match.$ENTRY.fasta
    mafft --auto Match.$ENTRY.fasta > Match.$ENTRY.fasta.aligned

    # calculate PID using percid
    percid Match.$ENTRY.fasta.aligned percid.$ENTRY.percid_matrix

    # appending percid to report
    echo "##########  Query entry: $ENTRY ##########" >> $OUTPUTREPORT
    LINE_NUM=2
    while read line
    do
	if [[ $line == *"Fields"* ]] # Append to Fields description with "% percid" 
	then

	    echo "$line % percid" >> $OUTPUTREPORT

	elif [[ $line == \#* ]] # other comment line
	then

	    echo $line >> $OUTPUTREPORT

	else # entries that need to be processed
	    PERCENT=`cat percid.$ENTRY.percid_matrix | head -n$LINE_NUM | tail -n1 | awk '{print $1}'`
	    PERCENT=`echo "scale = 2; $PERCENT* 100" | bc`

	    # extract annotation
	    ID=`echo $line | awk 'BEGIN { FS="|" } { print $2 }'`
	    ID_header=`grep $ID $DATABASE`
	    SCINAME=`echo $ID_header | awk 'BEGIN { FS="|" } { print $5 }'`

	    echo $line $PERCENT $SCINAME >> $OUTPUTREPORT

	    LINE_NUM=$((LINE_NUM+1))

	fi
    done <blastp.$ENTRY.report


    #rm query.$ENTRY.fasta REF.$ENTRY.fasta

    ENTRY=$((ENTRY+1))
done <$INPUT_FASTA


# cleanup
unset INPUT_FASTA DATABASE DATABASE_NAME COUNT EVALUE_SET EVALUE NUM_DESCRIPTIONS_SET NUM_DESCRIPTIONS NUM_ALIGNMENTS_SET NUM_ALIGNMENTS LINE_NUM PERCENT
  
