#!/bin/bash

REFERENCE="$1"
READ_LEN=50        # length of each read
NUM_READS=20       # number of reads
ERROR_RATE=0.02    # 2% error rate

[[ ! -f "$REFERENCE" ]] && { echo "Error: Reference file not found"; exit 1; }

echo "🧬 SYNTHETIC READ GENERATOR (WITH ERRORS)"
echo "------------------------------------------"

awk -v L="$READ_LEN" -v N="$NUM_READS" -v ERR="$ERROR_RATE" '
BEGIN {
    srand()
    bases[1]="A"; bases[2]="T"; bases[3]="G"; bases[4]="C"
}

# Read reference
!/^>/ {
    seq = seq toupper($0)
}

END {
    len = length(seq)

    for (r = 1; r <= N; r++) {

        # pick random start
        start = int(rand() * (len - L)) + 1
        read = substr(seq, start, L)

        # introduce errors
        mutated = ""
        for (i = 1; i <= length(read); i++) {

            base = substr(read, i, 1)

            if (rand() < ERR) {
                # mutate base (SNP)
                new_base = base
                while (new_base == base) {
                    new_base = bases[int(rand()*4)+1]
                }
                mutated = mutated new_base
            } else {
                mutated = mutated base
            }
        }

        # print FASTA format
        printf(">read_%d_pos_%d\n%s\n", r, start, mutated)
    }
}
' "$REFERENCE"
