#!/bin/bash
set -euo pipefail

INPUT="$1"
DOMAIN="$2"
[[ ! -f "$INPUT" ]] && { echo "Error: File not found" >&2; exit 1; }
[[ -z "$DOMAIN" ]] && { echo "Error: Domain required" >&2; exit 1; }

mkdir -p results
OUTFILE="results/analysis_$(basename "$INPUT" .fasta)_$(date +%Y%m%d_%H%M%S).txt"
HIGH_GC_FILE="results/high_gc_temp_$$.txt"

echo "📈 DOMAIN ANALYSIS: $DOMAIN" | tee "$OUTFILE"
echo "=============================" | tee -a "$OUTFILE"

# Process everything in a single fast AWK stream
awk -v domain="$DOMAIN" -v high_gc_file="$HIGH_GC_FILE" '
BEGIN { total_seqs = 0; high_gc_count = 0 }
/^>/ {
    if (seq_name != "") { process_sequence() }
    seq_name = $0
    len = 0
    gc_count = 0
    next
}
{
    toupper($0)
    gsub(/[ \t\r\n]+/, "", $0)
    len += length($0)
    gc = $0
    gsub(/[^GC]/, "", gc)
    gc_count += length(gc)
}
END {
    if (seq_name != "") { process_sequence() }
    printf "\n📊 SUMMARY\n=============================\n"
    printf "Total Sequences: %d\n", total_seqs
    printf "High GC Sequences: %d (%.1f%%)\n", high_gc_count, (total_seqs > 0 ? (high_gc_count*100/total_seqs) : 0)
}
function process_sequence() {
    total_seqs++
    gc_percent = (len > 0) ? (gc_count / len * 100) : 0
    insight = "Normal"
    
    if (domain == "cancer" && gc_percent > 55) {
        insight = "🚨 HIGH GC% - Cancer biomarker potential"
        high_gc_count++
        # Write directly to disk to save RAM
        print seq_name " (GC: " sprintf("%.1f", gc_percent) "%)" >> high_gc_file
    }
    
    printf "%s\n  Length: %d bp\n  GC%%: %.1f%%\n  Insight: %s\n%s\n", seq_name, len, gc_percent, insight, "──────────────────────────────────────────────────"
}' "$INPUT" | tee -a "$OUTFILE"

# Merge the temp file back into the report if it exists
if [[ -f "$HIGH_GC_FILE" ]]; then
    echo "Output: $OUTFILE" | tee -a "$OUTFILE"
    echo "High GC Sequences:" | tee -a "$OUTFILE"
    sed "s/^/  /" "$HIGH_GC_FILE" | tee -a "$OUTFILE"
    rm "$HIGH_GC_FILE" # Clean up
else
    echo "Output: $OUTFILE" | tee -a "$OUTFILE"
fi

echo "[✔] Analysis saved to $OUTFILE"
