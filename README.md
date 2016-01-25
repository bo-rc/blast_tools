# blast_tools
This repository hosts a set of *bash* scripts which aim to automate searching of biological sequence databases via the command line programs of BLAST+ tools.

## What is BLAST?
**BLAST** stands for **B**asic **L**ocal **A**lignment **S**earch **T**ool. It is a sequence comparison algorithm optimized for speed used to search sequence databases for optimal local alignments to a query. The initial search isolates a window of width `w`, which contains `w` letters, of both query and target sequences to calculate a similarity score. If this score is above a *threshold*, the comparisons are then extended in either direction to maximize the alignment of an increasing segment of the two sequences. The extent of the extension contributes to the *bit score* of the alignment: the higher the *bit score*, the better the alignment which indicates the similarity of the two sequences.

The [original BLAST](http://www.ncbi.nlm.nih.gov/pubmed/2231712) programs were developed in the 90's. [Modern BLAST](https://www.ncbi.nlm.nih.gov/pubmed/20003500?dopt=Citation) family tools are called BLAST+, which greatly improves the run times by breaking a long sequence into chucks and computing using multithreads. BLAST+ also introduced new features such as *masking* and *strategy files* but the underlying scoring algorithm is the same as the original BLAST.

## What is PSIBLAST?
**PSI**BLAST stands for **P**osition-**S**pecific **I**terated BLAST. The PSIBLAST algorithm extends BLAST search to use an arbitrary position-specific score matrix (PSSM) in place of a query sequence and associated substitution matrix in each search iteration. The PSSM is constructed using aligned search hits and is updated after each iteration when additioinal hits are discovered. In another words, PSIBLAST automated the procedure of generating PSSM from the output produced by a BLAST search, and adapted the BLAST algorithm to take the PSSM as input. PSIBLAST can be perfomed for a specific number of iterations or until the PSSM is converged. The final converged PSSM can be seen as a *profile* of the query sequence. PSIBLAST uses PSSM as input, which means PSIBLAST does not actually searches hits for the query sequence. However, since the PSSM is a profile of the query sequence, PSIBLAST results are usually good hits for the query sequence. Depending how the PSSM is constructed and updated, PSIBLAST is reported as more sensitive than BLAST to discover remotely-related protein seqences.

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
* [QR-reduction](http://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-7-382) is used to process the generated sequence profiles of PSIBLAST.

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

**Input** (`--input-fasta`)

**Output** (`--output-filename`): assigns the prefix for the output `.report` text file, whose filename also includes critical parameters used in the search.

**Database** (`--database`): search will be performed in this database.
* can be NCBI binary format
* can be a plain `.fasta` file: `blastdbcmd` will be called to generate database files with this `.fasta` file

**Initial Evalue** (`--initial-evalue`): the evalue for the BLAST search to build an inital PSSM for the PSIBLAST search.
* default is 0.001

**Evalue** (`--evalue`): the evalue for BLAST search or PSIBLAST search after the initial PSSM is determined.
* default is 0.001

**Number of Hits in Report** (`--num-report-hits`): in case the search gives multiple hits, this option chooses the top `N` hits to be in the final report.
* defualt is 1

**Backward Search** (`--backward-search`): this option enables the search using the hit as a query sequence and the input fasta file as a database. The backward search is supposed to hit the original query sequence.

**Number of Threads** (`--num-threads`): use multiple threads for the search.
* default is 4

**Number of PSIBLAST iteration** (`--max-num-psi-iteration`)
* `0` means perform PSIBLAST untill the search is converged.
* a non-`0` N means perfom N iterations of PSIBLAST searches.
 * typically the search will converge within 5 iterations.

## Flow Charts

**BLASTP**: the algorithm described in [BLAST+ Paper](https://www.ncbi.nlm.nih.gov/pubmed/20003500?dopt=Citation).

<img src="https://cloud.githubusercontent.com/assets/14265605/12565871/4b8bc672-c37c-11e5-9727-47a633e06a90.png" width="640">

**The PSIBLAST protocol of our choice**:

<img src="https://cloud.githubusercontent.com/assets/14265605/12562867/01141e46-c36d-11e5-943b-158aff59caf1.png" width="640">

**Structural Alignments and Protein Evolutionary Profile**:

1. perform BLASTP using `pdbaa` to find hits in the PDB database.
2. perform BLASTP or PSIBLAST using a larger database to get better sequence hits.
3. perform MultiSeq structural alignment and profile profile building.

# Build a local database
Use the `update_blastdb.pl` perl scripts (provided by NCBI):
* Go to the path of your local database directory
* Download database:
`./update_blastdb.pl nr pdbaa --decompress`
* Build taxonomy ID:
`./update_blastdb.pl taxdb; tar -xzf taxdb.tar.gz`

## Build a sub-database

1. Download the prebuilt nr database (ncbi).
2. Search the [Protein database](http://www.ncbi.nlm.nih.gov/protein) with query: "gram-positive bacteria"
3. Select "Send to File" and choose format "GI list"
4. Use the list of GIs from the previous step with the `blastdb_aliastool` to build an aliased blastdb of just gram-positive bacteria (takes several seconds): `blastdb_aliastool -gilist [*GI list filename*] -db nr -out [*sub-database name*] -title [*sub-database title*]`

### How many sequences in sub-databases?
* **Ecoli DB**: 149236
* **Mycoplasma**: 230866
* **Gram-positive bacteria**: 49749635
* **prokaryotes**: 204031745
* **bacteria**: 200863227


