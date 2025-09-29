#!/usr/bin/bash
#SBATCH --job-name=CellBender
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --gres=gpu:6   # Request 1 GPU
#SBATCH -c 48           # Cores per task requested
#SBATCH -o Outputs/%x_%j.o
#SBATCH -e Outputs/%x_%j.e
#SBATCH --mail-type=end,fail
#SBATCH --mail-user=pedro.ferreiro@rai.usc.es


# Check arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <input_h5_file> <output_directory>"
    echo "Note: Input should be a Cell Ranger raw output H5 file"
    exit 1
fi

INPUT_H5="$1"
OUTPUT_DIR="$2"

# Validations
if [[ ! -f "$INPUT_H5" ]]; then
    echo "ERROR: Input H5 file $INPUT_H5 does not exist"
    exit 1
fi

if [[ ! "$INPUT_H5" =~ \.h5$ ]]; then
    echo "ERROR: Input file must be an H5 file (.h5 extension)"
    exit 1
fi

# Create directories
mkdir -p Outputs
mkdir -p "$OUTPUT_DIR"

echo "=== Starting CellBender: $(date) ==="
echo "Input H5 file: $INPUT_H5"
echo "Output directory: $OUTPUT_DIR"

# Generate output filename based on input
base_name=$(basename "$INPUT_H5" .h5)
output_file="$OUTPUT_DIR/${base_name}_cellbender_filtered.h5"

echo "Output file: $output_file"

# Set locale and encoding variables for the HTML report generation
# echo "Setting UTF-8 locale..."
# export LC_ALL=en_US.UTF-8
# export LANG=en_US.UTF-8
# export PYTHONIOENCODING=utf-8

# Load required modules
echo "Loading Miniconda..."
module load cesga/system miniconda3/22.11.1-1

# Activate CellBender environment
echo "Activating CellBender environment..."
conda activate $STORE/envs/cellbender_commit4334e89

# Verify CellBender is available
echo "CellBender version: $(cellbender --version 2>&1 || echo 'CellBender not found')"

# Run CellBender with GPU acceleration
echo "=== Running CellBender remove-background ==="

cellbender remove-background \
    --cuda \
    --input "$INPUT_H5" \
    --output "$output_file" \
    --fpr 0.01 0.05 0.1
exit_code=$?

echo "=== Final summary: $(date) ==="
echo "Input: $INPUT_H5"
echo "Output: $output_file"
echo "Processing completed successfully"

# Deactivate conda environment
conda deactivate