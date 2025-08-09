# Load required libraries
library(dplyr)
library(readr)
library(lubridate)
library(stringr)
library(skimr)
library(ggplot2)
library(tidyr)

#Load the csv

netflix <- read_csv("D:\\data analyst\\R\\PROJECTS\\R for Analytics\\R-for-Data-Analystics\\Project 4\\data\\netflix_titles.csv") # this will be for cleaning and analysis

copy_netflix <- read_csv("D:\\data analyst\\R\\PROJECTS\\R for Analytics\\R-for-Data-Analystics\\Project 4\\data\\netflix_titles.csv") # Raw Data

glimpse(netflix)
str(netflix)
skim(netflix)

# Handling missing values

netflix |>
  filter(is.na(director), type == "TV Show")

# Check missing directors by content type
netflix %>%
  group_by(type) %>%
  summarise(
    total = n(),
    missing_director = sum(is.na(director)),
    percentage_missing = (missing_director / total) * 100
  )

netflix <- netflix |>
  mutate(
    director = ifelse(
      type == "TV Show" & is.na(director),
      "Multiple Directors",
      director
    )
  )


netflix %>%
  group_by(type) %>%
  summarise(
    total = n(),
    missing_cast = sum(is.na(cast)),
    percentage_missing = (missing_cast / total) * 100
  )


# Check a few examples of missing cast
netflix %>%
  filter(is.na(cast)) %>%
  select(type, title, director, country, rating) %>%
  head(10)


netflix <- netflix %>%
  mutate(
    cast = ifelse(is.na(cast), "Not Available", cast)
  )


netflix %>%
  select(date_added) %>%
  head(10)

# Convert date_added to proper date format
netflix <- netflix %>%
  mutate(
    date_added = mdy(date_added)
  )


# Check duration examples for both content types
netflix %>%
  group_by(type) %>%
  slice_head(n = 5) %>%
  select(type, title, duration)

netflix <- netflix %>%
  separate(duration, 
           into = c("duration_value", "duration_unit"), 
           sep = " ", 
           remove = FALSE)  # Keep original column for reference

# Verify the duration splitting
netflix %>%
  select(type, title, duration, duration_value, duration_unit) %>%
  group_by(type) %>%
  slice_head(n = 3)

# Verify the duration splitting
netflix %>%
  select(type, title, duration, duration_value, duration_unit) %>%
  str()

netflix <- netflix %>%
  mutate(
    duration_value = as.numeric(duration_value)
  )

# Examine multi-value fields
netflix %>%
  select(type, title, cast, country, listed_in) %>%
  slice_head(n = 5)


# See full genre strings
netflix %>%
  select(title, listed_in) %>%
  slice_head(n = 5) %>%
  mutate(listed_in = str_trunc(listed_in, width = 100))  # Show more characters

# Count unique genre combinations
netflix %>%
  count(listed_in, sort = TRUE) %>%
  head(10)

netflix <- netflix %>%
  mutate(
    type = as.factor(type),
    rating = as.factor(rating),
    duration_unit = as.factor(duration_unit)
  )

sum(duplicated(netflix))

# Save the cleaned dateset


write_csv(netflix_genre_country_expanded,"D:\\data analyst\\R\\PROJECTS\\R for Analytics\\R-for-Data-Analystics\\Project 4\\data\\netflix_titles_cleaned.csv") 


















































