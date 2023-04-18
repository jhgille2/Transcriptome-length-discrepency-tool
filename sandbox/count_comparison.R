

bam_lens <- read_delim(here::here("data", "bam_lengths.txt"), col_names = FALSE) %>% 
  set_names(c("sq", "seq", "bam_len")) %>% 
  select(-sq) %>% 
  mutate(seq = str_remove(seq, "SN:"),
         bam_len = as.numeric(str_remove(bam_len, "LN:")))

transcript_lens <- read_delim(here::here("data", "transcript_lengths.txt"), col_names = FALSE) %>% 
  set_names(c("seq", "transcript_len"))

transcript_lens_filtered <- read_delim(here::here("data", "transcript_lengths_filtered.txt"), col_names = FALSE) %>% 
  set_names(c("seq", "transcript_len_filtered"))


gtf_file <- read_delim(here::here("data", "genomic.AGAT.gtf"), skip = 8, col_names = FALSE)


gtf_filtered <- gtf_file %>% 
  dplyr::filter(!grepl("rna-W848_p084", X9))

write.table(gtf_filtered, file = here::here("data", "gtf_filtered.gtf"))
