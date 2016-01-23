# blast_tools
Automation tools for BLAST+ 

# Build a local database
Use the `update_blastdb.pl` perl scripts provided by NCBI:
* Go to the path of your local database directory
* Download database:
`./update_blastdb.pl nr pdbaa --decompress`
* Build taxonomy ID:
`./update_blastdb.pl taxdb; tar -xzf taxdb.tar.gz`

# BLAST for proteins: `blastp_formater.sh`

# PSIBLAST for proteins: `psiblast_formater.sh`

## Flow Chart

<img src="https://cloud.githubusercontent.com/assets/14265605/12404303/eda162c8-bdff-11e5-8f0d-0ea51570adfe.png" width="640">

## Arguments
**Clean Level** (`--clean`):
* `0`: temporary files are kept.
* `1`: temporary files and backwar-search files are deleted.
* `2`: profile database files are deleted + the effect of `1`
* `3`: psiblast last iteration report is deleted + the effect of `2`

# How to build a sub-database with NCBI nr database

1. Download the prebuilt nr database (ncbi).
2. Search the [Entrez Protein database](http://www.ncbi.nlm.nih.gov/protein) with query: "gram-positive bacteria"
3. Select "Send to File" and choose format "GI list"
4. Use the list of GIs from the previous step with the `blastdb_aliastool` to build an aliased blastdb of just gram-positive bacteria (takes several seconds): `blastdb_aliastool -gilist gram-positive-bacteria.gi_list.txt -db nr -out nr_gpb -title nr_gpb`



