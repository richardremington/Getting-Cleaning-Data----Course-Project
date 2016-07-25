
# INSTRUCTIONS
#
# You should create one R script called run_analysis.R that does the following.
# 
# 1.  Merges the training and the test sets to create one data set.
# 
# 2.  Extracts only the measurements on the mean and standard deviation for each 
#     measurement.
# 
# 3.  Uses descriptive activity names to name the activities in the data set
# 
# 4.  Appropriately labels the data set with descriptive variable names.
# 
# 5.  From the data set in step 4, creates a second, independent tidy data set 
#     with the average of each variable for each activity and each subject.


# The following code was developed on a Windows 7 Pro 64-bit machine running 
# R version 3.3.1 (2016-06-21) [Platform: x86_64-w64-mingw32/x64 (64-bit)].



#------------------------------------------------------------------------------
#--------------- 0. Prelimininaries -------------------------------------------
#------------------------------------------------------------------------------


#----- load required packages 

if(!require(dplyr))
  install.packages( "dplyr",
                    repos = "http://cran.r-project.org",
                    dependencies = TRUE)
require(dplyr)

if(!require(tidyr))
  install.packages( "tidyr",
                    repos = "http://cran.r-project.org",
                    dependencies = TRUE)
require(tidyr)


#------------------------------------------------------------------------------
#--------------- 1. Merge training & test data sets ---------------------------
#------------------------------------------------------------------------------


#----- download the assignment data ("UCI HAR data)0 zip file 

# location of data
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# if the subdirectory "/data" does not exist, create it
if (!file.exists("data")) dir.create("data")

# download data
download.file(URL, 
              destfile="data/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")

# If it hangs, may need to enter ESC on some Windows machines!!!

# extract the zipped files to subdirectory "/data/UCI HAR Dataset"
unzip (".data/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", exdir = "data")


#-- read training data

# measurement data
train <- read.table( file = "./data/UCI HAR Dataset/train/X_train.txt")
dim(train)
# [1]  7352  561

# subject ID
train.subject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
dim(train.subject)
# 7352    1

# activity ID
train.labels <- read.delim( file = "./data/UCI HAR Dataset/train/y_train.txt",
                            sep = "", 
                            header = FALSE)
dim(train.labels)
#  7352    1

# 6 activities (measurement counts by activity)
table(train.labels)
#    1    2    3    4    5    6 
# 1226 1073  986 1286 1374 1407

# read the test data
test <- read.delim( file = "./data/UCI HAR Dataset/test/X_test.txt",
                    sep = " ", 
                    header = FALSE)
dim(test)
# [1] 4312  667

# check how many of the train variable names are in the test data
sum( names(train) %in% names(test))
# 561

# note there are 561 variables (columns) in the training data set & 667 
# variables in the test data set

# train & test have the same row names for the 1st 561 columns (extent of train)
sum(names(train) == names(test)[1:ncol(train)])
# 561

# From the README.txt file that comes with the data dowload:
#   "For each record it is provided: A 561-feature vector with time and 
#   frequency domain variables." 

# The additional columns in the test data are not described and can not be 
# merged with the training data.

# subject ID
test.subject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
dim(test.subject)
# 2947    1

# activity ID
test.labels <- read.delim( file = "./data/UCI HAR Dataset/test/y_test.txt",
                           sep = "", 
                           header = FALSE)
dim(test.labels)
# [1] 2947    1

# Note: "test" has more rows than test.sujbjects and test.labels.  Only the 
# first 2947 rows of data will be used.

# subset to rows of test data with test.labels
test <- test[ 1:nrow(test.labels), ]
nrow(test)
# 2947

# 6 activities (measurement counts by activity)
table(test.labels)
#   1   2   3   4   5   6 
# 496 471 420 491 532 537 

# append rows of training & test data sets for columns with matching names
d <- rbind(train, test[, 1:ncol(train)])
dim(d)
# 10299   561

# get the column names of variables
ColumnNames  <- read.table("./data/UCI HAR Dataset/features.txt", header=FALSE)
dim(ColumnNames)
# 561 2

head(ColumnNames)
#   V1                V2
# 1  1 tBodyAcc-mean()-X
# 2  2 tBodyAcc-mean()-Y
# 3  3 tBodyAcc-mean()-Z
# 4  4  tBodyAcc-std()-X
# 5  5  tBodyAcc-std()-Y
# 6  6  tBodyAcc-std()-Z

# assign column names to the combined training & test data
colnames(d)  <- ColumnNames$V2

# add a column for "subject" 
d$subject <- c( unlist(train.subject), unlist(test.subject))

# add a column for "activity" 
d$activity.number <- c( unlist(train.labels), unlist(test.labels))

dim(d)
# 10299   563


#------------------------------------------------------------------------------
#--------------- 2. Extract columns that are mean() or std() measurements -----
#------------------------------------------------------------------------------

# identify the index of column names that include "mean()" or "std()"
i <- grep(".*mean\\(\\)|.*std\\(\\)", colnames(d), ignore.case=TRUE)
i
#  [1]   1   2   3   4   5   6  41  42  43  44  45  46  81  82  83  84  85  86 121 122 123 124 125
# [24] 126 161 162 163 164 165 166 201 202 214 215 227 228 240 241 253 254 266 267 268 269 270 271
# [47] 345 346 347 348 349 350 424 425 426 427 428 429 503 504 516 517 529 530 542 543

# number of variables that measure mean or std
length(i)
# 66

# subset to these columns with the activity variable as the first column
d <- data.frame( subject = d$subject, activity.number = d$activity.number, d[ , i])
ncol(d)
# 68

# keep a copy of the original 66 variables with mean & std measures
measurement.names <- ColumnNames$V2[i]


#------------------------------------------------------------------------------
#--------------- 3. Replace activities "1" - "6" with descriptive names -------
#------------------------------------------------------------------------------

# get descriptive activity names
activity.labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt", 
                              header=FALSE)
activity.labels
#   V1                 V2
# 1  1            WALKING
# 2  2   WALKING_UPSTAIRS
# 3  3 WALKING_DOWNSTAIRS
# 4  4            SITTING
# 5  5           STANDING
# 6  6             LAYING

unique.activities <- as.character(activity.labels$V2)
unique.activities

# add variable to describe activity to combined train and test data
d$activity <- NA

# give activities descriptive names
for( i in 1:length(unique.activities))
{
  j <- d$activity.number == i 
  d$activity[j] <- unique.activities[i]  
}
d$activity  

# make factor (honoring numeric scheme)
d$activity <- factor(d$activity, levels = unique.activities)
        
names(d)
#  [1] "subject"                     "activity.number"             "tBodyAcc.mean...X"          
#  [4] "tBodyAcc.mean...Y"           "tBodyAcc.mean...Z"           "tBodyAcc.std...X"           
#  [7] "tBodyAcc.std...Y"            "tBodyAcc.std...Z"            "tGravityAcc.mean...X"       
# [10] "tGravityAcc.mean...Y"        "tGravityAcc.mean...Z"        "tGravityAcc.std...X"        
# [13] "tGravityAcc.std...Y"         "tGravityAcc.std...Z"         "tBodyAccJerk.mean...X"      
# [16] "tBodyAccJerk.mean...Y"       "tBodyAccJerk.mean...Z"       "tBodyAccJerk.std...X"       
# [19] "tBodyAccJerk.std...Y"        "tBodyAccJerk.std...Z"        "tBodyGyro.mean...X"         
# [22] "tBodyGyro.mean...Y"          "tBodyGyro.mean...Z"          "tBodyGyro.std...X"          
# [25] "tBodyGyro.std...Y"           "tBodyGyro.std...Z"           "tBodyGyroJerk.mean...X"     
# [28] "tBodyGyroJerk.mean...Y"      "tBodyGyroJerk.mean...Z"      "tBodyGyroJerk.std...X"      
# [31] "tBodyGyroJerk.std...Y"       "tBodyGyroJerk.std...Z"       "tBodyAccMag.mean.."         
# [34] "tBodyAccMag.std.."           "tGravityAccMag.mean.."       "tGravityAccMag.std.."       
# [37] "tBodyAccJerkMag.mean.."      "tBodyAccJerkMag.std.."       "tBodyGyroMag.mean.."        
# [40] "tBodyGyroMag.std.."          "tBodyGyroJerkMag.mean.."     "tBodyGyroJerkMag.std.."     
# [43] "fBodyAcc.mean...X"           "fBodyAcc.mean...Y"           "fBodyAcc.mean...Z"          
# [46] "fBodyAcc.std...X"            "fBodyAcc.std...Y"            "fBodyAcc.std...Z"           
# [49] "fBodyAccJerk.mean...X"       "fBodyAccJerk.mean...Y"       "fBodyAccJerk.mean...Z"      
# [52] "fBodyAccJerk.std...X"        "fBodyAccJerk.std...Y"        "fBodyAccJerk.std...Z"       
# [55] "fBodyGyro.mean...X"          "fBodyGyro.mean...Y"          "fBodyGyro.mean...Z"         
# [58] "fBodyGyro.std...X"           "fBodyGyro.std...Y"           "fBodyGyro.std...Z"          
# [61] "fBodyAccMag.mean.."          "fBodyAccMag.std.."           "fBodyBodyAccJerkMag.mean.." 
# [64] "fBodyBodyAccJerkMag.std.."   "fBodyBodyGyroMag.mean.."     "fBodyBodyGyroMag.std.."     
# [67] "fBodyBodyGyroJerkMag.mean.." "fBodyBodyGyroJerkMag.std.."  "activity"         

# select and re-order columns (omit "activity.number")
d <- select( d, subject, activity, tBodyAcc.mean...X : fBodyBodyGyroJerkMag.std..)                    
ncol(d)
# 68


#------------------------------------------------------------------------------
#--------------- 4. Replace variable names with descriptive names -------------
#------------------------------------------------------------------------------

# x = working copy of 66 measurement variable names (in order as they appear in "d")
x <- measurement.names

# starts with "t", now ends with "time"
x <- gsub("^t(.*)$", "\\1_time", x)

# starts with "f", now ends with "frequency"
x <- gsub("^f(.*)$", "\\1_frequency", x)

# replace "BodyBody" with "Body"
x <- gsub("BodyBody", "Body", x)

# replace "Acc" with "-acceleration"
x <- gsub("Acc", "_acceleration", x)

# place hyphen to before "Gyro" or "Jerk"
x <- gsub("(Jerk|Gyro)", "_\\1", x)

# replace "Mag" with "-magnitude" 
x <- gsub("Mag", "_magnitude", x)

# drop occurrences of "()"
x <- gsub("\\(\\)", "", x)

# replace "-" with "_" 
x <- gsub("-", "_", x)

# all to lower case
x <- tolower(x)
x
#  [1] "body_acceleration_mean_x_time"                   "body_acceleration_mean_y_time"                  
#  [3] "body_acceleration_mean_z_time"                   "body_acceleration_std_x_time"                   
#  [5] "body_acceleration_std_y_time"                    "body_acceleration_std_z_time"                   
#  [7] "gravity_acceleration_mean_x_time"                "gravity_acceleration_mean_y_time"               
#  [9] "gravity_acceleration_mean_z_time"                "gravity_acceleration_std_x_time"                
# [11] "gravity_acceleration_std_y_time"                 "gravity_acceleration_std_z_time"                
# [13] "body_acceleration_jerk_mean_x_time"              "body_acceleration_jerk_mean_y_time"             
# [15] "body_acceleration_jerk_mean_z_time"              "body_acceleration_jerk_std_x_time"              
# [17] "body_acceleration_jerk_std_y_time"               "body_acceleration_jerk_std_z_time"              
# [19] "body_gyro_mean_x_time"                           "body_gyro_mean_y_time"                          
# [21] "body_gyro_mean_z_time"                           "body_gyro_std_x_time"                           
# [23] "body_gyro_std_y_time"                            "body_gyro_std_z_time"                           
# [25] "body_gyro_jerk_mean_x_time"                      "body_gyro_jerk_mean_y_time"                     
# [27] "body_gyro_jerk_mean_z_time"                      "body_gyro_jerk_std_x_time"                      
# [29] "body_gyro_jerk_std_y_time"                       "body_gyro_jerk_std_z_time"                      
# [31] "body_acceleration_magnitude_mean_time"           "body_acceleration_magnitude_std_time"           
# [33] "gravity_acceleration_magnitude_mean_time"        "gravity_acceleration_magnitude_std_time"        
# [35] "body_acceleration_jerk_magnitude_mean_time"      "body_acceleration_jerk_magnitude_std_time"      
# [37] "body_gyro_magnitude_mean_time"                   "body_gyro_magnitude_std_time"                   
# [39] "body_gyro_jerk_magnitude_mean_time"              "body_gyro_jerk_magnitude_std_time"              
# [41] "body_acceleration_mean_x_frequency"              "body_acceleration_mean_y_frequency"             
# [43] "body_acceleration_mean_z_frequency"              "body_acceleration_std_x_frequency"              
# [45] "body_acceleration_std_y_frequency"               "body_acceleration_std_z_frequency"              
# [47] "body_acceleration_jerk_mean_x_frequency"         "body_acceleration_jerk_mean_y_frequency"        
# [49] "body_acceleration_jerk_mean_z_frequency"         "body_acceleration_jerk_std_x_frequency"         
# [51] "body_acceleration_jerk_std_y_frequency"          "body_acceleration_jerk_std_z_frequency"         
# [53] "body_gyro_mean_x_frequency"                      "body_gyro_mean_y_frequency"                     
# [55] "body_gyro_mean_z_frequency"                      "body_gyro_std_x_frequency"                      
# [57] "body_gyro_std_y_frequency"                       "body_gyro_std_z_frequency"                      
# [59] "body_acceleration_magnitude_mean_frequency"      "body_acceleration_magnitude_std_frequency"      
# [61] "body_acceleration_jerk_magnitude_mean_frequency" "body_acceleration_jerk_magnitude_std_frequency" 
# [63] "body_gyro_magnitude_mean_frequency"              "body_gyro_magnitude_std_frequency"              
# [65] "body_gyro_jerk_magnitude_mean_frequency"         "body_gyro_jerk_magnitude_std_frequency"   


#-- relabel measurement variable with more descriptive names

names(d)[1:3]
#  "subject"           "activity.number"   "tBodyAcc.mean...X"

which.cols <- 3:ncol(d)

names(d)[which.cols] <- x
names(d)


#------------------------------------------------------------------------------
#--------------- 5. create a tidy data set of means by activity & subject -----
#------------------------------------------------------------------------------

out <- tbl_df(d) %>% 
  group_by(activity, subject) %>%
  summarise_each(funs(mean)) %>%
  gather( variable, mean, -activity, -subject)
# view all in separate window
View(out)
# condensed view to console
out
# Source: local data frame [11,880 x 4]
# Groups: activity [6]
# 
#    activity subject                      variable      mean
#      (fctr)   (int)                         (chr)     (dbl)
# 1   WALKING       1 body_acceleration_mean_x_time 0.2773308
# 2   WALKING       2 body_acceleration_mean_x_time        NA
# 3   WALKING       3 body_acceleration_mean_x_time 0.2755675
# 4   WALKING       4 body_acceleration_mean_x_time        NA
# 5   WALKING       5 body_acceleration_mean_x_time 0.2778423
# 6   WALKING       6 body_acceleration_mean_x_time 0.2836589
# 7   WALKING       7 body_acceleration_mean_x_time 0.2755930
# 8   WALKING       8 body_acceleration_mean_x_time 0.2746863
# 9   WALKING       9 body_acceleration_mean_x_time        NA
# 10  WALKING      10 body_acceleration_mean_x_time        NA
# ..      ...     ...                           ...       ...

# checksum
dim(out)
# 11880     4

# number of means (i.e., rows) = n variables * n activities * n participants
66*6*30
# 11880

# Save the data into the tidy data file
write.table( out, file="tidy_data_(from_Step_5).txt", row.name=FALSE)

# check output file
dim(read.table("tidy_data_(from_Step_5).txt", header=TRUE))
# 11880     4
