## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
lapply(list.files("./R", full.names = TRUE), source)

## tar_plan supports drake-style targets and also tar_target()
tar_plan(

# INPUT FILES
###################################################

# The path to the gtf file
tar_file(gtf_file,
here::here("data", "genomic.gtf")),

# The path to the transcriptome file
tar_file(transcriptome_file,
here::here("data", "transcriptome.fa")),

tar_file(bam_file,
here::here("data", "alignment.bam")),

# Genome file
tar_file(genome_file,
here::here("data", "genome.fna")),

# Make seq length files
tar_file(bam_length_file,
make_bam_length_file(bam_file)),

tar_file(transcriptome_length, file,
make_transcript_length_file(transcriptome_file)),

# GET seq lengths
# Get sequence lengths from the bam and transcriptome files
tar_target(bam_lengths,
get_bam_lengths(bam_length_file)),

# Transcriptome lengths
tar_target(transcriptome_lengths,
get_transcript_lengths(transcriptome_length_file)),

# Identify transcripts with different lengths
tar_file(problem_transcripts,
identify_problem_transcripts(bam_lengths, transcriptome_lengths)),

# Subset the gtf file based to remove the problem transcripts
tar_file(subset_gtf,
remove_problem_transcripts(problem_transcripts, gtf_file))

# Make a new transcriptome file using this new gtf file
tar_file(new_transcriptome,
make_new_transcriptome(subset_gtf, genome_file))

)
