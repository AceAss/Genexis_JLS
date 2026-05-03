#!/bin/bash

INPUT="$1"
[[ ! -f "$INPUT" ]] && { echo "Error: Input file not found" >&2; exit 1; }

echo "🧬 ORF FINDER"
echo "-------------------------"

awk '
/^>/ {
    if (seq != "") find_orfs()
    seq = ""
    next
}
{
    gsub(/[ \t\r\n]+/, "", $0)
    seq = seq toupper($0)
}
END { if (seq != "") find_orfs() }

function find_orfs() {
    len = length(seq)
    for (i = 1; i <= len - 2; i++) {
        # Search for START codon
        if (substr(seq, i, 3) == "ATG") {
            # Search for STOP codon in the same frame
            for (j = i + 3; j <= len - 2; j += 3) {
                stop = substr(seq, j, 3)
                if (stop == "TAA" || stop == "TAG" || stop == "TGA") {
                    orf_seq = substr(seq, i, j - i + 3)
                    print "ORF Found | Start: " i " | End: " j+2 " | Length: " length(orf_seq)
                    print orf_seq
                    print "-------------------------"
                    # Advance outer loop to end of this ORF
                    i = j + 2 
                    break 
                }
            }
        }
    }
}' "$INPUT"
