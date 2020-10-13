library(tidyverse)
library(epiextractr)
library(blsAPI)
library(here)
library(data.table)
library(zoo)


#######################
# Gameplan to automate
# state unemp by race

# 1.    Automate downloading series reports from BLS    -DONE
# 1.2   Produce excel output of monthly urate by state  -DONE
# 1.3   Produce quarterly average of urate by state     -DONE

# 2     Read in pooled CPS data                         -DONE
# 2.2   produce ratio for each state by race and gender -
# 2.3   Restrict output to those with sample size of 700<


#######################

bls_key <- Sys.getenv("BLS_REG_KEY")

series_ids <- fread("input/seriesid.csv")

statedata <- series_ids$series_id

# This is where our state unemployment data lives
rawsource <- "https://download.bls.gov/pub/time.series/la/"


#function to retreive data from BLS
#max number of years is 20 per query, max seriesids is 50 per query, max querys per day is 500 for registered users.
get_bls_data <- function(codes) {
  
  payload <- list('seriesid' = codes[1:50], 'startyear' = '2001', 'endyear' = '2020', 'registrationkey' = bls_key)
  payload2<- list('seriesid' = codes[51:52], 'startyear' = '2001', 'endyear' = '2020', 'registrationkey' = bls_key)
  
  df1 <- blsAPI(payload, api_version = 2, return_data_frame = TRUE)
  df2 <-blsAPI(payload2, api_version = 2, return_data_frame = TRUE)
  
  rbind(df1, df2)
}
  

# Clean and format bls data
stSeries <- get_bls_data(statedata) %>% 
  mutate(urate = as.numeric(value), .keep="unused") %>%
  full_join(series_ids, by= c('seriesID' = 'series_id')) %>%
  mutate(month = as.numeric(substr(period,2,3))) %>% #create standard date variable
  mutate(date = as.Date(paste(year, month, 1, sep = "-"), "%Y-%m-%d")) %>% 
  mutate(qtr=as.yearqtr(date))  #create quarter variable
 
# Table of average quarterly unemployment by state
qtrly <- stSeries %>% 
  select(state, qtr, urate) %>% 
  group_by(state, qtr) %>% 
  summarize(qtr_urate = mean(urate)) %>% 
  pivot_wider(id_cols = state, names_from=qtr, values_from=qtr_urate)


# 2  load 2 quarters of CPS data (modify later to make interactive)
cps <-load_cps(years = 2020,months = 3:9, sample="basic") %>% 
  filter(age>=16) %>% 
  select(female, wbhao, statefips, unemp, month, cmpwgt)

#calculate unemployment rate by state, sex, race/ethnicity
race_urate<-cps %>% 
  group_by(statefips, female, wbhao) %>% 
  summarize(urtP = weighted.mean(unemp,cmpwgt/3),
            n_urt = n())
  
 #will need to filter obs <= 700