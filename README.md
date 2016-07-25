# Getting-Cleaning-Data----Course-Project

Coursera from Johns Hopkins University
“Getting and Cleaning Data”
Peer Graded Assignment / Course Project

Introduction

This repository contains information that demonstrates how to collect, work with, and clean the data sets provided for this assignment according to instructions.  

Instructions:

You should create one R script called run_analysis.R that does the following.
1.	Merges the training and the test sets to create one data set.
2.	Extracts only the measurements on the mean and standard deviation for each measurement.
3.	Uses descriptive activity names to name the activities in the data set
4.	Appropriately labels the data set with descriptive variable names.
5.	From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Short summary of assignment:  data from a smartphone accelerometer study (30 participants, 6 activities, many variables measured) is downloaded, read into R, and formatted to be a tidy data set per the instructions above.

Summary

The work is done by run_analysis.R  which downloads the zipped raw data to subdirectory “data” (note: if the directory does not exist, it will be created).  To use this script, place the script in your current working directory [see getwd() and setwd()], and, from the R command line (i.e., in R Console) enter: 

source(“run_analysis.R”)


The results will be written to "tidy_data_(from_Step_5).txt" in the current working directory. See CodeBook.md in this repository for details about the data set.
Work Details
The data come from a study of a Samsung brand smartphone accelerometer in which 30 participants performed 6 activities and many performance measurements were recorded.  The raw data was split into “training” and “test” data sets.  For each, there were separate files for activity labels (“walking”, “sitting”, “standing”, etc.) and participant (“subject”) identification for rows of raw data.  Likewise, there are separate files for variable names (for each of the performance measures).  For each subject and activity, a time series of measurements was included in the data.  Following the assignment instructions, the training and test data sets were merged, descriptively labeled, and variables representing measurement means and standard deviations were extracted. The submitted final data set is simply the mean of these variables by combination of activity and subject (66 variables * 6 activities * 30 participants = 11,880 means).  
Additional details of the work are provided with extensive comments in the R script run_analysis.R.
