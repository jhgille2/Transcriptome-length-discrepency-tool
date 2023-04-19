# Transcriptome length discrepency tools
Some code to (hopefully) help to resolve an issue where sequences in a BAM/SAM header have a different length indicated than what is indicated in both a gtf file and transcriptome file used in a common pipeline.

## Problem description
There seems to a problem where sequence lengths the SAM/BAM headers in the alignment files produced by the STAR aligner disagree with the lengths in annotation gtf/transcriptome files that are used for producing a index and in quantifying the alignments, respectively. This causes an error in the salmon aligner that looks like:  
`SAM file says target rna-W848_p084 has length 384, but the FASTA file contains a sequence of length [126 or 125]`  

And no quant.sf file will be produced. I have found a few [threads on github](https://github.com/COMBINE-lab/salmon/issues/785) or [biostars](https://www.biostars.org/p/486346/) from users who have similar issues, but as far as I can tell, a solution to the problem has not been implemented in the STAR or salmon software as of the the time of writing. The user who had the issue on biostar mentioned that they resolved their issue by comparing transcript sequence lengths in their transcriptome and BAM files and removing the transcripts that had different lengths between the two. I'll use their approach here as it seemed to resolve the issue while only removing a couple transcripts (in the genome files I was using at least)

## Workflow
## Required software
The software I used for this is listed in the environment.yml file in this repository and can be installed with `conda install -f environment.yml`.  

### Input files
To start, I need to already have a genome.fa, annotations.gtf, and transcripts.fa file, where the transcripts.fa file was generated using the genome.fa and annotations.gtf file with a tool like [gffread](http://ccb.jhu.edu/software/stringtie/gff.shtml). I also need to have already indexed my genome (I used STAR), and aligned my transcripts to the genome (I used STAR here again) for at least one sample so that I have an output Aligned.toTranscriptome.out.bam file for at least one sample.

### Get transcriptome lengths from transcriptome.fa and bam header
Next, I'll need to get the transcript lengths for both the transcriptome.fa files and bam headers. Here's how I would do that for the transcriptome file:  
`bioawk -c fastx '{ print $name, length($seq) }' < transcriptome.fa > transcriptome_lengths.txt`  
And for the bam file:  
`samtools view -H sample_Aligned.toTranscriptome.out.bam > bam_lengths.txt`

### Compare transcriptome lengths from the two sources.  
**I'm still working on automating this step** but the gist is I want to match the sequench names between both files and find the transcripts that have different lengths in the two files and then export these "problem transcripts" to a file that can be used in the next step.

### Subset the gtf file to exclude the transcripts with different lengths
Next, I want to remove those problem transcripts from my annotations.gtf file. I can do that with a command like this:
`grep -v -Ff problem_transcripts.txt annotations.gtf > annotations_filtered.gtf`  
This command assumes that you have a file called `problem_transcripts.txt` that has the ids for each of the problematic transcripts found in the first step listed one per line. It will then export a gtf file without these transcripts to a new gtf file called `annotations_filtered.gtf`. 

### (Try to) remake the transcriptome.fa file from the filtered gtf file
At this point you can try to re-make the transcriptome file from the genome.fa file and the annotations_filtered.gtf file with this command:

`gffread -w transcriptome_new.fa -g genome.fa annotations_filtered.gtf`  

When I did this however, I got an error that looked like this:  

`GffObj::getSpliced() error: improper genomic coordinate 220519 on NC_022868.1 for rna-W848_p085`  

Which seemed to indicate a line of the gtf file with an impossible genomic coordinate. This is an error I definitely need to look more into. I have a bad feeling it may be due to a mismatch between the names for the chromosomes for the annotations and the genome file but I'm going to have to circle back to this. Basically just writing this here for future me. At any rate, my quick and dirty solution was to remove this transcript as well. I did this with:  

`cat annotations_filtered.gtf | awk '{if ($1 != "NC_022868.1" && $5 != "220519") print $0;}' > annotations_filtered_2.gtf`

And then re-made the transcriptome again with: 

`gffread -w transcriptome_new.fa -g genome.fa annotations_filtered_2.gtf`  

This time the transcriptome.fa file was made without errors and salmon was also able to run without errors after re-indexing the genome with the new gtf files and aligning to the new transcriptome file. 

## Thoughts and future work (More writing stuff so I don;t forget later)
I should be able to automate the steps up to filtering the annotations file to remove the transcripts that have different lengths in the initial transcriptome.fa and annotations.gtf files. After that though, I think it would be better to remove problem sequences manually/I'm not sure how I'd go about automating it yet. I'd like to have a clearer idea about what that error is when I try to make the first new transcriptome.fa file after filtering out the transcripts with the mismatched lengths to be sure there isn;t a more serious underlying issue there. Overall, this process did not remove many transcripts though. I only had one transcript that differend in length in my alignment and transcriptome files and it was just that one entry with the improper genomic coordinate that I had to remove for [my current data](https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_004193775.1/) so I didn't have to sacrifice much data with this filtering methos, I just still need to souble check that it's not horribly altering anything. 
