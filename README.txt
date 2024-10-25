# Project Background
***

![Skyline View of New York City](https://www.wallart.com/media/catalog/product/cache/5b18b93ddbe5d6592c6b175f41d24454/n/e/new-york-manhattan-skyline-op-fotobehang_10.jpg)

Welcome to New York City, one of the most-visited cities in the world. There are many Airbnb listings in New York City to meet the high demand for temporary lodging for travelers, which can be anywhere between a few nights to many months. As a consultant to I will take a closer look at the New York Airbnb market by combining data from multiple file types like .csv, .tsv, and .xlsx (Excel files).

## Objective

As a consultant, I will be analyzing the available New York Airbnb market data to provide insights to real estate market trends for the fictional real estate company. Specifically: 

- Determine the earliest and most recent review dates. 
- Find out how many listings are private rooms. 
- Find the average price of listings. 

Once these have been determined, I'll compile the values into a tibble called "review_dates"

## Stakeholders

As mentioned, this is a project working as a consultant to a fictional real estate company. 
```
# This R environment comes with many helpful analytics packages installed
# It is defined by the kaggle/rstats Docker image: https://github.com/kaggle/docker-rstats
# For example, here's a helpful package to load

library(tidyverse) # metapackage of all tidyverse packages

# Input data files are available in the read-only "../input/" directory
# For example, running this (by clicking run or pressing Shift+Enter) will list all files under the input directory

list.files(path = "../input")

# You can write up to 20GB to the current directory (/kaggle/working/) that gets preserved as output when you create a version using "Save & Run All" 
# You can also write temporary files to /kaggle/temp/, but they won't be saved outside of the current session

```
library(tidyverse)
library(lubridate)
library(readr)
library(readxl)
library(stringr)
# Load in the data sets. 

last_reviews <- read_tsv("/kaggle/input/airbnb-price/Airbnb price/airbnb_last_review.tsv")

prices <- read_csv("/kaggle/input/airbnb-price/Airbnb price/airbnb_price.csv")

room_types <- read_excel("/kaggle/input/airbnb-price/Airbnb price/airbnb_room_type.xlsx")
```

```
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
```

# Cleaning & EDA
​
After importing and doing the initial inspection of the three datasets are in different formats (csv, tsv, and xlsx), I found the following: 
***
​
The Airbnb-price datasets consist of three tables: airbnb_last_review.tsv, airbnb_price.csv, and airbnb_room_type.xlsx. There is a total of 75,627 rows (25,209 each) and I've included a brief description of each table below: 
​
**airbnb_price.csv**
- This is a CSV file containing data on Airbnb listing prices and locations.
- **`listing_id`**: unique identifier of listing (4 digit numeric) - 0 missing values. 
- **`price`**: nightly listing price in USD (string) - 0 missing values. 
- **`nbhood_full`**: name of borough and neighborhood where listing is located (string) - 0 missing values. 
​
**airbnb_room_type.xlsx**
This is an Excel file containing data on Airbnb listing descriptions and room types.
- **`listing_id`**: unique identifier of listing (4 digit numeric)
- **`description`**: listing description (string) - 10 missing values. 
- **`room_type`**: Airbnb has three types of rooms: shared rooms, private rooms, and entire homes/apartments (string)
​
**airbnb_last_review.tsv**
This is a TSV file containing data on Airbnb host names and review dates.
- **`listing_id`**: unique identifier of listing (4 digit numeric)
- **`host_name`**: name of listing host (string) - 8 missing values
- **`last_review`**: date when the listing was last reviewed (string)
​
### Missing Values
​
**airbnb_price.csv**
​
- **`listing_id`**: 0 missing values. 
- **`price`**: 0 missing values. 
- **`nbhood_full`**: 0 missing values. 
​
**airbnb_room_type.xlsx**
​
- **`listing_id`**: 0 missing values.
- **`description`**: <span style ="color: red">10 missing values. <span>
- **`room_type`**: 0 missing values. 
​
**airbnb_last_review.tsv**
​
- **`listing_id`**: 0 missing values. 
- **`host_name`**: <span style ="color: red">8 missing values.<span>
- **`last_review`**: 0 missing values. 
​
In summary, 8 rows with missing data in last_review under the host_name field, 10 in room_type under the description field. 
​
### Duplicate Rows and Values
​
There are also no duplicate rows in any of the dfs, but there are 17845 duplicate values in the host_name field of the last_reviews df. However, the nature of this field is more beneficial 
​
## Cleaning Objectives
    
1. **Merge Dataframes Together**
     
    Merge all dataframes into one I'll dub airbnb_listings for easier analysis and cleaning. 
​
2. **Remove NA Values**
    
    Given all dfs have 25,209 total rows, the 8 missing values from the last_reviews df represent a total of 0.03% of the data, and the 10 missing values from the room_type df represent a total of 0.04% of the data.  
    
    Both represent a small portion of the available data, and attempting to impute the missing values wouldn't benefit the analysis. Last_review's host_name field would require matching up listing_ids with the host_names, and the description value would be too difficult to replace. 
    
    As such, I'll simply be removing the missing values. 
​
3. **Leave Duplicate Values** 
    
    As the duplicate assessment shows above, there are no duplicate rows in any of the dataframes, though there are a substantial 17845 duplicate values in the host_name field 
​
4. **Adjust Data Types**
       
    To accomplish the statistical analysis I'll need to convert the prices and review date fields. Prices can be converted to a numeric format, and last_reviewed can be converted to YYYY-MM-DD format. 
    
5. **Move Columns**

```
# 1. Merge dataframes together. 
airbnb_listings <- last_reviews %>%
                        inner_join(prices, by = 'listing_id') %>%
                        inner_join(room_types, by = 'listing_id')

head(airbnb_listings)
```
```
#2. Remove rows with NA values. 

airbnb_listings <- airbnb_listings %>% 
                            drop_na()

# Check the dataframe. 

sum(is.na(airbnb_listings))

head(airbnb_listings)
```
```
#3. Convert data types. 

# Price from character to numeric. Removing " dollars" first. 

airbnb_listings$price <- as.numeric(gsub(" dollars", "", airbnb_listings$price))

head(airbnb_listings)

airbnb_listings$price <- as.numeric(gsub("[^0-9.]", "", airbnb_listings$price))

head(airbnb_listings)

# Last_reviewed from character to POSIXct. 

airbnb_listings$last_review <- format(mdy(airbnb_listings$last_review), "%m-%d-%Y")

head(airbnb_listings)
```

```
# Shift column locations. 

airbnb_listings <- airbnb_listings %>%
    relocate(last_review, .after=room_type) %>%
    relocate(room_type, .after=nbhood_full)

head(airbnb_listings)
```
