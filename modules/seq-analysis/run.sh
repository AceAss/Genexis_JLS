#!/bin/bash

INPUT="$1"

if [[ ! -f "$INPUT" ]]; then
  echo "Error: File not found"
  exit 1
fi

echo "SEQUENCE ANALYSIS"
echo "-------------------------"

SEQ_NAME=""
SEQUENCE=""
COUNT=0

while read -r line; do
  if [[ "$line" == ">"* ]]; then

    # Process previous sequence (if exists)
    if [[ -n "$SEQUENCE" ]]; then
      ((COUNT++))
      LEN=${#SEQUENCE}

      if [[ $LEN -gt 0 ]]; then
        GC=$(echo "$SEQUENCE" | grep -o "[GCgc]" | wc -l)
        GC_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($GC/$LEN)*100}")
      else
        GC_PERCENT=0
      fi

      echo "$SEQ_NAME"
      echo "Length : $LEN"
      echo "GC %   : $GC_PERCENT"
      echo "-------------------------"
    fi

    # Reset for new sequence
    SEQ_NAME="$line"
    SEQUENCE=""

  else
    # Append sequence lines (IMPORTANT FIX)
    SEQUENCE+=$(echo "$line" | tr -d ' \n\r')
  fi

done < "$INPUT"

# Process last sequence
if [[ -n "$SEQUENCE" ]]; then
  ((COUNT++))
  LEN=${#SEQUENCE}

  if [[ $LEN -gt 0 ]]; then
    GC=$(echo "$SEQUENCE" | grep -o "[GCgc]" | wc -l)
    GC_PERCENT=$(awk "BEGIN {printf \"%.2f\", ($GC/$LEN)*100}")
  else
    GC_PERCENT=0
  fi

  echo "$SEQ_NAME"
  echo "Length : $LEN"
  echo "GC %   : $GC_PERCENT"
  echo "-------------------------"
fi

echo "Total sequences: $COUNT"
