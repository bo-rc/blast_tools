# blast_tools
Automation tools for BLAST

# psiblast

# Build a local database
Use the perl scripts provided by NCBI.

* Go to the path of your local database directory
* Download database:
`./update_blastdb.pl nr pdbaa --decompress`
* Build taxonomy ID:
`./update_blastdb.pl taxdb; tar -xzf taxdb.tar.gz`

**Clean Level**:
* `0`: temporary files are kept.
* `1`: temporary files and backwar-search files are deleted.
* `2`: profile database files are deleted + the effect of `1`
* `3`: psiblast last iteration report is deleted + the effect of `2`

