# script to clean passenger entries datastored in station-entry-and-exit-figures.xlsx file

# libs ---------------------------------------------------------------------------------------
library(tidyverse)

# sheets in excel file -----------------------------------------------------------------------

passenger_num_sheets <- c("2017 Entry & Exit", 
                          "2016 Entry & Exit", 
                          "2015 Entry & Exit", 
                          "2014 Entry & Exit",
                          "2013 Entry & Exit")

# function to extract and clean data from each sheet ------------------------------------------
station_entries <- function(sheet) { # function to extract the right data from each sheet
  
  year = str_sub(sheet, 1, 4)
  
  readxl::read_excel("raw-data/station-entry-and-exit-figures.xlsx", 
                     sheet = sheet, 
                     skip = 6) %>% 
    select(station = "Station",
           total = "million") %>% 
    mutate(year = year)
  
}

# map function to sheet -----------------------------------------------------------------------
station_numbers <- map_df(passenger_num_sheets, station_entries) %>% 
  filter(station != "Total") %>% 
  filter(!(is.na(station)))

# write as csv --------------------------------------------------------------------------------
write.csv(station_numbers, "output-data/station_numbers.csv", row.names = FALSE)
