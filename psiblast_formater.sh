#!/bin/bash
if [[ ($1 == "-h") || ($1 == "--help") ]]
then
    echo "Usage:"
    echo "$0 [-h,-help] [-i,--input-fasta] [-d,--database] <-e,--evalue>
    <-nd,--num_descriptions> <-na,--num_alignments> <-o --output-filename>
    <-cl,--clean> <-nrh,--num-report-hits> <-nthr, --num-threads>
    <-psimax, --max-num-psi-iteration> <-ie, --initial-evalue>
    <-bks, --backward-search>

    where:
        -h, --help  show this help text
	-i, --input-fasta the input FASTA file
	-d, --database database FASTA file
	-ie, --initial-evalue the initial E value for blastp
	-e, --evalue the E value for psiblast
	-nd, --num_descriptions
	-na, --num_alignments
	-o, --output-filename
	-cl, --clean
	-nrh, --num-report-hits
	-nthr, --num-threads
	-bks, --backward-search
	-psimax, --max-num-psi-iteration"
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
	    PSI_BLAST_DB="$2"
	    shift
	    ;;
	-ie|--initial-evalue)
	    INIT_EVALUE_SET="$2"
	    shift
	    ;;
	-e|--evalue)
	    EVALUE_SET="$2"
	    shift
	    ;;
	-th|--threshold)
	    THRESHOLD_SET="$2"
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
	-psimax|--max-num-psi-iteration)
	    MAX_PSI_ITER="$2"
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
NUM_PDB=0
if [[ $P_PSI_BLAST_DB_1 != "" ]]
then
  NUM_PDB=1
  if [[ $P_PSI_BLAST_DB_2 != "" ]]
  then
    NUM_PDB=2
  fi
fi

PSI_BLAST_DB_NAME=${PSI_BLAST_DB%.*}
P_PSI_BLAST_DB_1_NAME=${P_PSI_BLAST_DB_1%.*}
P_PSI_BLAST_DB_2_NAME=${P_PSI_BLAST_DB_2%.*}
INIT_EVALUE=${INIT_EVALUE_SET:-0.1}
EVALUE=${EVALUE_SET:-0.001}
THRESHOLD=${THRESHOLD_SET:-0.0005}
NUM_THREDS=${NUM_THREDS_SET:-4}
NUM_REPORT_HITS=${NUM_REPORT_HITS_SET:-2}
NUM_DESCRIPTIONS=${NUM_DESCRIPTIONS_SET:-9}
NUM_ALIGNMENTS=${NUM_ALIGNMENTS_SET:-9}
if [[ NUM_PDB == 1 ]]
then
    OUTPUTREPORT="${OUTPUTREPORT%.*:-"psiblast"}-MaxHits_$NUM_REPORT_HITS-in_${INPUT_FASTA%.*}-db_$PSI_BLAST_DB_NAME-p_db_$P_PSI_BLAST_DB_1_NAME-e_$EVALUE-it_$MAX_PSI_ITER.report"
elif [[ NUM_PDB == 2 ]]
then
    OUTPUTREPORT="${OUTPUTREPORT%.*:-"psiblast"}-MaxHits_$NUM_REPORT_HITS-in_${INPUT_FASTA%.*}-db_$PSI_BLAST_DB_NAME-p_db_1_$P_PSI_BLAST_DB_1_NAME-p_db_2_$P_PSI_BLAST_DB_2_NAME-e_$EVALUE-it_$MAX_PSI_ITER.report"
else
    OUTPUTREPORT="${OUTPUTREPORT%.*:-"psiblast"}-MaxHits_$NUM_REPORT_HITS-in_${INPUT_FASTA%.*}-db_$PSI_BLAST_DB_NAME-e_$EVALUE-it_$MAX_PSI_ITER.report"
fi

############################################
# if database is a fasta file, build a local database
# otherwise database files in BLASTDB path will be used.
if [[ $PSI_BLAST_DB == *".fasta"* || $PSI_BLAST_DB == *".FASTA"* ]]
then
    # generage database if they do not exist
    [ ! -e "$PSI_BLAST_DB_NAME.psq" ] && \
    [ ! -e "$PSI_BLAST_DB_NAME.psi" ] && \
    [ ! -e "$PSI_BLAST_DB_NAME.psd" ] && \
    [ ! -e "$PSI_BLAST_DB_NAME.pog" ] && \
    [ ! -e "$PSI_BLAST_DB_NAME.pni" ] && \
    [ ! -e "$PSI_BLAST_DB_NAME.pnd" ] && \
    [ ! -e "$PSI_BLAST_DB_NAME.pin" ] && \
    [ ! -e "$PSI_BLAST_DB_NAME.phr" ] && \
    makeblastdb -in $PSI_BLAST_DB -out $PSI_BLAST_DB_NAME -dbtype prot -parse_seqids
fi

if [[ $P_PSI_BLAST_DB_1 == *".fasta"* || $P_PSI_BLAST_DB_1 == *".FASTA"* ]]
then
    # generage database if they do not exist
    [ ! -e "$P_PSI_BLAST_DB_1_NAME.psq" ] && \
    [ ! -e "$P_PSI_BLAST_DB_1_NAME.psi" ] && \
    [ ! -e "$P_PSI_BLAST_DB_1_NAME.psd" ] && \
    [ ! -e "$P_PSI_BLAST_DB_1_NAME.pog" ] && \
    [ ! -e "$P_PSI_BLAST_DB_1_NAME.pni" ] && \
    [ ! -e "$P_PSI_BLAST_DB_1_NAME.pnd" ] && \
    [ ! -e "$P_PSI_BLAST_DB_1_NAME.pin" ] && \
    [ ! -e "$P_PSI_BLAST_DB_1_NAME.phr" ] && \
    makeblastdb -in $P_PSI_BLAST_DB_1 -out $P_PSI_BLAST_DB_1_NAME -dbtype prot -parse_seqids
fi

if [[ $P_PSI_BLAST_DB_2 == *".fasta"* || $P_PSI_BLAST_DB_2 == *".FASTA"* ]]
then
    # generage database if they do not exist
    [ ! -e "$P_PSI_BLAST_DB_2_NAME.psq" ] && \
    [ ! -e "$P_PSI_BLAST_DB_2_NAME.psi" ] && \
    [ ! -e "$P_PSI_BLAST_DB_2_NAME.psd" ] && \
    [ ! -e "$P_PSI_BLAST_DB_2_NAME.pog" ] && \
    [ ! -e "$P_PSI_BLAST_DB_2_NAME.pni" ] && \
    [ ! -e "$P_PSI_BLAST_DB_2_NAME.pnd" ] && \
    [ ! -e "$P_PSI_BLAST_DB_2_NAME.pin" ] && \
    [ ! -e "$P_PSI_BLAST_DB_2_NAME.phr" ] && \
    makeblastdb -in $P_PSI_BLAST_DB_2 -out $P_PSI_BLAST_DB_2_NAME -dbtype prot -parse_seqids
fi

# final report
echo "\
# psiblast report:
#    Input: $INPUT_FASTA
#    Database: $PSI_BLAST_DB_NAME
#    Evalue: $EVALUE
# Fields: subject id, subject length, alignment length, evalue, bit score, % identity, % percid annotation
" > $OUTPUTREPORT

printf "%30s %10s %10s %10s %8s %10s %10s     %s\n" \
	"HitID" "Length" "Alignment" "Evalue" "BitScore" "%id" \
	"%percid" "Annotation" >> $OUTPUTREPORT
echo \
------------------------------------------------------------------------------------------------------------------- \
>> $OUTPUTREPORT

NUM_LINES=$(wc -l < $INPUT_FASTA)

ENTRY=0
COUNT=1
NEW_ENTRY=1
while [[ $COUNT -le $NUM_LINES ]]
do
  #
  ## extract one fasta query from input file
  #
  THIS_LINE=$(sed "${COUNT}q;d" $INPUT_FASTA)

  if [[ $NEW_ENTRY == 1 ]] # '>' line of a new entry
  then
    echo $THIS_LINE > tmp.query.$ENTRY.fasta
    COUNT=$((COUNT+1))
    NEW_ENTRY=0
    continue
  else
    if [[ $THIS_LINE =~ ^\> ]] # '>' line of the next new entry
    then
      NEW_ENTRY=1
    else                       # sequence lines
      echo $THIS_LINE >> tmp.query.$ENTRY.fasta
	    COUNT=$((COUNT+1))
	    if [[ $COUNT -gt $NUM_LINES ]] # the last line
	    then
        echo
	    else                          # not the last line
        continue
      fi
    fi
  fi

  ## extract one fasta query from input file
  printf "\n\n\n"
  echo "*********** processing entry $ENTRY: ***********"
  printf "\n\n\n"

  #
  ## Constructing initial profile
  #
  echo "@@@ Constructing initial profile"

  # use hits in profile database 1 to construct initial profile
  if [[ $P_PSI_BLAST_DB_1 != "" ]]
  then
    echo "@@@     processing profile database 1"
    blastp -outfmt "7 sseqid slen length evalue bitscore pident stitle" \
    -query tmp.query.$ENTRY.fasta -out p_db_1.$ENTRY.report -db $P_PSI_BLAST_DB_1_NAME \
    -evalue $INIT_EVALUE -num_threads $NUM_THREDS -lcase_masking  -max_target_seqs $NUM_DESCRIPTIONS_P_PSI_BLAST_DB_1

    grep "ref|\|gi|" p_db_1.$ENTRY.report | awk 'BEGIN { FS="|" } { print $2 }' | uniq > tmp.P_REF_1.$ENTRY.id
    echo "@@@    profile 1 contains sequences:"
    cat tmp.P_REF_1.$ENTRY.id
  else
    echo "profile database must be assigned."
    exit 1
  fi

  # use hits in profile database 2 to construct initial profile
  if [[ $P_PSI_BLAST_DB_2 != "" ]]
  then
    echo "@@@     processing profile database 2"
    blastp -outfmt "7 sseqid slen length evalue bitscore pident stitle" -query tmp.query.$ENTRY.fasta \
    -out p_db_2.$ENTRY.report -db $P_PSI_BLAST_DB_2_NAME -evalue $INIT_EVALUE -num_threads $NUM_THREDS \
    -lcase_masking -max_target_seqs $NUM_DESCRIPTIONS_P_PSI_BLAST_DB_2

    grep "ref|\|gi|" p_db_2.$ENTRY.report | awk 'BEGIN { FS="|" } { print $2 }' | uniq > tmp.P_REF_2.$ENTRY.id
    echo "@@@    profile 2 contains sequences:"
    cat tmp.P_REF_2.$ENTRY.id
  fi

  # construct a set of aligned sequences which are then used
  # by psiblast below to generate the initial PSSM
  echo "@@@ constructing aligned sequences"

  if [[ -s tmp.P_REF_1.$ENTRY.id ]]
  then
    blastdbcmd -db $P_PSI_BLAST_DB_1_NAME -entry_batch tmp.P_REF_1.$ENTRY.id -out p_db_1.$ENTRY.fasta
  fi

  if [[ -s tmp.P_REF_2.$ENTRY.id ]]
  then
    blastdbcmd -db $P_PSI_BLAST_DB_2_NAME -entry_batch tmp.P_REF_2.$ENTRY.id -out p_db_2.$ENTRY.fasta
  fi

  if [[ -s tmp.P_REF_1.$ENTRY.id ]] || [[ -s tmp.P_REF_2.$ENTRY.id ]]
  then
    cat p_db_1.$ENTRY.fasta p_db_2.$ENTRY.fasta > p_db.$ENTRY.fasta
    NUM_ENTRY=$(grep ">" p_db.$ENTRY.fasta | wc -l | sed 's/[^0-9]*//g')

    if [[ $NUM_ENTRY > 1 ]]
    then
      mafft p_db.$ENTRY.fasta > p_db.$ENTRY.fasta.aligned

      #
      ## PSIBLAST loops
      #
      echo "@@@ PSIBLAST loops"
      psiblast -outfmt "7 sseqid slen length evalue bitscore pident" -db $PSI_BLAST_DB_NAME \
      -in_msa p_db.$ENTRY.fasta.aligned -out psiblast.$ENTRY.report \
      -num_iterations $MAX_PSI_ITER -evalue $EVALUE

	    # build a fasta file for hits in the last iteration of PSIBLAST
	    # search

	    # extract hits in the last iteration:
	    NUM_ITER=$(grep "Iteration: " psiblast.$ENTRY.report | wc -l | sed 's/[^0-9]*//g')
	    grep "Iteration: $NUM_ITER" -A100 psiblast.$ENTRY.report > psiblast.last_iter.$ENTRY.report

	    grep "ref|\|gi|" psiblast.last_iter.$ENTRY.report | awk 'BEGIN { FS="|" } { print $2 }' | uniq > tmp.REF.$ENTRY.id
	    if [[ -s tmp.REF.$ENTRY.id ]]
	    then
        blastdbcmd -db $PSI_BLAST_DB_NAME -entry_batch tmp.REF.$ENTRY.id -out psiblast.last_iter.$ENTRY.fasta
        cat tmp.query.$ENTRY.fasta psiblast.last_iter.$ENTRY.fasta > tmp.Match.$ENTRY.fasta
        mafft tmp.Match.$ENTRY.fasta > tmp.Match.$ENTRY.fasta.aligned

        echo "@@@ generating profile"
        seqqr tmp.Match.$ENTRY.fasta.aligned psiblast.$ENTRY.profile
      fi
    else
      echo "EMPTY: less than two hits in initial profile construction, skipping psiblast." > psiblast.$ENTRY.report
      echo "EMPTY: less than two hits in initial profile construction, skipping psiblast." > psiblast.last_iter.$ENTRY.report
    fi
  else
    echo "EMPTY: less than two hits in initial profile construction, skipping psiblast." > psiblast.$ENTRY.report
    echo "EMPTY: less than two hits in initial profile construction, skipping psiblast." > psiblast.last_iter.$ENTRY.report
  fi

  # output report
  ## header for every entry
  echo "@@@ writing report"
  echo "Query $(sed "1q;d" tmp.query.$ENTRY.fasta):" >> $OUTPUTREPORT
  echo  >> $OUTPUTREPORT

  LINE_NUM=2
  while read line
  do
    if [[ $line == *"gi"* ]] || [[ $line == *"ref"* ]] || [[ $line == *"lcl"* ]]
    then
      #
	    ## calculate PID for top hits
	    #
	    echo "@@@ calculating % percid for top $((LINE_NUM - 1)) hit"
	    ID=$(echo $line | awk 'BEGIN { FS="|" } { print $2 }')
	    blastdbcmd -db $PSI_BLAST_DB -dbtype prot -entry $ID -out tmp.$ENTRY.$((LINE_NUM - 1)).fasta

	    cat tmp.query.$ENTRY.fasta tmp.$ENTRY.$((LINE_NUM - 1)).fasta > tmp.Match.$ENTRY.$((LINE_NUM - 1)).fasta
	    mafft tmp.Match.$ENTRY.$((LINE_NUM - 1)).fasta > tmp.Match.$ENTRY.$((LINE_NUM - 1)).fasta.aligned
	    percid tmp.Match.$ENTRY.$((LINE_NUM - 1)).fasta.aligned percid.$ENTRY.$((LINE_NUM - 1)).percid_matrix
	    PERCENT=$(cat percid.$ENTRY.$((LINE_NUM - 1)).percid_matrix | tail -n1 | awk '{print $1}')
	    PERCENT=$(echo "scale=2; $PERCENT*100" | bc)
	    PERCENT=$(printf '%*.*f' 0 2 "$PERCENT")

	    # extract annotation
	    ID=$(echo $line | awk 'BEGIN { FS="|" } { print $2 }')
	    if [[ $PSI_BLAST_DB == *.fasta || $PSI_BLAST_DB == *.FASTA ]]
	    then
        ID_header=$(grep $ID $PSI_BLAST_DB)
        TITLE=$(echo $ID_header | awk 'BEGIN { FS="|" } { print $5 }')
	    else
        TITLE=$(blastdbcmd -db $PSI_BLAST_DB_NAME -dbtype prot -entry $ID | head -n1 | awk -v id=$ID 'BEGIN { FS=id } { print $2 }' | cut -d " " -f2- | awk 'BEGIN { FS=">" } { print $1 }')
      fi

      IFS="	"
	    printf "%30s %10s %10s %10s %8s %10s %10s %s\n" ${line[0]} \
	    ${line[1]} ${line[2]} ${line[3]} ${line[4]} ${line[5]} $PERCENT $TITLE >> $OUTPUTREPORT

	    if [[ $LINE_NUM -gt $NUM_REPORT_HITS ]]
      then
        break
      fi

      LINE_NUM=$((LINE_NUM+1))

    elif [[ $line == "EMPTY"* ]] # initial PSSM failed
    then
      echo "less than two hits in initial profile construction, skipping psiblast." >> $OUTPUTREPORT
    elif [[ $line == *"# 0 hits"* ]]
    then
      echo "0 hits" >> $OUTPUTREPORT
    elif [[ $line == "" ]] # empty line
    then
      echo ""
    else # not include comments
      echo
    fi
  done <psiblast.last_iter.$ENTRY.report

  echo  >> $OUTPUTREPORT

  #
  ## if backward searching enabled
  #
  if [[ $BACK == 1 ]]
  then
    echo "@@@ top hit backward searching"
    if [[ ! -e "input_as_db.phr" ]]
    then
      makeblastdb -in $INPUT_FASTA -out input_as_db -dbtype prot -parse_seqids
    fi
    BACKWARD_SEARCH_ENTRY_ID=$(grep "ref|\|gi|" psiblast.last_iter.$ENTRY.report | head -n1 | awk 'BEGIN { FS="|" } { print $2 }')
    ENTRY_STRING="'$BACKWARD_SEARCH_ENTRY_ID'"
    eval "blastdbcmd -db $PSI_BLAST_DB_NAME -dbtype prot -entry $ENTRY_STRING > backward_search.$ENTRY.fasta"

    blastp -outfmt \
    "7 qseqid sseqid slen length evalue bitscore pident" \
    -query backward_search.$ENTRY.fasta -out backward_search.$ENTRY.report \
    -db input_as_db -evalue $EVALUE -num_threads $NUM_THREDS -lcase_masking

    echo "  Backward Search hits:" >> $OUTPUTREPORT
    #grep "ref|\|gi|" backward_search.$ENTRY.report | head -n1 | awk 'BEGIN { FS="|" } { print $2 }' >> $OUTPUTREPORT
    REPORT_STRING=$(grep "^gi|" backward_search.$ENTRY.report | head -n1)

    echo "backward: $REPORT_STRING"

    #
    ## backward PID calculation
    #
    echo "@@@ calculating top hit backward searching %percid"
    # align query sequence with all hits
    cat backward_search.$ENTRY.fasta tmp.query.$ENTRY.fasta > tmp.backward_search.Match.$ENTRY.fasta
    mafft tmp.backward_search.Match.$ENTRY.fasta > tmp.backward_search.Match.$ENTRY.fasta.aligned

    # calculate PID using percid
    percid tmp.backward_search.Match.$ENTRY.fasta.aligned tmp.backward_search.percid.$ENTRY.percid_matrix
    PERCENT=$(cat tmp.backward_search.percid.$ENTRY.percid_matrix | tail -n1 | awk '{print $1}')
    PERCENT=$(echo "scale=2; $PERCENT*100" | bc)
    PERCENT=$(printf '%*.*f' 0 2 "$PERCENT")

    if [[ $REPORT_STRING != "" ]]
    then
      arr=($REPORT_STRING)
      printf "%30s %10s %10s %10s %8s %10s %10s\n" ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${arr[5]} ${arr[6]} $PERCENT >> $OUTPUTREPORT
    fi
    echo  >> $OUTPUTREPORT
  fi

  ENTRY=$((ENTRY+1))
done

#
## cleanup
#
echo "@@@ cleaning up"
if [[ $BACK == 1 ]]
then
    rm input_as_db.*

    if [[ $DEBUG_CLEAN > 0 ]]
    then
        rm backward_search.*
    fi
fi

if [[ $DEBUG_CLEAN > 0 ]]
then
    rm tmp.*
fi

if [[ $DEBUG_CLEAN > 1 ]]
then
    rm p_db*
fi

if [[ $DEBUG_CLEAN > 2 ]]
then
    rm psiblast.last_iter.*
fi

unset P_PSI_BLAST_DB_1 P_PSI_BLAST_DB_2
