get_transcript_lengths <- function(transcriptome_file){

    transcript_lens <- read_delim(transcriptome_file, col_names = FALSE) %>% 
                        set_names(c("seq", "transcript_len"))

    return(transcript_lens)
}