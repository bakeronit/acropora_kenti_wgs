library(RColorBrewer)


site_labels <- function(){
  c("MI"="Magnetic Island","PR"="Pandora Reef","DI"="Dunk Island","PI"="Pelorus Island","FI"="Flinders Island",
    "ARL"="Arlington Reef","TAY"="Taylor Reef","RIB"="Rib Reef","JB"="John Brewer Reef")
}

site_order <- function(){
  c('MI'=0,'PI'=5,'DI'=3,'PR'=7,'FI'=1,"ARL"=2,"TAY"=4,"RIB"=6,"JB"=8)
  c('MI'=0,'PI'=3,'DI'=5,'PR'=1,'FI'=7,"ARL"=8,"TAY"=6,"RIB"=4,"JB"=2)
}

site_colors <- function(){
  clrs <- c("#B15928","#FB9A99","#FDBF6F","#A6CEE3","#B2DF8A","#E31A1C","#FF7F00","#1F78B4","#33A02C")
  clrs <- c("#B15928","#FB9A99","#FDBF6F","#A6CEE3","#B2DF8A","#E31A1C","#FF7F00","#1F78B4","#33A02C")
  names(clrs) <- c("MI","FI","PI","DI","PR","ARL","RIB","TAY","JB")
  clrs
}


