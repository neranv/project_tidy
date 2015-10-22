## Introduction
This project is created as a part of Coursera course 'Getting and Cleaning Data'. Goal of this project is to combine train and test data, extract measurements of mean and standard deviation, and label with descriptive names. Data can be found at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

##R Script
Script 'run_analysis.R' helps in processing the data. It consists function called process_xy() which takes in x data, y data, subject data, feature names and activity data.

```R
process_xy <- function(xdata, ydata, subject_data, feature_names, activities) { ... } 
```
where xdata is a data frame which contain different measurements (e.g. tBodyAcc, tBodyGyro etc), 
      ydata is an array of activity ids 
      subject_data is an array of subject ids
      feature_name is a character array which corresponds to measurements in xdata
      activities is a charactery of activity names

Output of process_xy is a data frame which combines all these data. Let us see how process_xy function works

- Clean up the variable names. Remove '(', ')' and replace '-' with a '.'. This makes the variable name more readable and intuitive.
```R
feature_names <- gsub('\\(','',feature_names)
feature_names <- gsub('\\)','',feature_names)
feature_names <- gsub('-','.',feature_names)
names(xdata) <- feature_names
```
- Unfortunately names(xdata) has duplicate which has to be weeded out
```R
xdata  <- xdata[,!duplicated(names(xdata))]
```
- Then extract mean and std is selected from xdata
```R
xdata1 <- dplyr::select(xdata, contains('mean'))
xdata2 <- dplyr::select(xdata, contains('std'))
#COBINE THESE TWO
xdata <- cbind(xdata1,xdata2)
```
