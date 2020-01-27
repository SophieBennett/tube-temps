# script to extract and tidy tube temperatures csv

# libs ----------------------------------------------------------------------------

library(tidyverse)

# necessary data ------------------------------------------------------------------

months <- read_csv("raw-data/months.csv")

# function to extract data from url -----------------------------------------------

download_url <- function(url, fileext) {
  tempdir <- tempdir()
  path <- tempfile(tmpdir = tempdir, fileext = fileext)
  download.file(url, destfile = path, mode = "wb")
  path
}

# extract data --------------------------------------------------------------------
url <- "https://data.london.gov.uk/download/london-underground-average-monthly-temperatures/b01c7853-fff2-4781-9755-9b5e1404d78c/lu-average-monthly-temperatures.csv" # url for tube temp data download

tube_temps <- read_csv(download_url(url, ".csv"))

# data tidying --------------------------------------------------------------------

tube_temps <- tube_temps %>% 
  left_join(months, by = "Month") %>% 
  mutate(date = as.Date(paste("01", month_num, Year, sep = "/"), "%d/%m/%Y")) %>% 
  select(-month_num) %>% 
  gather(Bakerloo:`Sub-surface_lines`, key = "tube", value = "temperature") %>% 
  mutate(tube = ifelse(tube == "Sub-surface_lines", "Sub-Surface Lines", tube)) %>% 
  mutate(tube = ifelse(tube == "Waterloo_and_City", "Waterloo and City", tube))

# save clean data to csv ----------------------------------------------------------

write.csv(tube_temps, "output-data/tube_temps.csv", row.names = FALSE)