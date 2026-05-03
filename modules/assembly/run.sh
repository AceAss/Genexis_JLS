#!/bin/bash

INPUT="$1"
MIN_OVERLAP=3
VERBOSE=1

[[ ! -f "$INPUT" ]] && { echo "Error: Input file not found"; exit 1; }

echo "🧬 GENOME ASSEMBLY (EPIC GREEDY OVERLAP)"
echo "---------------------------------------"

# Load reads (FASTA → array)
mapfile -t reads < <(grep -v ">" "$INPUT" | tr 'a-z' 'A-Z')

TOTAL_READS=${#reads[@]}
MERGE_COUNT=0
STEP=1

# Function: overlap calculation
overlap() {
  a="$1"
  b="$2"
  max=0

  len_a=${#a}
  len_b=${#b}
  min_len=$(( len_a < len_b ? len_a : len_b ))

  for ((k=1; k<=min_len; k++)); do
    if [[ "${a: -k}" == "${b:0:k}" ]]; then
      max=$k
    fi
  done

  echo $max
}

# Assembly loop
while [[ ${#reads[@]} -gt 1 ]]; do

  best_i=0
  best_j=1
  best_ov=0

  # Find best overlap
  for ((i=0; i<${#reads[@]}; i++)); do
    for ((j=0; j<${#reads[@]}; j++)); do
      [[ $i -eq $j ]] && continue

      ov=$(overlap "${reads[i]}" "${reads[j]}")

      if [[ $ov -gt $best_ov ]]; then
        best_ov=$ov
        best_i=$i
        best_j=$j
      fi
    done
  done

  # Stop if no good overlap
  if [[ $best_ov -lt $MIN_OVERLAP ]]; then
    echo "⚠️ No significant overlaps found (threshold=$MIN_OVERLAP)"
    break
  fi

  a="${reads[best_i]}"
  b="${reads[best_j]}"

  # ✅ FIXED MERGE (IMPORTANT)
  merged="${a}${b:$best_ov}"

  # Verbose logs
  if [[ $VERBOSE -eq 1 ]]; then
    echo "[STEP $STEP]"
    echo "READ A : $a"
    echo "READ B : $b"
    echo "Overlap: $best_ov bp"
    echo "Merged : $merged"
    echo "---------------------------------------"
  fi

  ((STEP++))
  ((MERGE_COUNT++))

  # Remove merged reads
  new_reads=()
  for ((k=0; k<${#reads[@]}; k++)); do
    [[ $k -eq $best_i || $k -eq $best_j ]] && continue
    new_reads+=("${reads[k]}")
  done

  new_reads+=("$merged")
  reads=("${new_reads[@]}")

done

# Final sequence
FINAL_SEQ="${reads[0]}"

echo "======================================="
echo "🧬 FINAL ASSEMBLED GENOME"
echo "======================================="

# Print nicely (FASTA-style wrapping)
echo "$FINAL_SEQ" | fold -w 80

echo ""
echo "========= ASSEMBLY SUMMARY ========="
echo "Reads          : $TOTAL_READS"
echo "Final Length   : ${#FINAL_SEQ}"
echo "Merges         : $MERGE_COUNT"
echo "Min Overlap    : $MIN_OVERLAP"
echo "===================================="
