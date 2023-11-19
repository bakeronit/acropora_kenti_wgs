sample2reef <- function(data){
  data %>% 
    mutate(reef = case_when(
      grepl("DI",sample)~ "DI",
      grepl("PI",sample)~ "PI",
      grepl("FI",sample)~ "FI",
      grepl("PR",sample)~ "PR",
      grepl("MI",sample)~ "MI",    
      grepl("TAY",sample)~ "TAY",
      grepl("ARL",sample)~ "ARL",
      grepl("JB",sample)~ "JB",  
      grepl("RIB",sample)~ "RIB",    
    ))
}

reef2pop <- function(data){
  data %>% 
  mutate(pop = case_when(
    reef %in% c("DI","PI","FI","PR") ~ "north_inshore",
    reef %in% c("RIB","ARL","TAY","JB") ~ "offshore",
    reef == "MI" ~ "magnetic_island"
  ))
}

add_reef_order <- function(data){
  reef_order <- 1:9
  names(reef_order) <- c("MI","PR","PI","DI","FI","JB","TAY","RIB","ARL")
  
  ns_order <- 1:9
  names(ns_order) <-  c("MI","PR","JB","PI","RIB","DI","TAY","FI","ARL")
  
  data %>% 
    mutate(reef_order = reef_order[reef]) %>% 
    mutate(ns_order = ns_order[reef])
}


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

add_reef_colors <- function(data){
  clrs <- c("#B15928","#FB9A99","#FDBF6F","#A6CEE3","#B2DF8A","#E31A1C","#FF7F00","#1F78B4","#33A02C")
  names(clrs) <- c("MI","FI","PI","DI","PR","ARL","RIB","TAY","JB") 
  data %>% 
    mutate(reef_clr = clrs[reef]) 
}

add_symbionts <- function(data){
  sm <- read_tsv("data/symbiomito/haplogroups.tsv",show_col_types = FALSE)
  data %>% dplyr::left_join(sm) 
}

add_inversion_genotypes <- function(data){
  gd <- read_tsv("data/genotype_data.tsv",show_col_types = FALSE) %>% 
    dplyr::select(sample_id,starts_with("L"))
  data %>% left_join(gd)
}

read_sample_table <- function(){
  
  read_csv("data/summary_data.csv",show_col_types = FALSE) %>% 
    dplyr::select(sample_id,reef=pop,location,pop=reef) %>% 
    dplyr::mutate(pop=ifelse(pop=="Outer","Offshore","Inshore")) %>% 
    add_reef_order() %>% 
    add_reef_colors()
  
}
