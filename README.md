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

