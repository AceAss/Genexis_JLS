# 🧬 GENEXIS TOOLKIT v2.0

Genexis Toolkit v2.0 is a robust, memory-efficient command-line utility built entirely in Bash for high-throughput bioinformatics analysis. Designed to bridge the gap between complex genomic algorithms and lightweight terminal environments, Genexis provides a highly modular suite of tools for sequence analysis, genome assembly, motif discovery, and mutation detection.

Built with a focus on streaming architecture, it bypasses the typical memory bottlenecks associated with large-scale genomic data, allowing researchers to process massive FASTA files on standard hardware.

---

## 🚀 Performance & Scalability

Genexis is engineered for scale. Utilizing highly optimized `awk` processing and line-by-line sequence reading, the toolkit avoids loading entire datasets into memory. 
* **High-Throughput Capacity:** Capable of handling large-scale genomic datasets, easily processing **over 500,000 sequences (5 Lakhs+)** in a single run.
* **Large File Optimization:** Built-in validation checks automatically detect files exceeding 1GB to optimize memory allocation and parsing strategies.
* **Native Execution:** Relies entirely on native Unix utilities (`grep`, `awk`, `tr`, `bc`), ensuring lightning-fast execution without the overhead of heavy external dependencies like Python or Java.

---

## 🧰 Core Modules

The toolkit is divided into specialized modules, each targeting a specific bioinformatics pipeline:

### 1. Domain Analysis (`analysis`)
Evaluates sequences for specific structural domains and biomarkers.
* **Cancer Biomarker Detection:** Identifies sequences with a high GC percentage (>55%), flagging them for potential oncogenic relevance.
* **Automated Reporting:** Generates timestamped summary reports detailing length, GC percentage, and structural insights for every sequence.

### 2. Genome Assembly (`assembly`)
Reconstructs continuous genomes from fragmented reads using an Epic Greedy Overlap algorithm.
* Custom minimum overlap thresholds.
* Iterative read-merging with verbose logging to track assembly steps.
* Generates a final assembled genome sequence with a detailed summary of read counts and merge iterations.

### 3. Mutation & Hotspot Detector (`mutation`)
Performs comparative genomics by aligning sample sequences against a reference genome.
* **Variant Calling:** Detects and classifies Single Nucleotide Polymorphisms (SNPs) and Insertions/Deletions (INDELs).
* **Hotspot Mapping:** Utilizes a 100bp sliding window to calculate mutation density. Automatically flags "Hotspots" if the mutation rate exceeds a 5% threshold within a given window.

### 4. Motif Search (`motif`)
Rapidly scans multi-sequence FASTA files for specific DNA patterns.
* Outputs precise nucleotide positions for every pattern match within the sequence.
* Seamlessly handles multi-line FASTA formatting.

### 5. Translation (`translation`)
Executes full-sequence DNA-to-Protein translation.
* Utilizes a complete, hardcoded standard genetic code table for all 64 codons.
* Handles unknown or ambiguous codons by outputting `X`.

### 6. Open Reading Frame (ORF) Finder (`orf`)
Scans raw sequences to identify potential protein-coding regions.
* Detects standard `ATG` start codons.
* Scans in-frame to locate `TAA`, `TAG`, or `TGA` stop codons, outputting the exact start/end positions, lengths, and translated sequences.

### 7. Synthetic Read Generator (`reads-gen`)
A utility for testing and simulating sequencer outputs.
* Generates random reads of specified lengths from a reference genome.
* **Error Simulation:** Injects synthetic sequencing errors (SNPs) at a customizable error rate (default 2%) to mimic real-world Illumina/Nanopore data.

### 8. Basic Sequence Analysis (`seq-analysis`)
A rapid profiling tool for calculating sequence length, GC content, and sequence counts across massive FASTA files.

---

## ⚙️ Installation

The toolkit includes an automated deployment script that configures permissions and creates system-wide symlinks.
```bash
# Navigate to the project directory
cd genexis-toolkit

# Make the installer executable
chmod +x install.sh

# Run the installation script (requires sudo for symlinking to /usr/local/bin)
./install.sh
```

Once installed, verify the installation by typing:
```bash
genexis --help
```

---

## 💻 Usage & Syntax

Genexis utilizes a central dispatcher to route commands to the appropriate module.

**Basic Syntax:**
```bash
genexis --module <module_name> --input <file.fasta> [options]
```

**Workflow Examples:**

* **Run a rapid GC% and length check on a massive dataset:**
  
```bash
  genexis --module seq-analysis --input genome_data.fasta
  ```
* **Search for a specific regulatory motif (e.g., TATA box):**
  ```bash
  genexis --module motif --input promoters.fasta --pattern TATAAA
  ```
* **Perform cancer biomarker analysis on sequence data:**
  ```bash
  genexis --module analysis --input samples.fasta --domain cancer
  ```
* **Translate a finalized transcript assembly into proteins:**
  ```bash
  genexis --module translation --input transcripts.fasta
  ```

---

## 👥 Project Contributors

This toolkit is developed and maintained by:
* **Satyakam Tripathy** - Lead Developer
* **Jonney Reji Thaliath** - Collaborator
* **Lokesh A** - Collaborator
