# Chromosome length info
lengths <- read_tsv("data/ragtag/ragtag.scaffold_lengths.txt", col_names = c("chr","length"),show_col_types = FALSE)

offsets <- lengths %>% arrange(desc(length)) %>% 
  dplyr::mutate(offset=cumsum(length)-length) %>% 
  dplyr::mutate(scaffold_num = row_number())

axis_chr<- offsets %>% 
  mutate(centre=offset+length/2) %>% 
  mutate(chr_id=ifelse(grepl(chr,pattern="chr"),chr,"Unplaced")) %>% 
  mutate(chr_id=str_remove(chr_id,"_RagTag"),chr_id=str_remove(chr_id,"chr")) %>% 
  group_by(chr_id) %>% 
  summarise(centre = mean(centre))


main_text=10