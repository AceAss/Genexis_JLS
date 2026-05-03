#!/bin/bash

INPUT="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFERENCE="$SCRIPT_DIR/reference.fasta"
WINDOW=100   # window size

[[ ! -f "$INPUT" ]] && { echo "Error: Input file not found"; exit 1; }
[[ ! -f "$REFERENCE" ]] && { echo "Error: Reference genome not found"; exit 1; }

echo "🧬 MUTATION + HOTSPOT DETECTOR"
echo "---------------------------------------"

awk -v W="$WINDOW" '
BEGIN { ref = "" }

# 1. Load the reference genome into memory ONCE
FNR==NR {
    if ($0 !~ /^>/) {
        gsub(/[ \t\r\n]+/, "", $0)
        ref = ref toupper($0)
    }
    next
}

# 2. Stream the input file sequence by sequence
/^>/ {
    if (seq_name != "") { analyze_mutations() }
    seq_name = $0
    seq = ""
    next
}
{
    gsub(/[ \t\r\n]+/, "", $0)
    seq = seq toupper($0)
}

# Process the final sequence
END {
    if (seq_name != "") { analyze_mutations() }
}

function analyze_mutations() {
    print "▶ Analyzing:", seq_name
    len_ref = length(ref)
    len_seq = length(seq)
    min_len = (len_ref < len_seq ? len_ref : len_seq)

    mut_count = 0; snp_count = 0; indel_count = 0
    delete window_mut

    for (i = 1; i <= min_len; i++) {
        ref_base = substr(ref, i, 1)
        seq_base = substr(seq, i, 1)

        if (ref_base != seq_base) {
            if (ref_base == "-" || seq_base == "-") {
                type = "INDEL"; indel_count++
            } else {
                type = "SNP"; snp_count++
            }
            mut_count++
            win = int((i-1)/W)
            window_mut[win]++
        }
    }

    if (len_seq > len_ref) { indel_count++ }
    else if (len_seq < len_ref) { indel_count++ }

    print "Total mutations :", mut_count
    print "SNPs            :", snp_count
    print "INDELs          :", indel_count

    threshold = W * 0.05
    for (w in window_mut) {
        count = window_mut[w]
        if (count >= threshold) {
            start = w * W + 1
            end = start + W - 1
            printf "🔥 HOTSPOT detected at region %d-%d (Mutations: %d)\n", start, end, count
        }
    }
    print "---------------------------------------"
}' "$REFERENCE" "$INPUT"
