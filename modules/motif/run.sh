#!/bin/bash

INPUT="$1"
PATTERN="$2"

[[ ! -f "$INPUT" ]] && { echo "File not found"; exit 1; }
[[ -z "$PATTERN" ]] && { echo "Pattern missing"; exit 1; }

echo "🔍 MOTIF SEARCH: $PATTERN"
echo "-------------------------"

awk -v pat="$PATTERN" '
/^>/ {
    if (seq_name != "") search_motif()
    seq_name = $0
    seq = ""
    next
}
{
    gsub(/[ \t\r\n]+/, "", $0)
    seq = seq toupper($0)
}
END { if (seq_name != "") search_motif() }

function search_motif() {
    print seq_name
    len_pat = length(pat)
    temp_seq = seq
    offset = 0
    found = 0
    
    while ((idx = index(temp_seq, pat)) > 0) {
        # Outputs 0-based index to match standard grep -b behavior
        print (offset + idx - 1) ":" pat
        offset += idx + len_pat - 1
        temp_seq = substr(temp_seq, idx + len_pat)
        found = 1
    }
    
    if (found == 0) print "No match found"
    print "-------------------------"
}' "$INPUT"
