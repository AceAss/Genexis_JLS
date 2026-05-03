#!/bin/bash

INPUT="$1"
[[ ! -f "$INPUT" ]] && { echo "Error: File not found"; exit 1; }

echo "🧬 DNA → PROTEIN (FULL TRANSLATION)"
echo "-----------------------------------"

awk '
BEGIN {
    # Initialize Codon Dictionary
    split("ATA I ATC I ATT I ATG M ACA T ACC T ACG T ACT T AAC N AAT N AAA K AAG K AGC S AGT S AGA R AGG R CTA L CTC L CTG L CTT L CCA P CCC P CCG P CCT P CAC H CAT H CAA Q CAG Q CGA R CGC R CGG R CGT R GTA V GTC V GTG V GTT V GCA A GCC A GCG A GCT A GAC D GAT D GAA E GAG E GGA G GGC G GGG G GGT G TCA S TCC S TCG S TCT S TTC F TTT F TTA L TTG L TAC Y TAT Y TAA * TAG * TGC C TGT C TGA * TGG W", dict, " ")
    for(i=1; i<=length(dict); i+=2) codon[dict[i]] = dict[i+1]
}
/^>/ {
    if (seq_name != "") translate()
    seq_name = $0
    seq = ""
    next
}
{
    gsub(/[ \t\r\n]+/, "", $0)
    seq = seq toupper($0)
}
END { if (seq_name != "") translate() }

function translate() {
    print seq_name
    prot = ""
    len = length(seq)
    for(i=1; i<=len-2; i+=3) {
        c = substr(seq, i, 3)
        aa = codon[c]
        prot = prot (aa ? aa : "X")
    }
    print "Protein:\n" prot
    print "Length (aa): " length(prot)
    print "-----------------------------------"
}' "$INPUT"
