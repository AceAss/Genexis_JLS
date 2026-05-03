#!/bin/bash
set -euo pipefail  # Strict mode: exit on error or undefined vars

# Safely get the absolute path to the directory containing this script
# Using BASH_SOURCE prevents issues if the script is called via a symlink
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================"
echo "        GENEXIS TOOLKIT v2.0"
echo "======================================"

MODULE=""
INPUT=""
DOMAIN=""
PATTERN=""

# -------------------------------
# Argument Parsing
# -------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --module) MODULE="$2"; shift 2 ;;
    --input|-i) INPUT="$2"; shift 2 ;;
    --domain|-d) DOMAIN="$2"; shift 2 ;;
    --pattern|-p) PATTERN="$2"; shift 2 ;;
    --help|-h)
      cat << EOF
Usage: genexis --module <name> --input <file> [options]

Modules:
  seq-analysis, motif, translation, analysis, orf, mutation, assembly
EOF
      exit 0
      ;;
    *) echo "Error: Unknown option: $1" >&2; exit 1 ;;
  esac
done

# -------------------------------
# VALIDATION
# -------------------------------
[[ -z "$MODULE" ]] && { echo "Error: --module required" >&2; exit 1; }
[[ -z "$INPUT" ]] && { echo "Error: --input required" >&2; exit 1; }
[[ ! -f "$INPUT" ]] && { echo "Error: Input file '$INPUT' not found" >&2; exit 1; }

# -------------------------------
# DISPATCHER (FORCE ABSOLUTE PATHS)
# -------------------------------
# By using the full path to run.sh, we prevent the script from 
# accidentally calling the 'genexis' global command and looping
case $MODULE in
  seq-analysis) bash "$BASE_DIR/../modules/seq-analysis/run.sh" "$INPUT" ;;
  motif)        bash "$BASE_DIR/../modules/motif/run.sh" "$INPUT" "$PATTERN" ;;
  translation)  bash "$BASE_DIR/../modules/translation/run.sh" "$INPUT" ;;
  analysis)     bash "$BASE_DIR/../modules/analysis/run.sh" "$INPUT" "$DOMAIN" ;;
  orf)          bash "$BASE_DIR/../modules/ORF/run.sh" "$INPUT" ;;
  mutation)     bash "$BASE_DIR/../modules/mutation/run.sh" "$INPUT" ;;
  assembly)     bash "$BASE_DIR/../modules/assembly/run.sh" "$INPUT" ;;
  *) echo "Error: Invalid module '$MODULE'." >&2; exit 1 ;;
esac

echo "[✔] GENEXIS COMPLETED SUCCESSFULLY"
