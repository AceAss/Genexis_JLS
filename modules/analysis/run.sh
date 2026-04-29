#!/bin/bash
set -euo pipefail

INPUT="$1"
DOMAIN="$2"
[[ ! -f "$INPUT" ]] && { echo "Error: File not found" >&2; exit 1; }
[[ -z "$DOMAIN" ]] && { echo "Error: Domain required" >&2; exit 1; }

mkdir -p results
OUTFILE="results/analysis_$(basename "$INPUT" .fasta)_$(date +%Y%m%d_%H%M%S).txt"
touch "$OUTFILE"

echo "📈 DOMAIN ANALYSIS: $DOMAIN" | tee "$OUTFILE"
echo "=============================" | tee -a "$OUTFILE"

declare -i HIGH_GC_COUNT=0 TOTAL_SEQS=0
declare -a HIGH_GC_SEQS

while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" ]] && continue
  
  if [[ "$line" == ">"* ]]; then
    [[ -n "${CURRENT_SEQ:-}" ]] && process_sequence
    CURRENT_NAME="$line"
    CURRENT_LEN=0
    CURRENT_GC=0
  else
    line=$(echo "$line" | tr -d '\n\r ' | tr 'a-z' 'A-Z')
    [[ -z "$line" ]] && continue
    LEN=${#line}
    GC=$(echo "$line" | grep -o '[GC]' | wc -l)
    ((CURRENT_LEN+=LEN))
    ((CURRENT_GC+=GC))
  fi
done < "$INPUT"

# Process final sequence
[[ -n "${CURRENT_SEQ:-}" ]] && process_sequence

process_sequence() {
  ((TOTAL_SEQS++))
  GC_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($CURRENT_GC/$CURRENT_LEN*100)}")
  
  INSIGHT="Normal"
  if [[ "$DOMAIN" == "cancer" && $(echo "$GC_PERCENT > 55" | bc -l) == 1 ]]; then
    INSIGHT="🚨 HIGH GC% - Cancer biomarker potential"
    ((HIGH_GC_COUNT++))
    HIGH_GC_SEQS+=("$CURRENT_NAME (GC: $GC_PERCENT%)")
  fi
  
  printf "%s\n  Length: %d bp\n  GC%%: %.1f%%\n  Insight: %s\n%s\n" \
    "$CURRENT_NAME" "$CURRENT_LEN" "$GC_PERCENT" "$INSIGHT" "─"×50 | tee -a "$OUTFILE"
}

# Summary
echo "" | tee -a "$OUTFILE"
echo "📊 SUMMARY" | tee -a "$OUTFILE"
echo "=============================" | tee -a "$OUTFILE"
printf "Total Sequences: %d\nHigh GC Sequences: %d (%.1f%%)\nOutput: %s\n" \
  "$TOTAL_SEQS" "$HIGH_GC_COUNT" $((HIGH_GC_COUNT*100/TOTAL_SEQS)) "$OUTFILE" | tee -a "$OUTFILE"

[[ ${#HIGH_GC_SEQS[@]} -gt 0 ]] && {
  echo "High GC Sequences:" | tee -a "$OUTFILE"
  printf '  %s\n' "${HIGH_GC_SEQS[@]}" | tee -a "$OUTFILE"
}

echo "[✔] Analysis saved to $OUTFILE"
