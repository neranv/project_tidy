## Introduction
This project is created as a part of Coursera course 'Getting and Cleaning Data'. Goal of this project is to combine train and test data, extract measurements of mean and standard deviation, and label with descriptive names. Data can be found at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

##R Script
Script 'run_analysis.R' helps in processing the data. It consists function called process_xy() which takes in x data, y data, subject data, feature names and activity data, and output is tidy data. Function signature is as follows:

```R
process_xy <- function(xdata, ydata, subject_data, feature_names, activities) { ... } 
```
where xdata is a data frame which contain different measurements (e.g. tBodyAcc, tBodyGyro etc), 
      ydata is an array of activity ids 
      subject_data is an array of subject ids
      feature_name is a character array which corresponds to measurements in xdata
      activities is a charactery of activity names

### Reading test and train data
x_test, y_test and subject_test are read using read.table() from x_test.txt, y_test.txt and subject_test.txt respectively. Similary x_train, y_train and subject_train. 

###Reading feature names 
features names are read from features.txt using read.table()

###Reading activity names
Activity names are read from activity_labels.txt using read.table()

#### Process read data using process_xy() function
The test and train data are fed to process_xy. Output of process_xy is a data frame which combines all these data. Let us see the steps carried out in process_xy

- Clean up the variable names. Remove '(', ')' and replace '-' with a '.'. This makes the variable name more readable and intuitive.
```R
feature_names <- gsub('\\(','',feature_names)
feature_names <- gsub('\\)','',feature_names)
feature_names <- gsub('-','.',feature_names)
names(xdata) <- feature_names
```
- Unfortunately xdata has duplicate col names which has to be weeded out
```R
xdata  <- xdata[,!duplicated(names(xdata))]
```
- Then mean and std is selected from xdata
```R
xdata1 <- dplyr::select(xdata, contains('mean'))
xdata2 <- dplyr::select(xdata, contains('std'))
#COBINE THESE TWO
xdata <- cbind(xdata1,xdata2)
```
- ydata col name is renamed to activity
```R
ydata <- dplyr::rename(ydata,
                           activity=V1)
```
- Change activity ids to activity names and coerce it to factors
```R
for(i in 1:length(activity_names) ){
      ydata[ydata$activity==i,] <- activities[i]
}
#make activity as factors
ydata$activity <- as.factor(ydata$activity)
```
- Rename subject_data col name to subjectID
```R
#RENAME COL NAME to  subjectID 
subject_data <- dplyr::rename(subject_data,
                                  subjectID=V1)
```
- combine xdata,ydata and subject data, and return
```R
    cbind(xdata,ydata,subject_data)
```
###Combine the processed data
The processed test and train data are combined.
```R
xy_combined <- rbind(xy_train, xy_test)
```
where xy_train and xy_test are the processed data

###Group,summarize and melt
Use chaining the combined is first grouped (by subjectID, activities) and mean for each variable is computed. Finally the output is written to a file using write.table
```R
xy_combined %>%
    dplyr::group_by(subjectID, activity) %>%
    dplyr::summarize_each(funs(mean)) %>% 
    melt(id.vars = c('subjectID','activity')) %>%
    write.table(file='tidy.txt',row.name=FALSE)
```




