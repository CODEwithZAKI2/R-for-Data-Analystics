# Load required libraries
library(dplyr)
library(readr)
library(lubridate)
library(stringr)
library(skimr)

#Load the csv

superstore <- read_csv("D:\\data analyst\\R\\PROJECTS\\R for Analytics\\Project 2\\dataset\\Superstore.csv")

# Initial exploration
glimpse(superstore)
head(superstore)
skim(superstore) # Shows detailed summary of all columns


# Check dimensions
dim(superstore)

# Check for missing values
sapply(superstore, function(x) sum(is.na(x)))


# Check data types
str(superstore)

# Check unique values in categorical columns
sapply(superstore[sapply(superstore, is.character)],
       function(x) length(unique(x)))


# Rename the column names to remove the space
superstore <- superstore |>
  rename_all(~ gsub(" ", "_", .))

superstore <- superstore |>
  rename_all(~ gsub("-", "_", .))

#check for the date columns
head(superstore$Order_Date, 20)
head(superstore$Ship_Date, 20)

# Convert Order_Date from character ("11/8/2016") to Date format

superstore <- superstore |>
  mutate(
    Order_Date = parse_date_time(Order_Date, orders = c("m/d/Y"))
  )

# Convert Ship_date from character ("11/8/2016") to Date format

superstore <- superstore |>
  mutate(
    Ship_Date = parse_date_time(Ship_Date, orders = c("m/d/Y"))
  )

# Check for duplicates
sum(duplicated(superstore))


# check if there are any records where Ship_Date is earlier than Order_Date?

superstore |>
  filter(Ship_Date < Order_Date) |>
  select(Order_ID)

# check for outliers in numerical columns (Sales, Profit, Discount, Quantity).


superstore |>
    filter(Discount < 0 | Discount > 1) |>
    select(Discount)

summary(superstore$Discount)
range(superstore$Discount) # Min and Max
sum(superstore$Discount < 0 | superstore$Discount > 1)

quantile(superstore$Discount, c(0, 0.25, 0.5, 0.75, 0.95, 1))


# check if there are any negative sales values?

summary(superstore$Sales)
range(superstore$Sales) # Min and Max
sum(superstore$Sales < 0)

# check the Profit column using the same methods? 

summary(superstore$Profit)
range(superstore$Profit) # Min and Max
sum(superstore$Profit < 0)

superstore |>
  filter(Profit < 0)

# check the Quantity column to complete our data cleaning

summary(superstore$Quantity)
range(superstore$Quantity) # Min and Max
sum(superstore$Quantity < 0)

table(superstore$Quantity)  # Shows frequency of each quantity

quantile(superstore$Quantity, seq(0, 1, 0.1))  # Shows 10%, 20%, 30%... percentiles


str(superstore)
# Show postal codes that contain letters
superstore |> 
  filter(grepl("[A-Za-z]", Postal_Code)) |> 
  select(Postal_Code, Country) |> 
  head(10)


            # The dataset is clean and ready for Analysis #


# Save the cleaned Dataset
write_csv(superstore, "D:\\data analyst\\R\\PROJECTS\\R for Analytics\\Project 2\\dataset\\Superstore_cleaned.csv")






































  
  
  
  
