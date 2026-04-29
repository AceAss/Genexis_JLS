#!/bin/bash

INPUT="$1"

[[ ! -f "$INPUT" ]] && { echo "File not found"; exit 1; }

echo "🧬 ORF FINDER"
echo "-------------------------"

SEQ_NAME=""
SEQUENCE=""

START_CODON="ATG"
STOP_CODONS=("TAA" "TAG" "TGA")

find_orfs() {
  local seq="$1"

  for ((i=0; i<${#seq}-2; i++)); do
    codon=${seq:$i:3}

    if [[ "$codon" == "$START_CODON" ]]; then
      for ((j=i+3; j<${#seq}-2; j+=3)); do
        stop=${seq:$j:3}

        for sc in "${STOP_CODONS[@]}"; do
          if [[ "$stop" == "$sc" ]]; then
            ORF_SEQ=${seq:$i:$((j-i+3))}
            LEN=${#ORF_SEQ}

            echo "ORF found:"
            echo "Start : $i"
            echo "End   : $((j+2))"
            echo "Length: $LEN"
            echo "Seq   : $ORF_SEQ"
            echo "-------------------------"

            break 2
          fi
        done
      done
    fi
  done
}

while read -r line; do
  if [[ "$line" == ">"* ]]; then

    if [[ -n "$SEQUENCE" ]]; then
      echo "$SEQ_NAME"
      find_orfs "$SEQUENCE"
    fi

    SEQ_NAME="$line"
    SEQUENCE=""

  else
    SEQUENCE+=$(echo "$line" | tr 'a-z' 'A-Z' | tr -d ' \n\r')
  fi

done < "$INPUT"

# last sequence
if [[ -n "$SEQUENCE" ]]; then
  echo "$SEQ_NAME"
  find_orfs "$SEQUENCE"
fi
