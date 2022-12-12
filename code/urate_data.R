
#BLS API keys are available at https://www.bls.gov/developers/
series_ids <- fread(here('input/seriesid.csv'))
statedata <- series_ids$series_id

# This is where our state unemployment data lives
rawsource <- "https://download.bls.gov/pub/time.series/la/"

#function to retrieve data from BLS
#max number of years is 20 per query, max seriesids is 50 per query, max queries per day is 500 for registered users.
get_bls_data <- function(codes) {
  
  payload1 <- list('seriesid' = codes[1:50], 'startyear' = '1983', 'endyear' = '2002', 'registrationkey' = bls_key)
  payload2 <- list('seriesid' = codes[1:50], 'startyear' = '2003', 'endyear' = '2022', 'registrationkey' = bls_key)
  payload3 <- list('seriesid' = codes[51:52], 'startyear' = '1983', 'endyear' = '2002', 'registrationkey' = bls_key)
  payload4 <- list('seriesid' = codes[51:52], 'startyear' = '2003', 'endyear' = '2022', 'registrationkey' = bls_key)
  
  
  df1 <- blsAPI(payload1, api_version = 2, return_data_frame = TRUE)
  df2 <- blsAPI(payload2, api_version = 2, return_data_frame = TRUE)
  df3 <- blsAPI(payload3, api_version = 2, return_data_frame = TRUE)
  df4 <- blsAPI(payload4, api_version = 2, return_data_frame = TRUE)
  
  #comine all years of data
  rbind(df1, df2, df3, df4)
}


#load state labels
geographic_labels<- read_csv(here('input/geographic_labels.csv'), col_names = TRUE)

#Load national-state demographic group ratios. See technical appendix for more details
national_state_ratios <-read_csv(here('input/national_state_ratios.csv'))

#Create a wide form of national_state_ratios table, for formatting post-analysis (see primary_output.R)
natl_st_ratio_table <-national_state_ratios %>% 
  pivot_wider(id_cols = c(state), names_from = wbhao, values_from = natl_weight,names_prefix = "natl_wgt_") %>% 
  clean_names("snake")

#Use EPI extractr to load CPS Basic. See more about package at https://github.com/Economic/epiextractr
cps <-load_basic(start_year:end_year, year, month, basicwgt, age, female, wbhao, statefips, division, unemp, lfstat) %>% 
  filter(age>=16, lfstat %in% c(1,2)) %>% 
  mutate(date = as.Date(paste(year, month, 1, sep = "-"), "%Y-%m-%d")) %>% 
  #create quarterly date periods
  mutate(qtr=as.yearqtr(date)) %>%  
  #merge optional labels
  left_join(geographic_labels) %>% 
  mutate(across(wbhao|female, ~ as.character(haven::as_factor(.x))),
         div_label = as_factor(division))


# LAUS are Local Area Unemployment Statistics from the BLS https://www.bls.gov/lau/ and loaded via BLS API

# Clean and format bls data
laus <- get_bls_data(statedata) %>% 
  #convert LAUS urates into percentages
  mutate(urate = as.numeric(value)/100, .keep="unused") %>% 
  #merge state names by series ID
  full_join(series_ids, by= c('seriesID' = 'series_id')) %>%
  #create standard date variable
  mutate(month = as.numeric(substr(period,2,3))) %>% 
  mutate(date = as.Date(paste(year, month, 1, sep = "-"), "%Y-%m-%d")) %>% 
  #create quarterly variable 
  mutate(qtr=as.yearqtr(date)) %>% 
  arrange(year, month, state) %>% 
  left_join(geographic_labels)


# Vector of each quarter to be analyzed
qtr_list <- c(unique(cps$qtr))
