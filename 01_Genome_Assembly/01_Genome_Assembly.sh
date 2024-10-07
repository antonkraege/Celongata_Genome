#!/bin/bash

#Raven hybrid assembly 

raven -t 90 m64093_220722_215755.hifi_reads.fastq.gz /DATA_RAID/echavarr/data/Celongata_478-15_PacBio/wtdbg2/Celongata_SAG216-3B_Nanoporereads.correctedReads.fasta.gz > Celongata_SAG216-3B_hybrid.fasta

#juicer Assembly polishing using HiC reads 
# indexing the draft assembly using bwa
bwa index /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/juicer/references/Cm_478-11_PacBio_27ctgs.fasta

#generating the digestion sites with juicer 
python ../juicer/misc/generate_site_positions.py Arima Cm_478-11 /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/juicer/references/Cm_478-11_PacBio_27ctgs.fasta

#polishing of draft assembly with juicer and 3d-dna
../juicer/scripts/juicer.sh -g Cm_478-11 -s Arima -z ./references/Cm_478-11_PacBio_27ctgs.fasta -y ./restriction_sites/Cm_478-11_Arima.txt -t 80 -p ./references/Cm-478-11_chrsize.txt -D /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/juicer/
../3d-dna/run-asm-pipeline.sh ../juicer/references/Cm_478-11_PacBio_27ctgs.fasta ../juicer/aligned/merged_nodups.txt 

#manual assembly curation with juicebox 
#mapping of ONT reads to the polished assembly with minimap2 for quality control 

minimap2 -d Cm_478-11_PacBio_27ctgs.FINAL Cm_478-11_PacBio_27ctgs.FINAL.fasta
minimap2 -a Cm_478-11_PacBio_27ctgs.FINAL /ONTreads/ > ONT-mapping-assembly.sam
samtools sort ONT-mapping-assembly.sam > ONT-mapping-assembly.bam
samttols index ONT-mapping-assembly.bam

#Identification of telomeric repeats with tapestry
weave -a 3d-genome-final4/Cm_478-11_PacBio_27ctgs.FINAL.fasta -r /DATA_RAID/echavarr/data/Cm_478-11_PacBio/m64093_220530_102118.hifi_reads.fastq.gz -t AACCCT -c 80 -o tapestry

#Identification of potential contaminations with Blobtools 
minimap2 -d ../Cm_478-11_final_genome_m_21 ../Cm_478-11_final_genome_m_21.fasta
minimap2 -x map-hifi ../Cm_478-11_final_genome_m_21 /DATA_RAID/echavarr/data/Cm_478-11_PacBio/m64093_220530_102118.hifi_reads.fastq.gz > mapped_PacBio_to_21.bam
blastn -query ../../genome-manual2/Cm_478-11_final_genome_m_21.fasta -db /DATA_RAID2/akraege/NCBI/blastn/ -outfmt ’6 qseqid staxids bitscore std’ -max_target_seqs 1 -max_hsps 1 -evalue 1e-25 -out assembly21_vs_nt
./blobtools view -i /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/Blobplot/run4/test21.blobDB.json && ./blobtools plot -i /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/Blobplot/run4/test21.blobDB.json
./blobtools create -i /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/genome-manual2/Cm_478-11_final_genome_m_21.fasta --db ./data/nodesDB.txt -t ../data/ assembly21_vs_nt -b /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/genome-manual2/map-ONT/mapped_PacBio_to_21_sorted.bam -o /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/Blobplot/run4/test212 -r order
./blobtools plot -o genus -r genus --colours colorfile.csv --format pdf -i /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/Blobplot/run4/test212.blobDB.json

#KAT-plot to check completeness of the assembly and retrieve ploidy information
