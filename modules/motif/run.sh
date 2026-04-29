#!/bin/bash

INPUT="$1"
PATTERN="$2"

[[ ! -f "$INPUT" ]] && { echo "File not found"; exit 1; }
[[ -z "$PATTERN" ]] && { echo "Pattern missing"; exit 1; }

echo "🔍 MOTIF SEARCH: $PATTERN"
echo "-------------------------"

SEQ_NAME=""
SEQUENCE=""

while read -r line; do
  if [[ "$line" == ">"* ]]; then

    # Process previous sequence
    if [[ -n "$SEQUENCE" ]]; then
      echo "$SEQ_NAME"

      MATCH=$(echo "$SEQUENCE" | grep -b -o "$PATTERN")

      [[ -z "$MATCH" ]] && echo "No match found" || echo "$MATCH"

      echo "-------------------------"
    fi

    SEQ_NAME="$line"
    SEQUENCE=""

  else
    SEQUENCE+=$(echo "$line" | tr -d ' \n\r')
  fi

done < "$INPUT"

# Process last sequence
if [[ -n "$SEQUENCE" ]]; then
  echo "$SEQ_NAME"
  MATCH=$(echo "$SEQUENCE" | grep -b -o "$PATTERN")
  [[ -z "$MATCH" ]] && echo "No match found" || echo "$MATCH"
  echo "-------------------------"
fi
