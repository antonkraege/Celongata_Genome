#!/bin/bash

#Mapping of RNAseq reads to the final genome assembly
hisat2-build -p 80 Cm-478-11_final_PacBio_genome.m.fasta Cm-478-11_hisat2-index
hisat2 --sensitive --summary-file ./ -p 80 -x Cm-478-11_21_hisat2-index -1 /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/RNAseq/DE51NGSUKBR128750_Cm_S2_R1_001.fastq.gz -2 /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/RNAseq/DE51NGSUKBR128750_Cm_S2_R2_001.fastq.gz -S RNAseq_to_Cm-478-11_21.sam

#annotation of genome with braker
braker.pl --species=Cm-478-11 --cores=80 --GENEMARK_PATH=/home/akraege/gmes_linux_64_4/ --genome=/DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/genome-manual2/Cm_478-11_final_genome_m_21.fasta --bam ./mapped_reads/RNAseq_to_Cm-478-11_21.bam

#quality control of braker annotation with BUSCO
busco -i ../Braker2/braker/braker_aa.fasta -o Cm-478-11_final_Pacbio-m -l chlorophyta -c 40 -m prot

#annotation of secreated proteins with signalp6
signalp6 --mode slow-sequential --output_dir Signalp6/ --fastafile RNAseq/braker/Celongata/braker.aa

#Annotation of repeats with repeat
BuildDatabase -name Cm-genome-final /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/genome-manual2/Cm_478-11_final_PacBio_genome_m.fasta
RepeatModeler -database /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/Reapeatmodeler/database/Cm-genome-final -pa 20
reasonaTE -mode annotate -projectFolder workspace -projectName testProject -tool all
TEclassTest.pl -o /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/Reapeatmodeler/ Cm_478-11_final_PacBio_genome_m.fasta
RepeatMasker -pa 20 -dir . -xsmall -gff -excln -lib /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/Reapeatmodeler/database/Cm-genome-final-families.fa /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/genome-manual2/Cm_478-11_final_PacBio_genome_m.fasta
