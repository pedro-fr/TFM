#!/usr/bin/env bash
# filepath: /home/usc/gr/pfr/pfr/TFM/Scripts/rename_fastq_biosample.sh

csv="/home/usc/gr/pfr/pfr/TFM/Raw_data/SraRunTable.csv"
raw_dir="/home/usc/gr/pfr/pfr/TFM/Raw_data"
out_dir="/home/usc/gr/pfr/pfr/TFM/prueba_subida"

# Extrae SRR y BioSample (columna 1 y 7)
awk -F',' 'NR>1 {print $1,$7}' "$csv" | while read SRR BIOSAMPLE; do
    # Renombra R1
    if [[ -f "$raw_dir/${SRR}_1.fastq.gz" ]]; then
        mv "$raw_dir/${SRR}_1.fastq.gz" "$out_dir/${BIOSAMPLE}_S1_L001_R1_001.fastq.gz"
    fi
    # Renombra R2
    if [[ -f "$raw_dir/${SRR}_2.fastq.gz" ]]; then
        mv "$raw_dir/${SRR}_2.fastq.gz" "$out_dir/${BIOSAMPLE}_S1_L001_R2_001.fastq.gz"
    fi
done