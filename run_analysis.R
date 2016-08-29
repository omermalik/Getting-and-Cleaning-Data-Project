## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Load: activity labels
Var_activity_labels <- read.table("./UCI HAR Dataset/Var_activity_labels.txt")[,2]

# Load: data column names
Var_features <- read.table("./UCI HAR Dataset/Var_features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extract_Var_features <- grepl("mean|std", Var_features)

# Load and process Var_X_test & Var_y_test data.
Var_X_test <- read.table("./UCI HAR Dataset/test/Var_X_test.txt")
Var_y_test <- read.table("./UCI HAR Dataset/test/Var_y_test.txt")
Var_subject_test <- read.table("./UCI HAR Dataset/test/Var_subject_test.txt")

names(Var_X_test) = Var_features

# Extract only the measurements on the mean and standard deviation for each measurement.
Var_X_test = Var_X_test[,extract_Var_features]

# Load activity labels
Var_y_test[,2] = Var_activity_labels[Var_y_test[,1]]
names(Var_y_test) = c("Activity_ID", "Activity_Label")
names(Var_subject_test) = "subject"

# Bind data
Var_test_data <- cbind(as.data.table(Var_subject_test), Var_y_test, Var_X_test)

# Load and process Var_X_train & Var_Y_train data.
Var_X_train <- read.table("./UCI HAR Dataset/train/Var_X_train.txt")
Var_Y_train <- read.table("./UCI HAR Dataset/train/Var_Y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(Var_X_train) = Var_features

# Extract only the measurements on the mean and standard deviation for each measurement.
Var_X_train = Var_X_train[,extract_Var_features]

# Load activity data
Var_Y_train[,2] = Var_activity_labels[Var_Y_train[,1]]
names(Var_Y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Bind data
train_data <- cbind(as.data.table(subject_train), Var_Y_train, Var_X_train)

# Merge test and train data
data = rbind(Var_test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt")