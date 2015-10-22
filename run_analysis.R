library(dplyr)
library(reshape2)

#READ IN FEATURES FILE which has the name of all the features
features <- read.table('UCI HAR Dataset/features.txt')
#get the actual feture names
feature_names <- features$V2

#READ TYPE OF ACTIVITIES
activity_lablels <- read.table('UCI HAR Dataset/activity_labels.txt', 
                               stringsAsFactors=FALSE)
#get list of activities
activity_names <- activity_lablels$V2

#Function which process and combines x,y and subject data
process_xy <- function(xdata, ydata, subject_data, feature_names, activities) {
    
    #RENAME VAR NAMES IN X data
    #make the feature names valid
    feature_names <- gsub('\\(','',feature_names)
    feature_names <- gsub('\\)','',feature_names)
    feature_names <- gsub('-','.',feature_names)
    names(xdata) <- feature_names
    #There are duplicate which needs to be removed
    xdata  <- xdata[,!duplicated(names(xdata))]
    
    #SELECT ONLY MEAN AND STD
    xdata1 <- dplyr::select(xdata, contains('mean'))
    xdata2 <- dplyr::select(xdata, contains('std'))
    
    #COBINE THESE TWO
    xdata <- cbind(xdata1,xdata2)

    #RENAME COL NAME to activity IN Y data
    ydata <- dplyr::rename(ydata,
                           activity=V1)
    
    #change activity id to activity names
    for(i in 1:length(activity_names) ){
        ydata[ydata$activity==i,] <- activities[i]
    }
    #make activity as factors
    ydata$activity <- as.factor(ydata$activity)
    
    #RENAME COL NAME to  subjectID 
    subject_data <- dplyr::rename(subject_data,
                                  subjectID=V1)
    #combine X,Y, subject data and return
    cbind(xdata,ydata,subject_data)
    
}

##READ IN TRAINING DATA

#Read X variable which has 561 feature vector
x_train <- read.table('UCI HAR Dataset/train/X_train.txt')
#READ Activity varible or output variable y
y_train <- read.table('UCI HAR Dataset/train/y_train.txt')
#subject train data
subject_train <- read.table('UCI HAR Dataset/train/subject_train.txt')

xy_train <- process_xy(x_train,y_train, subject_train, feature_names, activity_names)


##READ IN TEST DATA

#Read X varible which has the 561 feature vector
x_test <- read.table('UCI HAR Dataset/test/X_test.txt')
#activity variable or output variable y
y_test <- read.table('UCI HAR Dataset/test/y_test.txt')
#subject test data
subject_test <- read.table('UCI HAR Dataset/test/subject_test.txt')

xy_test <- process_xy(x_test, y_test, subject_test, feature_names, activity_names)

#COMBINE TEST and TRAIN DATA
xy_combined <- rbind(xy_train, xy_test)

#group_by subjectID, activity
#summarize mean of each variable
#and melt it to tall and skinny data
xy_combined %>%
    dplyr::group_by(subjectID, activity) %>%
    dplyr::summarize_each(funs(mean)) %>% 
    melt(id.vars = c('subjectID','activity')) %>%
    write.table(file='tidy.txt',row.name=FALSE)


