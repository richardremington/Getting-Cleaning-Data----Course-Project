# Codebook for “tidy_data_(from_Step_5).txt”

The project data are passed to, processed, and output from R language script run_analysis.R. This script writes to a text file reporting means for 66 variables by combination of physical activity (n=6) and study participant (n=30) with 

write.table( out, 
             file="tidy_data_(from_Step_5).txt",    
             row.name=FALSE)

This table can be read into R with:

read.table( "tidy_data_(from_Step_5).txt", 
            header=TRUE)

A full description of the raw data is available here:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
The script run_analysis.R is extensively commented and, for conciseness, provides an “in place” guide to the code.
