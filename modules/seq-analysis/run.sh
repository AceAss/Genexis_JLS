#!/bin/bash

INPUT="$1"

if [[ ! -f "$INPUT" ]]; then
  echo "Error: File not found"
  exit 1
fi

echo "SEQUENCE ANALYSIS"
echo "-------------------------"

awk '
# When we hit a new sequence header
/^>/ {
    # If we already have a sequence loaded, calculate and print it
    if (seq_name != "") {
        gc_percent = (len > 0) ? (gc_count / len * 100) : 0
        printf "%s\nLength : %d\nGC %%   : %.2f\n-------------------------\n", seq_name, len, gc_percent
        count++
    }
    # Reset for the new sequence
    seq_name = $0
    len = 0
    gc_count = 0
    next
}
# For sequence lines
{
    # Remove all spaces and newlines
    gsub(/[ \t\r\n]+/, "", $0)
    len += length($0)
    
    # Extract only G and C characters and count them
    gc = $0
    gsub(/[^GCgc]/, "", gc)
    gc_count += length(gc)
}
# Process the very last sequence in the file
END {
    if (seq_name != "") {
        gc_percent = (len > 0) ? (gc_count / len * 100) : 0
        printf "%s\nLength : %d\nGC %%   : %.2f\n-------------------------\n", seq_name, len, gc_percent
        count++
    }
    print "Total sequences: " count
}' "$INPUT"
