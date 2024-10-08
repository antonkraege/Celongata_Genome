#!/bin/bash

#Raven hybrid assembly 

raven -t 90 m64093_220722_215755.hifi_reads.fastq.gz /DATA_RAID/echavarr/data/Celongata_478-15_PacBio/wtdbg2/Celongata_SAG216-3B_Nanoporereads.correctedReads.fasta.gz > Celongata_SAG216-3B_hybrid.fasta

#juicer Assembly polishing using HiC reads 
# indexing the draft assembly using bwa
bwa index /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/juicer/references/Celongata_SAG216-3B_hybrid.fasta

#generating the digestion sites with juicer 
python ../juicer/misc/generate_site_positions.py Arima Celongata /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/juicer/references/Celongata_SAG216-3B_hybrid.fasta

#polishing of draft assembly with juicer and 3d-dna
../juicer/scripts/juicer.sh -g Celongata -s Arima -z ./references/Celongata_SAG216-3B_hybrid.fasta -y ./restriction_sites/Celongata_Arima.txt -t 80 -p ./references/Celongata_chrsize.txt -D /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/juicer/
../3d-dna/run-asm-pipeline.sh ../juicer/references/Celongata_SAG216-3B_hybrid.fasta ../juicer/aligned/merged_nodups.txt 

#manual assembly curation with juicebox 
#mapping of ONT reads to the polished assembly with minimap2 for quality control 

minimap2 -d Celongata_SAG216-3B_hybrid.fasta.FINAL Celongata_SAG216-3B_hybrid.fasta.FINAL.fasta
minimap2 -a Celongata_SAG216-3B_hybrid.fasta.FINAL /ONTreads/ > ONT-mapping-assembly.sam
samtools sort ONT-mapping-assembly.sam > ONT-mapping-assembly.bam
samttols index ONT-mapping-assembly.bam

#Identification of telomeric repeats with tapestry
weave -a annotation/Celongata_SAG216-3B_hybrid.FINAL_polished1_m.fasta -r /DATA_RAID/echavarr/data/Celongata_478-15_PacBio/m64093_220722_215755.hifi_reads.fastq.gz -d 5000 -t AACCCT -c 80 -o tapestry_new/

#Identification of potential contaminations with Blobtools 
minimap2 -d ../Celongata_SAG216-3B_hybrid.FINAL_polished1_m ../Celongata_SAG216-3B_hybrid.FINAL_polished1_m.fasta
minimap2 -x map-hifi ../Celongata_SAG216-3B_hybrid.FINAL_polished1_m /DATA_RAID/echavarr/data/Celongata_478-15_PacBio/m64093_220722_215755.hifi_reads.fastq.gz > mapped_PacBio_to_Ce.bam
blastn -query ../../genome-manual2/Celongata_SAG216-3B_hybrid.FINAL_polished1_m.fasta -db /DATA_RAID2/akraege/NCBI/blastn/ -outfmt ’6 qseqid staxids bitscore std’ -max_target_seqs 1 -max_hsps 1 -evalue 1e-25 -out assembly_vs_nt
./blobtools view -i /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/Blobplot/run4/test21.blobDB.json && ./blobtools plot -i /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/Blobplot/run4/test21.blobDB.json
./blobtools create -i /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/genome-manual2/Cm_478-11_final_genome_m_21.fasta --db ./data/nodesDB.txt -t ../data/ assembly_vs_nt -b /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/genome-manual2/map-ONT/mapped_PacBio_to_Ce_sorted.bam -o /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/Blobplot/run4/test212 -r order
./blobtools plot -o genus -r genus --colours colorfile.csv --format pdf -i /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/Blobplot/run4/test212.blobDB.json

#KAT-plot to check completeness of the assembly and retrieve ploidy information
kat comp -t 80 -o kat-comp-main ../Celongata_final_genome_m_21 /DATA_RAID/echavarr/data/Celongata_478-15_PacBio/m64093_220722_215755.hifi_reads.fastq.gz /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/genome-manual2/Celongata_SAG216-3B_hybrid.FINAL_polished1_m.fasta
kat plot spectra-cn -x 800 -o beautiful_kmer_plot.svg kat-comp-main.mx
