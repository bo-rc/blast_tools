# blast_tools
This repository hosts a set of *bash* scripts which would automate the command line programs of BLAST+ tools.

## What is BLAST?
**BLAST** stands for **B**asic **L**ocal **A**lignment **S**earch **T**ool. It is a sequence comparison algorithm optimized for speed used to search sequence databases for optimal local alignments to a query. The initial search isolates a window of width `w`, which contains `w` letters, of both query and target sequences to calculate a similarity score. If this score is above a *threshold*, the comparisons are then extended in either direction to maximize the alignment of an increasing segment of the two sequences. The extent of the extension contributes to the *bit score* of the alignment: the higher the *bit score*, the better the alignment which indicates the similarity of the two sequences.

The [original BLAST](http://www.ncbi.nlm.nih.gov/pubmed/2231712) programs were developed in the 90's. [Modern BLAST](https://www.ncbi.nlm.nih.gov/pubmed/20003500?dopt=Citation) family tools are called BLAST+, which greatly improves the run times by breaking a long sequence into chucks and computing using multithreads. BLAST+ also introduced new features such as *masking* and *strategy files* but the underlying scoring algorithm is the same as the original BLAST.

## Purpose and Features of the scripts
The purpose of this set of scripts is to automate BLAST search tasks for multiple query sequences. Input sequences can be put in a text file with the FASTA format. Database files can be standard BLAST database files or as simple as another FASTA file. The searching result is in a `.report` text file. 

**Features**:
* formatted report contains full length of annotations for hit sequences.
* the maximun number of hits in report can be assigned.
* by using the *launch* script, different *e-value*s, databases, other parameters can be tested automatically; the output files will be automatically named accordingly.
* *Backward Search* is implemented for the confirmation of hits.
 * *Backward Search* can be turned on and off using the *launch* scripts.
* `percid` program in [MultiSeq](http://www.scs.illinois.edu/schulten/multiseq/) is used to calculate the percentage of similarity between query and target sequences.
* The initial searching database and the PSIBLAST taget database can be different and use different *e-values*.
* QR-reduction is used to process the generated sequence profiles of PSIBLAST.

The scripts are exclusively written in *bash* to meet the requirements of the university groups using the tools. 

The set of tools performs two BLAST tasks: BLAST search and PSI-BLAST search.

## BLAST for proteins: `blastp_formater.sh`
This script performs modern multithreading BLAST+ searches for proteins. 
* input: 
 * the fasta file containing query sequences; 
 * the target database
* output: 
 * a report file for the search, containing hits and other relevant information
* usage: use `launch_blastp.sh` to automate BLAST+ searches with different parameters.
 * e.g. test a set of `e-value` cutoffs

## PSIBLAST for proteins: `psiblast_formater.sh`
This script first performs a `blastp` search to determine initial hits for `seqqr` (QR-reduction), then a `seqqr` to determine initial profile of aligned sequences, finally the `psiblast` search against the initial profile.
* input: the fasta file containing query sequences; 
 * databases for initial profile searches; 
 * the target database.
* ouput: 
 * a report file for the search, containing hits and other relevant information; 
 * a profile report for each query sequences.
* usage: use `launch_psiblast.sh` to automate PSIBLAST searches with different parameters.

## Arguments
**Clean Level** (`--clean`):
* `0`: temporary files are kept.
* `1`: temporary files and backwar-search files are deleted.
* `2`: profile database files are deleted + the effect of `1`
* `3`: psiblast last iteration report is deleted + the effect of `2`

## Flow Charts

**BLASTP**: the algorithm described in [BLAST+ Paper](https://www.ncbi.nlm.nih.gov/pubmed/20003500?dopt=Citation).

**PSIBLAST**:

<img src="https://cloud.githubusercontent.com/assets/14265605/12404303/eda162c8-bdff-11e5-8f0d-0ea51570adfe.png" width="640">

**The protocol of our choice**:



# Build a local database
Use the `update_blastdb.pl` perl scripts provided by NCBI:
* Go to the path of your local database directory
* Download database:
`./update_blastdb.pl nr pdbaa --decompress`
* Build taxonomy ID:
`./update_blastdb.pl taxdb; tar -xzf taxdb.tar.gz`

## Build a sub-database

1. Download the prebuilt nr database (ncbi).
2. Search the [Entrez Protein database](http://www.ncbi.nlm.nih.gov/protein) with query: "gram-positive bacteria"
3. Select "Send to File" and choose format "GI list"
4. Use the list of GIs from the previous step with the `blastdb_aliastool` to build an aliased blastdb of just gram-positive bacteria (takes several seconds): `blastdb_aliastool -gilist gram-positive-bacteria.gi_list.txt -db nr -out nr_gpb -title nr_gpb`

### How many sequences in sub-databases?
* **Ecoli DB**: 149236
* **Mycoplasma**: 230866
* **Firmicutes** (gram-positive bacteria): 49749635
* **prokaryotes**: 204031745
* **bacteria**: 200863227


