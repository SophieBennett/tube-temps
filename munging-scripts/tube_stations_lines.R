# script to scrape and clean list of tube stations and lines

# libs -------------------------------------------------------------------------------------
library(rvest)
library(xml2)
library(tidyverse)

# url for scraping -------------------------------------------------------------------------
URL <- "https://en.wikipedia.org/wiki/List_of_London_Underground_stations"

# scraping ---------------------------------------------------------------------------------
stations <- read_html(URL) %>% 
  html_node("body") %>% 
  html_node("table") 

df_stations <- stations %>% 
  html_table() %>% 
  as_tibble()

# Where multiple lines are relevant for a station in the html table
# they are in seperate a tags

# Go back to the html
df_stations$line <- stations %>%
  # Get the second column
  rvest::html_nodes(xpath = "tbody/tr[*]/td[2]") %>% 
  # Map to keep cell data together (i.e., there might be 1 or more a tags per cell)
  purrr::map(~ .x %>% 
               rvest::html_nodes(xpath = "a") %>% 
               # The line is in the title attribute
               rvest::html_attr("title"))

# cleaning --------------------------------------------------------------------------------
df_stations <- df_stations %>% 
  select(Station, line) %>% 
  tidyr::unnest()

df_stations <- df_stations %>% 
  mutate(line = str_remove(line, " line")) %>% 
  mutate(line = str_remove(line, " \\(London Underground\\)"))

# write to csv -------------------------------------------------------------------------------
write.csv(df_stations, "output-data/tube_stations.csv", row.names = FALSE)  


