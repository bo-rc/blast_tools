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

<img src="https://cloud.githubusercontent.com/assets/14265605/12404303/eda162c8-bdff-11e5-8f0d-0ea51570adfe.png" width="500">

## Arguments
**Clean Level** (`--clean`):
* `0`: temporary files are kept.
* `1`: temporary files and backwar-search files are deleted.
* `2`: profile database files are deleted + the effect of `1`
* `3`: psiblast last iteration report is deleted + the effect of `2`

