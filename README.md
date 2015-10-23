### I. Introduction
This project is created as a part of Coursera course 'Getting and Cleaning Data'. Goal of this project is to combine train and test data and other related data then extract mean and standard deviation measurements and label them with descriptive names. 
Finally group them by subject, activity and get a summary of mean for each of the variables.

Data that was used can be found at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip [1]

### II. R Script - run_analysis.R
The script 'run_analysis.R' helps in processing the data. It consists of a function called process_xy() which takes in x data, y data, subject data, feature names and activity lables, and outputs an tidy data set.

Function signature is as follows:

```R
process_xy <- function(xdata, ydata, subject_data, feature_names, activities) { ... } 
```
<p>
where xdata is a data frame which contains different measurements (e.g. tBodyAcc, tBodyGyro etc), 
      ydata is an array of activity ids 1-6,
      subject_data is an array of subject ids,
      feature_name is a character array which corresponds to measurements in xdata,
      and activities is a character array of activity names or labels (factors).
</p>
### III. Getting from Dirty to Tidy Data
This section explains how data in 'UCI HAR Dataset' is transformed in to a tidy data set. 

#### a. Read test and train data
x_test, y_test and subject_test data frames are read using read.table() from x_test.txt, y_test.txt and subject_test.txt respectively. Similary x_train, y_train and subject_train data frames are read from x_tain.txt, y_train, z_train. 

#### b. Read feature names 
Features names are read from features.txt using read.table()

#### c. Read activity names
Activity names are read from activity_labels.txt using read.table()

#### d. Process the read data using process_xy() function
The test and train data are fed to process_xy separately to get a tidy data set. In the next step the tidy data set xy_train, xy_test are combined.

```R

xy_train <- process_xy(x_train,y_train, subject_train, feature_names, activity_names)

xy_test <- process_xy(x_test, y_test, subject_test, feature_names, activity_names)
```

Let us see the steps that are carried out in the function process_xy. They are as follows:

- Variable names are cleaned up.  '(', ')' are removed and '-' is replaced with '.'. This makes the variable name more readable and intuitive.
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
- mean and std is then selected from xdata
```R
xdata1 <- dplyr::select(xdata, contains('mean'))
xdata2 <- dplyr::select(xdata, contains('std'))
#COBINE THESE TWO
xdata <- cbind(xdata1,xdata2)
```
- ydata col name is renamed to activity to make it more descriptive
```R
ydata <- dplyr::rename(ydata,
                           activity=V1)
```
- activity ids ie number 1-6 are properly labelled to make it more readable
```R
for(i in 1:length(activity_names) ){
      ydata[ydata$activity==i,] <- activities[i]
}
#make activity as factors
ydata$activity <- as.factor(ydata$activity)
```
-  subject_data col name is renamed to subjectID
```R
#RENAME COL NAME to  subjectID 
subject_data <- dplyr::rename(subject_data,
                                  subjectID=V1)
```
-  xdata,ydata and subject data are combined and returned 
```R
    cbind(xdata,ydata,subject_data)
```
#### e. Combine the tidy data sets
The tidied test and train data sets are combined.
```R
xy_combined <- rbind(xy_train, xy_test)
```
where xy_train and xy_test are the tidy data sets

#### f. Group, summarize and melt
Use chaining the combined data is first grouped (by subjectID, activities) and then mean for each variable is computed. Finally the melted output is written to a file using write.table
```R
xy_combined %>%
    dplyr::group_by(subjectID, activity) %>%
    dplyr::summarize_each(funs(mean)) %>% 
    melt(id.vars = c('subjectID','activity')) %>%
    write.table(file='tidy.txt',row.name=FALSE)
```

### Reference
[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
