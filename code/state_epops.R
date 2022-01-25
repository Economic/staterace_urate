library(tidyverse)
library(blsAPI)
library(here)
library(zoo)
library(readxl)
library(openxlsx)


bls_key <- Sys.getenv("BLS_REG_KEY")
series_ids <- fread(here('/input/epop_urate_seriesid.csv'))
state_epop <- series_ids$epop_id
state_urates <- series_ids$series_id #set this to epop_id to get EPOPs!

# This is where our state unemployment data lives
rawsource <- "https://download.bls.gov/pub/time.series/la/"

#function to retrieve data from BLS
#max number of years is 20 per query, max seriesids is 50 per query, max queries per day is 500 for registered users.
get_bls_data <- function(codes) {
  
  payload1 <- list('seriesid' = codes[2:50], 'startyear' = '2001', 'endyear' = '2020', 'registrationkey' = bls_key)
  payload2 <- list('seriesid' = codes[51:52], 'startyear' = '2001', 'endyear' = '2020', 'registrationkey' = bls_key)
  payload3 <- list('seriesid' = codes[2:50], 'startyear' = '1981', 'endyear' = '2000', 'registrationkey' = bls_key)
  payload4 <- list('seriesid' = codes[51:52], 'startyear' = '1981', 'endyear' = '2000', 'registrationkey' = bls_key)
  
  df1 <- blsAPI(payload1, api_version = 2, return_data_frame = TRUE)
  df2 <- blsAPI(payload2, api_version = 2, return_data_frame = TRUE)
  df3 <- blsAPI(payload3, api_version = 2, return_data_frame = TRUE)
  df4 <- blsAPI(payload4, api_version = 2, return_data_frame = TRUE)
  
  
  rbind(df1, df2, df3, df4)
}


# LAUS Epops
epops_laus <- get_bls_data(state_epop) %>% 
  mutate(epop = as.numeric(value)/100, .keep="unused") %>% #turn LAUS epop into percentages
  full_join(series_ids, by= c('seriesID' = 'epop_id')) %>% #merge state names
  select(-series_id) %>% 
  mutate(month = as.numeric(substr(period,2,3))) %>% #create standard date variable
  mutate(date = as.Date(paste(year, month, 1, sep = "-"), "%Y-%m-%d")) %>% 
  mutate(qtr=as.yearqtr(date)) %>% #create quarter variable
  arrange(year, month, state)


# LAUS Unemployment rates
urates_laus <- get_bls_data(state_urates) %>% 
  mutate(urate = as.numeric(value)/100, .keep="unused") %>% #turn LAUS epop into percentages
  full_join(series_ids, by= c('seriesID' = 'series_id')) %>% #merge state names
  mutate(month = as.numeric(substr(period,2,3))) %>% #create standard date variable
  mutate(date = as.Date(paste(year, month, 1, sep = "-"), "%Y-%m-%d")) %>% 
  mutate(qtr=as.yearqtr(date)) %>% #create quarter variable
  arrange(year, month, state)


# Table of monthly epop by state
st_epop_monthly <- epops_laus %>% 
  select(state, date, epop) %>%
  pivot_wider(id_cols = state, names_from=date, values_from=epop)

# Table of average quarterly epop by state
st_epop_qtrly <- epops_laus %>% 
  select(state, qtr, epop) %>% 
  group_by(state, qtr) %>% 
  summarize(qtr_epop = mean(epop)) %>% 
  pivot_wider(id_cols = state, names_from=qtr, values_from=qtr_epop)

# Table of average quarterly epop by state
st_epop_annual <- epops_laus %>% 
  select(state, year, epop) %>% 
  group_by(state, year) %>% 
  summarize(yrly_epop = mean(epop))# %>% 
  pivot_wider(id_cols = state, names_from=year, values_from=yrly_epop)


# Table of average quarterly epop by state
st_urates_annual <- urates_laus %>% 
  select(state, year, urate) %>% 
  group_by(state, year) %>% 
  summarize(yrly_urate = mean(urate))# %>% 
  pivot_wider(id_cols = state, names_from=year, values_from=yrly_urate)

  
st_pov <- read_csv(here('/input/pov_rates.csv'), col_names = TRUE) %>%
  mutate(year = as.character(year)) %>% 
  pivot_longer(!year, names_to = 'state', values_to = 'pov_rate') %>% 
  arrange(state, year)

resh_data <- st_pov %>% 
  left_join(st_urates_annual) %>% 
  left_join(st_epop_annual)
  
  
#Write to an excel workbook
state_epops_xl <- createWorkbook()

addWorksheet(state_epops_xl, sheetName = "State epop monthly (seas)",)
addWorksheet(state_epops_xl, sheetName = "State epop quarterly (seas)")
addWorksheet(state_epops_xl, sheetName = "State epop annual (seas)")
addWorksheet(state_epops_xl, sheetName = "State urates annual (seas)")
addWorksheet(state_epops_xl, sheetName = "Reshaped epop_urate_pov")



writeData(state_epops_xl, st_epop_monthly, sheet = "State epop monthly (seas)",
          startCol = 1, startRow = 1, colNames = TRUE, keepNA = TRUE, )
writeData(state_epops_xl, st_epop_qtrly, sheet = "State epop quarterly (seas)",
          startCol = 1, startRow = 1, colNames = TRUE, keepNA = TRUE)
writeData(state_epops_xl, st_epop_annual, sheet = "State epop annual (seas)",
          startCol = 1, startRow = 1, colNames = TRUE, keepNA = TRUE)
writeData(state_epops_xl, st_urates_annual, sheet = "State urates annual (seas)",
          startCol = 1, startRow = 1, colNames = TRUE, keepNA = TRUE)
writeData(state_epops_xl, resh_data, sheet = "Reshaped epop_urate_pov",
          startCol = 1, startRow = 1, colNames = TRUE, keepNA = TRUE)

saveWorkbook(state_epops_xl, here("/data/state_epops.xlsx"), overwrite = TRUE)
