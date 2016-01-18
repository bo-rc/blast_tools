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

![blast-protocol](https://cloud.githubusercontent.com/assets/14265605/12404273/aa8223b0-bdff-11e5-9173-679cabd8997c.png)

## Arguments
**Clean Level** (`--clean`):
* `0`: temporary files are kept.
* `1`: temporary files and backwar-search files are deleted.
* `2`: profile database files are deleted + the effect of `1`
* `3`: psiblast last iteration report is deleted + the effect of `2`

