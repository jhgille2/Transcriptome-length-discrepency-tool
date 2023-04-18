# Transcriptome length discrepency tool
Some code to (hopefully) help to resolve an issue where sequences in a BAM/SAM header have a different length indicated than what is indicated in both a gtf file and transcriptome file used in a common pipeline.

## Problem description
There seems to a problem where sequence lengths the SAM/BAM headers in the alignment files produced by the STAR aligner disagree with the lengths in annotation gtf/transcriptome files that are used for producing a index and in quantifying the alignments, respectively. This causes an error in the salmon aligner that looks like:  
`SAM file says target rna-W848_p084 has length 384, but the FASTA file contains a sequence of length [126 or 125]`  

And no quant.sf file will be produced. I have found a few [threads on github](https://github.com/COMBINE-lab/salmon/issues/785) or [biostars](https://www.biostars.org/p/486346/) from users who have similar issues, but as far as I can tell, a solution to the problem has not been implemented in the STAR or salmon software as of the the time of writing. The user who had the issue on biostar mentioned that they resolved their issue by comparing transcript sequence lengths in their transcriptome and BAM files and removing the transcripts that had different lengths between the two.
