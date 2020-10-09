library(tidyverse)
library(epiextractr)
library(blsAPI)
library(here)
library(data.table)
library(zoo)


#######################
# Gameplan to automate
# state unemp by race

# 1.  Automate downloading series reports from BLS
# 1.2   Produce excel output of monthly urate by state
# 1.3   Produce quarterly average of urate by state
#       i.e. avg(1:3), avg(3:6) ... avg(9:12)..

# 2   Read in pooled CPS data (perhaps with extractr?)
# 2.2 produce ratio for each state by race and gender
# 2.3 Restrict output to those with sample size of 700<


#######################

bls_key <- Sys.getenv("BLS_REG_KEY")

series_ids <- fread("input/seriesid.csv")

statedata <- series_ids$series_id

# This is where our state unemployment data lives
rawsource <- "https://download.bls.gov/pub/time.series/la/"


#function to retreive data from BLS
get_bls_data <- function(codes) {
  
  payload <- list('seriesid' = codes, 'startyear' = '2001', 'endyear' = '2020', 'registrationkey' = bls_key)
  
  df1 <- blsAPI(payload, api_version = 2, return_data_frame = TRUE)
}
  

stSeries <- get_bls_data(statedata) %>% 
  mutate(urate = as.numeric(value), .keep="unused") %>%
  full_join(series_ids, by= c('seriesID' = 'series_id')) %>%
  mutate(month = as.numeric(substr(period,2,3))) %>% #create standard date variable
  mutate(date = as.Date(paste(year, month, 1, sep = "-"), "%Y-%m-%d")) %>% 
  mutate(qtr=as.yearqtr(date))  #create quarter variable
 
  
qtrly <- stSeries %>% 
  select(state, qtr, urate) %>% 
  group_by(state, qtr) %>% 
  summarize(qtr_urate = mean(urate)) %>% 
  pivot_wider(id_cols = state, names_from=qtr, values_from=qtr_urate)

