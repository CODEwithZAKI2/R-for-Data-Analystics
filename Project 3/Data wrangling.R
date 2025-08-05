# Load required libraries
library(dplyr)
library(readr)
library(lubridate)
library(stringr)
library(skimr)
library(ggplot2)

#Load the csv

hr_data <- read_csv("D:\\data analyst\\R\\PROJECTS\\R for Analytics\\R-for-Data-Analystics\\Project 3\\data\\HR-Employee.csv") # this will be for cleaning and analysis

copy_hr_data <- read_csv("D:\\data analyst\\R\\PROJECTS\\R for Analytics\\R-for-Data-Analystics\\Project 3\\data\\HR-Employee.csv") # RAW data

glimpse(hr_data)
str(hr_data)
skim(hr_data)

# Convert categorical columns to factor
hr_data <- hr_data %>%
  mutate(
    Attrition = as.factor(Attrition),
    BusinessTravel = as.factor(BusinessTravel),
    Department = as.factor(Department),
    EducationField = as.factor(EducationField),
    Gender = as.factor(Gender),
    JobRole = as.factor(JobRole),
    MaritalStatus = as.factor(MaritalStatus),
    OverTime = as.factor(OverTime)
  )

summary(hr_data)

# Convert ordinal columns to ordered factor
hr_data <- hr_data %>%
  mutate(
    Education = factor(Education, levels = 1:5, ordered = TRUE),
    EnvironmentSatisfaction = factor(EnvironmentSatisfaction, levels = 1:4, ordered = TRUE),
    JobInvolvement = factor(JobInvolvement, levels = 1:4, ordered = TRUE),
    JobLevel = factor(JobLevel, levels = 1:5, ordered = TRUE),
    JobSatisfaction = factor(JobSatisfaction, levels = 1:4, ordered = TRUE),
    PerformanceRating = factor(PerformanceRating, levels = 1:4, ordered = TRUE),
    RelationshipSatisfaction = factor(RelationshipSatisfaction, levels = 1:4, ordered = TRUE),
    StockOptionLevel = factor(StockOptionLevel, levels = 0:3, ordered = TRUE),
    WorkLifeBalance = factor(WorkLifeBalance, levels = 1:4, ordered = TRUE)
  )


# Remove unnecessary columns
hr_data <- hr_data %>%
  select(
    -EmployeeCount,
    -Over18,
    -StandardHours,
    -EmployeeNumber
  )










































