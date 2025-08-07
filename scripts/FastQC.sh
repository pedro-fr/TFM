#!/usr/bin/bash
#SBATCH --job-name=FastQC_Analysis
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH -o Outputs/%x_%j.o
#SBATCH -e Outputs/%x_%j.e
#SBATCH --mail-type=end,fail
#SBATCH --mail-user=pedro.ferreiro@rai.usc.es

# Check arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <input_directory> <output_directory>"
    echo "Example: sbatch $0 /path/to/fastq /path/to/output"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"

# Calculate threads from SLURM allocation
THREADS=${SLURM_CPUS_PER_TASK:-1}

# Validations
if [[ ! -d "$INPUT_DIR" ]]; then
    echo "ERROR: Input directory $INPUT_DIR does not exist"
    exit 1
fi

# Create directories
mkdir -p Outputs
mkdir -p "$OUTPUT_DIR"

echo "=== Starting FastQC Analysis: $(date) ==="
echo "Input directory: $INPUT_DIR"
echo "Output directory: $OUTPUT_DIR"
echo "Using $THREADS threads"

# Load required modules
module load fastqc

# Verify fastqc is available
echo "FastQC version: $(fastqc --version 2>&1 || echo 'FastQC not found')"

# Count files to process
total_files=$(find "$INPUT_DIR" -name "*.fastq.gz" -o -name "*.fq.gz" | wc -l)
echo "FASTQ files found: $total_files"

if [[ $total_files -eq 0 ]]; then
    echo "ERROR: No .fastq.gz or .fq.gz files found in $INPUT_DIR"
    exit 1
fi

# Process files
current=0
failed_files=0

for fastq_file in "$INPUT_DIR"/*.fastq.gz "$INPUT_DIR"/*.fq.gz; do
    # Check if file exists (in case glob finds nothing)
    [[ -f "$fastq_file" ]] || continue
    
    ((current++))
    base_name=$(basename "$fastq_file")
    
    echo "[$current/$total_files] Processing: $base_name"
    
    # Run FastQC with error handling
    set +e
    fastqc "$fastq_file" \
        --outdir "$OUTPUT_DIR" \
        --threads "$THREADS" \
        --quiet
    exit_code=$?
    set -e
    
    if [[ $exit_code -eq 0 ]]; then
        echo "✓ Completed: $base_name"
    else
        echo "✗ Error processing: $base_name (exit code: $exit_code)" >&2
        ((failed_files++))
    fi
    echo "---"
done

echo "=== Final summary: $(date) ==="
echo "Files processed: $current"
echo "Failed files: $failed_files"
echo "Output files generated: $(find "$OUTPUT_DIR" -name "*.html" | wc -l)"
echo "Disk usage: $(du -sh "$OUTPUT_DIR" | cut -f1)"

if [[ $failed_files -gt 0 ]]; then
    echo "WARNING: $failed_files files failed processing"
    exit 1
else
    echo "FastQC analysis completed successfully"
    echo "Reports available in: $OUTPUT_DIR"
fi