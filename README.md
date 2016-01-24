# blast_tools
Flexible automation tools for BLAST+ 

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


