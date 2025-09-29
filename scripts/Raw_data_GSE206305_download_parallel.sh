#!/usr/bin/bash
#SBATCH --job-name=GSE206305_download_Raw_data_parallel
#SBATCH --time=26:00:00
#SBATCH --cpus-per-task=6
#SBATCH --mem=20G
#SBATCH -o GSE206305_parallel.o     
#SBATCH -e GSE206305_parallel.e
#SBATCH --mail-type=end
#SBATCH --mail-user=pedro.ferreiro@rai.usc.es      # Mail when the job ends

echo "DOWNLOADING"
module load sra-toolkit

# Specify the directory where Raw_data will be downloaded
output_dir="/home/usc/gr/pfr/pfr/TFM/Raw_data"

THREADS=${SLURM_CPUS_PER_TASK:-1}

while read sample
do

echo $sample
prefetch --max-size u $sample
echo "fasterq-dump"

fasterq-dump --split-files --threads "$THREADS" -O "$output_dir" $sample

#If you have paired-end data
echo "Gzipping with pigz!"
if [[ -f "$output_dir/${sample}_1.fastq" ]]; then
    /bin/pigz -p "$THREADS" "$output_dir/${sample}_1.fastq"
fi
if [[ -f "$output_dir/${sample}_2.fastq" ]]; then
    /bin/pigz -p "$THREADS" "$output_dir/${sample}_2.fastq"
fi
echo "DONE!"

done < SRR_Acc_List_no_SRR19697621.txt