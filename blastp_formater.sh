#!/bin/bash
if [[ ($1 == "-h") || ($1 == "--help") ]]
then
    echo "Usage:"
    echo "$0 [-h,-help] [-i,--input-fasta] [-d,--database] <-e,--evalue>
    <-nd,--num_descriptions> <-na,--num_alignments> <-o --output-filename>
    <-cl,--clean> <-nrh,--num-report-hits> <-nthr, --num-threads>
    <-bks, --backward-search>

    where:
        -h, --help  show this help text
	-i, --input-fasta the input FASTA file
	-d, --database database FASTA file
	-e, --evalue the E value
	-nd, --num_descriptions 
	-na, --num_alignments
	-o, --output-filename 
	-cl, --clean 
	-nrh, --num-report-hits 
	-nthr, --num-threads 
	-bks, --backward-search "
    exit 0
fi
    
# parsing input arguments
while [[ $# > 1 ]]
do
    key="$1"

    case $key in
	-i|--input-fasta)
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

	-o|--output-filename)
	    OUTPUTREPORT="$2"
	    shift
	    ;;

	-cl|--clean)
	    DEBUG_CLEAN="$2"
	    shift
	    ;;

	-bks|--backward-search)
	    BACK="$2"
	    shift
	    ;;

	-nrh|--num-report-hits)
	    NUM_REPORT_HITS_SET="$2"
	    shift
	    ;;

	-nthr|--num-threads)
	    NUM_THREDS_SET="$2"
	    shift
	    ;;


    esac
    shift
done

# processing input arguments 
DATABASE_NAME=${DATABASE%.*}
EVALUE=${EVALUE_SET:-0.001}
NUM_THREDS=${NUM_THREDS_SET:-4}
NUM_REPORT_HITS=${NUM_REPORT_HITS_SET:-2}
NUM_DESCRIPTIONS=${NUM_DESCRIPTIONS_SET:-9}
NUM_ALIGNMENTS=${NUM_ALIGNMENTS_SET:-9}
OUTPUTREPORT="${OUTPUTREPORT%.*:-"report"}-MaxHits_$NUM_REPORT_HITS-input_${INPUT_FASTA%.*}-db_$DATABASE_NAME-evalue_$EVALUE.txt"

############################################
# if database is a fasta file, build a local database
if [[ $DATABASE == *".fasta"* || $DATABASE == *".FASTA"* ]]
then
    # generage database if they do not exist
    [ ! -e "$DATABASE_NAME.psq" ] && \
    [ ! -e "$DATABASE_NAME.psi" ] && \
    [ ! -e "$DATABASE_NAME.psd" ] && \
    [ ! -e "$DATABASE_NAME.pog" ] && \
    [ ! -e "$DATABASE_NAME.pni" ] && \
    [ ! -e "$DATABASE_NAME.pnd" ] && \
    [ ! -e "$DATABASE_NAME.pin" ] && \
    [ ! -e "$DATABASE_NAME.phr" ] && \
    makeblastdb -in $DATABASE -out $DATABASE_NAME -dbtype prot -parse_seqids
fi

# final report
echo "\
# blastp report:  
#    Input: $INPUT_FASTA
#    Database: $DATABASE_NAME
#    Evalue: $EVALUE
# Fields: subject id, subject length, alignment length, evalue, bit score, % identity, % percid, annotation
" > $OUTPUTREPORT

printf "%30s %10s %10s %10s %8s %10s %10s     %s\n" \
	"HitID" "Length" "Alignment" "Evalue" "BitScore" "%id" \
	"%percid" "Annotation" >> $OUTPUTREPORT
echo \
---------------------------------------------------------------------------------------------------------------------------------------------------------- \
>> $OUTPUTREPORT

NUM_LINES=$(wc -l < $INPUT_FASTA)

ENTRY=0
COUNT=1
NEW_ENTRY=1
while [[ $COUNT -le $NUM_LINES ]]
do
    THIS_LINE=$(sed "${COUNT}q;d" $INPUT_FASTA)
    
    if [[ $NEW_ENTRY == 1 ]] # '>' line of a new entry
    then
	echo $THIS_LINE > query.$ENTRY.fasta
	COUNT=$((COUNT+1))
	NEW_ENTRY=0
	continue
    else
	if [[ $THIS_LINE =~ ^\> ]] # '>' line of the next new entry
	then
	    NEW_ENTRY=1
	else                       # sequence lines
	    echo $THIS_LINE >> query.$ENTRY.fasta
	    COUNT=$((COUNT+1))
	    if [[ $COUNT -gt $NUM_LINES ]] # the last line
	    then
		echo 
	    else                          # not the last line
	        continue
	    fi
	fi
    fi

    # Blast outputs archive
    blastp -outfmt \
	"7 sseqid slen length evalue bitscore pident" \
	-query query.$ENTRY.fasta -out blastp.$ENTRY.report \
	-db $DATABASE_NAME -evalue $EVALUE -num_threads	$NUM_THREDS -lcase_masking
	#-num_descriptions $NUM_DESCRIPTIONS -num_alignments $NUM_ALIGNMENTS

    # build a fasta file for all hits
    grep "ref|\|gi|" blastp.$ENTRY.report | awk 'BEGIN { FS="|" } { print $2 }' > REF.$ENTRY.fasta
    blastdbcmd -db $DATABASE_NAME -entry_batch REF.$ENTRY.fasta -out blastdbcmd.$ENTRY.fasta

    # align query sequence with all hits
    cat query.$ENTRY.fasta blastdbcmd.$ENTRY.fasta > Match.$ENTRY.fasta
    mafft Match.$ENTRY.fasta > Match.$ENTRY.fasta.aligned

    # calculate PID using percid
    percid Match.$ENTRY.fasta.aligned percid.$ENTRY.percid_matrix

    # output report
    ## header for every entry
    echo "Query $(sed "1q;d" query.$ENTRY.fasta):" >> $OUTPUTREPORT
    echo  >> $OUTPUTREPORT

    ## append percid to report
    LINE_NUM=2
    while read line
    do
	if [[ $line == *"0 hits found"* ]] # Append to Fields description with "% percid" 
	then

	    echo "0 hits found" >> $OUTPUTREPORT

	elif [[ $line == \#* ]] # other comment line
	then

	    # not include comments
	    echo 

	else # entries that need to be processed
	    PERCENT=$(cat percid.$ENTRY.percid_matrix | head -n$LINE_NUM | tail -n1 | awk '{print $1}')
	    PERCENT=$(echo "scale=2; $PERCENT*100" | bc)
	    PERCENT=$(printf '%*.*f' 0 2 "$PERCENT")

	    # extract annotation
	    ID=$(echo $line | awk 'BEGIN { FS="|" } { print $2 }')
	    ID_header=$(grep $ID $DATABASE)
	    SCINAME=$(echo $ID_header | awk 'BEGIN { FS="|" } { print $5 }')

	    IFS="	"
	    printf "%30s %10s %10s %10s %8s %10s %10s %s\n" ${line[0]} ${line[1]} ${line[2]} ${line[3]} ${line[4]} ${line[5]} $PERCENT $SCINAME >> $OUTPUTREPORT

	    if [[ $LINE_NUM -gt $NUM_REPORT_HITS ]]
	    then 
		break
	    fi

	    LINE_NUM=$((LINE_NUM+1))

	fi
    done <blastp.$ENTRY.report

    echo  >> $OUTPUTREPORT

    if [[ $BACK == 1 ]]
    then
	if [[ ! -e "input_as_db.phr" ]]
	then
	    makeblastdb -in $INPUT_FASTA -out input_as_db -dbtype prot -parse_seqids
	fi
	BACKWARD_SEARCH_ENTRY_ID=$(grep "ref|\|gi|" blastp.$ENTRY.report | head -n1 | awk 'BEGIN { FS="|" } { print $2 }')
	ENTRY_STRING="'$BACKWARD_SEARCH_ENTRY_ID'"
	eval "blastdbcmd -db $DATABASE_NAME -dbtype prot -entry $ENTRY_STRING > backward_search.$ENTRY.fasta"

	blastp -outfmt \
	    "7 qseqid sseqid slen length evalue bitscore pident" \
	    -query backward_search.$ENTRY.fasta -out backward_search.$ENTRY.report \
	    -db input_as_db -evalue $EVALUE -num_threads $NUM_THREDS -lcase_masking

	echo "  Backward Search hits:" >> $OUTPUTREPORT
	#grep "ref|\|gi|" backward_search.$ENTRY.report | head -n1 | awk 'BEGIN { FS="|" } { print $2 }' >> $OUTPUTREPORT
	REPORT_STRING=$(grep "^gi|" backward_search.$ENTRY.report | head -n1)

        # align query sequence with all hits
        cat backward_search.$ENTRY.fasta query.$ENTRY.fasta > backward_search.Match.$ENTRY.fasta
        mafft backward_search.Match.$ENTRY.fasta > backward_search.Match.$ENTRY.fasta.aligned

        # calculate PID using percid
        percid backward_search.Match.$ENTRY.fasta.aligned backward_search.percid.$ENTRY.percid_matrix
	PERCENT=$(cat backward_search.percid.$ENTRY.percid_matrix | tail -n1 | awk '{print $1}')
	PERCENT=$(echo "scale=2; $PERCENT*100" | bc)
	PERCENT=$(printf '%*.*f' 0 2 "$PERCENT")

	arr=($REPORT_STRING)
	printf "%30s %10s %10s %10s %8s %10s %10s\n" ${arr[1]} \
	${arr[2]} ${arr[3]} ${arr[4]} \
	${arr[5]} ${arr[6]} $PERCENT >> $OUTPUTREPORT

	echo  >> $OUTPUTREPORT
    fi

    ENTRY=$((ENTRY+1))
done


# cleanup
if [[ $DEBUG_CLEAN == 1 ]]
then
    rm Match.*.fasta Match.*.fasta.aligned \
    percid.*.percid_matrix query.*.fasta REF.*.fasta \
    blastp.*.report blastdbcmd.*.fasta backward_search.* \
    input_as_db.*
fi
