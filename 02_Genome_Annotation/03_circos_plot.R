getwd()
setwd("D:/Genome_Assembly_Hanna_Cm/Celongata/HiC-2")
library(circlize)
library(dplyr)
library(tidyr)
circos.clear()
#Create the sectors of the plot

chromosomes <- data.frame('chr'=c('HiC_scaffold_1', 'HiC_scaffold_2', 'HiC_scaffold_3', 
                                  'HiC_scaffold_4', 'HiC_scaffold_5', 'HiC_scaffold_6', 'HiC_scaffold_7',
                                  'HiC_scaffold_8', 'HiC_scaffold_9', 'HiC_scaffold_10', 'HiC_scaffold_11', 'HiC_scaffold_12',
                                  'HiC_scaffold_13', 'HiC_scaffold_14', 'HiC_scaffold_15', 'HiC_scaffold_16', 'HiC_scaffold_17',
                                  'HiC_scaffold_18', 'HiC_scaffold_19', 'HiC_scaffold_20','HiC_scaffold_21'),
                          'start'=c(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
                          'end'=c(4899248,3806983,3450627,3417207,3302711,3061597,2861090,2745756,2676475,
                                  2622059,2614173,2460451,2305702,2165543,2123315,1961593,1651278,1579665,1432053,183418,69946),
                          'type'=c('chr','chr','chr','chr','chr','chr','chr','chr',
                                   'chr','chr','chr','chr','chr','chr','chr','chr','chr','chr','chr','chr','chr'))

circos.par(start.degree = 82)#,cell.padding = c(0.5, 0, 0.5, 0))
circos.par("gap.degree" = 2,cell.padding = c(0, 0, 0, 0))
circos.initialize(chromosomes$chr, xlim = cbind(rep(0, 20), chromosomes$end))
circos.genomicInitialize(chromosomes)

gc <- read.csv('gc_sliding_window.gff', sep = '\t', header = TRUE, colClasses = c(NA,numeric(),numeric(),NA))
#column names
colnames(gc) = c("chr","start","stop","cov")
gc$cov=gc$cov*100

#Plot
circos.track(factors=gc$chr, x=gc$start, y=gc$cov, panel.fun=function(x, y) {
  circos.lines(x, y, col="grey50", lwd=0.6)
  circos.segments(x0=1, x1=chromosomes[chromosomes$chr == get.current.sector.index(),]$end, y0=30, y1=30, lwd=0.6, lty="11", col="grey90")
  circos.segments(x0=1, x1=chromosomes[chromosomes$chr==get.current.sector.index(),]$end, y0=50, y1=50, lwd=0.6, lty="11", col="grey90")
  circos.segments(x0=1, x1=chromosomes[chromosomes$chr==get.current.sector.index(),]$end, y0=70, y1=70, lwd=0.6, lty="11", col="grey90")
}, ylim=range(gc$cov), track.height=0.15, bg.border=F)
# gc y axis
get.current.sector.index()
circos.yaxis(sector.index = "HiC_scaffold_1", at=c(30, 50, 70), labels.cex=0.5, lwd=0, tick.length=0, labels.col="grey40", col="#FFFFFF",  side = "left")
circos.par
range(gc$cov)
genes <- read.csv('genedensity2.csv',sep =';',header=FALSE, colClasses = c(NA,NA,NA))
#Give column names that match what type of data it is
colnames(genes) = c("chr","start","stop")
#Plot the data on the track, giving a colour and a height
circos.genomicDensity(genes, col = c("#23395d"), track.height = 0.15, bg.border=F)
# #Visualizing genome coverage to determine centromere positions
repeats <- read.csv('Repeatdensity.csv',sep =';',header=FALSE, colClasses = c(NA,NA,NA))
#Give column names that match what type of data it is
colnames(repeats) = c("chr","start","stop")
#Plot the data on the track, giving a colour and a height
circos.genomicDensity(repeats, col = c("#7d0000"), track.height = 0.1, window.size =20000, bg.border=F)
