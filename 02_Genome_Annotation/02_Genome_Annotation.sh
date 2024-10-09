#!/bin/bash

#Mapping of RNAseq reads to the final genome assembly
hisat2-build -p 80 Celongata_SAG216-3B_hybrid.FINAL_polished1_m.fasta Celongata_hisat2-index
hisat2 --sensitive --summary-file ./ -p 80 -x Celongata_hisat2-index -1 /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/RNAseq/DE51NGSUKBR128750_Ce_S2_R1_001.fastq.gz -2 /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/RNAseq/DE51NGSUKBR128750_Ce_S2_R2_001.fastq.gz -S RNAseq_to_Celongata.sam

#annotation of genome with braker
braker.pl --species=Celongata --cores=80 --GENEMARK_PATH=/home/akraege/gmes_linux_64_4/ --genome=/DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/genome-manual2/Celongata_SAG216-3B_hybrid.FINAL_polished1_m.fasta --bam ./mapped_reads/RNAseq_to_Celongata.bam

#quality control of braker annotation with BUSCO
busco -i ../Braker2/braker/braker_aa.fasta -o Celongata_final_m -l chlorophyta -c 40 -m prot

#annotation of secreated proteins with signalp6
signalp6 --mode slow-sequential --output_dir Signalp6/ --fastafile RNAseq/braker/Celongata/braker.aa

#Annotation of repeats with repeat
BuildDatabase -name Celongata-genome-final /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/genome-manual2/Celongata_SAG216-3B_hybrid.FINAL_polished1_m.fasta
RepeatModeler -database /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/Reapeatmodeler/database/Celongata-genome-final -pa 20
reasonaTE -mode annotate -projectFolder /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/Reapeatmodeler/ -projectName Celongata -tool all
TEclassTest.pl -o /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/Reapeatmodeler/ Celongata_SAG216-3B_hybrid.FINAL_polished1_m.fasta
RepeatMasker -pa 20 -dir . -xsmall -gff -excln -lib /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/Reapeatmodeler/database/Celongata-genome-final-families.fa /DATA_RAID2/akraege/Hanna_Genome_Assembly/Celongata/genome-manual2/Celongata_SAG216-3B_hybrid.FINAL_polished1_m.fasta
