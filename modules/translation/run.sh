#!/bin/bash

INPUT="$1"

# Check file
[[ ! -f "$INPUT" ]] && { echo "Error: File not found"; exit 1; }

echo "🧬 DNA → PROTEIN (FULL TRANSLATION)"
echo "-----------------------------------"

# Full codon table
declare -A CODON=(
[ATA]=I [ATC]=I [ATT]=I [ATG]=M
[ACA]=T [ACC]=T [ACG]=T [ACT]=T
[AAC]=N [AAT]=N [AAA]=K [AAG]=K
[AGC]=S [AGT]=S [AGA]=R [AGG]=R
[CTA]=L [CTC]=L [CTG]=L [CTT]=L
[CCA]=P [CCC]=P [CCG]=P [CCT]=P
[CAC]=H [CAT]=H [CAA]=Q [CAG]=Q
[CGA]=R [CGC]=R [CGG]=R [CGT]=R
[GTA]=V [GTC]=V [GTG]=V [GTT]=V
[GCA]=A [GCC]=A [GCG]=A [GCT]=A
[GAC]=D [GAT]=D [GAA]=E [GAG]=E
[GGA]=G [GGC]=G [GGG]=G [GGT]=G
[TCA]=S [TCC]=S [TCG]=S [TCT]=S
[TTC]=F [TTT]=F [TTA]=L [TTG]=L
[TAC]=Y [TAT]=Y [TAA]=* [TAG]=*
[TGC]=C [TGT]=C [TGA]=* [TGG]=W
)

SEQ_NAME=""
SEQUENCE=""

while read -r line; do
  if [[ "$line" == ">"* ]]; then

    # Process previous sequence
    if [[ -n "$SEQUENCE" ]]; then
      echo "$SEQ_NAME"

      PROT=""
      for ((i=0; i<${#SEQUENCE}-2; i+=3)); do
        COD=${SEQUENCE:$i:3}
        AA="${CODON[$COD]}"

        # Unknown codon → X
        [[ -z "$AA" ]] && AA="X"

        PROT+="$AA"
      done

      echo "Protein:"
      echo "$PROT"
      echo "Length (aa): ${#PROT}"
      echo "-----------------------------------"
    fi

    SEQ_NAME="$line"
    SEQUENCE=""

  else
    # Join multi-line FASTA
    SEQUENCE+=$(echo "$line" | tr 'a-z' 'A-Z' | tr -d ' \n\r')
  fi
done < "$INPUT"

# Last sequence
if [[ -n "$SEQUENCE" ]]; then
  echo "$SEQ_NAME"

  PROT=""
  for ((i=0; i<${#SEQUENCE}-2; i+=3)); do
    COD=${SEQUENCE:$i:3}
    AA="${CODON[$COD]}"
    [[ -z "$AA" ]] && AA="X"
    PROT+="$AA"
  done

  echo "Protein:"
  echo "$PROT"
  echo "Length (aa): ${#PROT}"
  echo "-----------------------------------"
fi

echo "[✔] Full translation complete"
