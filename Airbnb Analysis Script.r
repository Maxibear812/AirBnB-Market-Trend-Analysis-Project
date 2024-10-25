library(tidyverse) # metapackage of all tidyverse packages

library(tidyverse)
library(lubridate)
library(readr)
library(readxl)
library(stringr)
# Load in the data sets. 

prices <- read.csv("airbnb_price.csv")

room_types <- read.excel("airbnb_room_type.xlsx")

last_reviews <- read.tsv("airbnb_last_review.tsv")

# Initial inspection.

head(last_reviews)

head(prices)

head(room_types)

# Row count. 

nrow(last_reviews)

nrow(prices)

nrow(room_types)

# Data type check. 

str(last_reviews)

str(prices)

str(room_types)

# Column names

colnames(last_reviews)

colnames(prices)

colnames(room_types)

# Check for missing values. 

sapply(last_reviews, function(x) sum(is.na(x)))

sapply(prices, function(x) sum(is.na(x)))

sapply(room_types, function(x) sum(is.na(x)))

# Check for duplicate rows in the df. 

nrow(last_reviews[duplicated(last_reviews), ])

nrow(prices[duplicated(prices), ])

nrow(room_types[duplicated(room_types), ])

# Check for duplicate values in listing_id fields. 

sum(duplicated(last_reviews$listing_id))

sum(duplicated(prices$listing_id))

sum(duplicated(room_types$listing_id))

# Check for duplicate values in the host_name field. 

sum(duplicated(last_reviews$host_name))

# 1. Merge dataframes together. 
airbnb_listings <- last_reviews %>%
                        inner_join(prices, by = 'listing_id') %>%
                        inner_join(room_types, by = 'listing_id')

head(airbnb_listings)

#2. Remove rows with NA values. 

airbnb_listings <- airbnb_listings %>% 
                            drop_na()

# Check the dataframe. 

sum(is.na(airbnb_listings))

head(airbnb_listings)

#3. Convert data types. 

# Price from character to numeric. Removing " dollars" first. 

airbnb_listings$price <- as.numeric(gsub(" dollars", "", airbnb_listings$price))

head(airbnb_listings)

airbnb_listings$price <- as.numeric(gsub("[^0-9.]", "", airbnb_listings$price))

head(airbnb_listings)

# Last_reviewed from character to POSIXct. 

airbnb_listings$last_review <- format(mdy(airbnb_listings$last_review), "%m-%d-%Y")

head(airbnb_listings)

# Shift column locations. 

airbnb_listings <- airbnb_listings %>%
    relocate(last_review, .after=room_type) %>%
    relocate(room_type, .after=nbhood_full)

head(airbnb_listings)
