#!/bin/bash

INPUT="$1"
[[ ! -f "$INPUT" ]] && { echo "File not found"; exit 1; }

echo "🧬 ORF FINDER"
echo "-------------------------"

awk '
/^>/ {
    if (seq_name != "") find_orfs()
    seq_name = $0
    seq = ""
    next
}
{
    gsub(/[ \t\r\n]+/, "", $0)
    seq = seq toupper($0)
}
END { if (seq_name != "") find_orfs() }

function find_orfs() {
    print seq_name
    len = length(seq)
    found = 0
    for(i=1; i<=len-2; i++) {
        if(substr(seq, i, 3) == "ATG") {
            for(j=i+3; j<=len-2; j+=3) {
                stop = substr(seq, j, 3)
                if(stop == "TAA" || stop == "TAG" || stop == "TGA") {
                    orf = substr(seq, i, j-i+3)
                    print "ORF found:"
                    print "Start : " i-1
                    print "End   : " j+2
                    print "Length: " length(orf)
                    print "Seq   : " orf
                    print "-------------------------"
                    found = 1
                    break 2
                }
            }
        }
    }
}' "$INPUT"
