

#Mapping of RNAseq reads to the final genome assembly
hisat2-build -p 80 Cm-478-11_final_PacBio_genome.m.fasta Cm-478-11_hisat2-index
hisat2 --sensitive --summary-file ./ -p 80 -x Cm-478-11_21_hisat2-index -1 /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/RNAseq/DE51NGSUKBR128750_Cm_S2_R1_001.fastq.gz -2 /DATA_RAID2/akraege/Hanna_Genome_Assembly/Cm-478-11/RNAseq/DE51NGSUKBR128750_Cm_S2_R2_001.fastq.gz -S RNAseq_to_Cm-478-11_21.sam
