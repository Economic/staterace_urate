
#call quarterly state function passing all quarters as arguments
my_state_dfs <- state_analysis(qtr_list)

#bind each data frame returned from function
all_qtrs <- bind_rows(my_state_dfs) %>% 
  mutate(wbhao = replace_na(wbhao, 'All'),
         gender = replace_na(gender, 'All'))

# Clean our data up
state_unemp_rates_raw <- all_qtrs %>% 
  filter(gender=='All', wbhao!="All", wbhao!='Other', qtr!='NA') %>% 
  left_join(geographic_labels) %>% 
  left_join(national_state_ratios) %>% 
  select(qtr, div_label, state, st_abbr, gender, wbhao, n, subgroup_urate,
         st_urate_12mos, natl_urate_12mos, st_ratio, natl_ratio, st_weight, natl_weight, laus_qtr_unemp, cps_pool = grp_qtrs) %>% 
  #Calculates a final quarterly unemployment rate by multiplying a weighted mean
  #of state and national CPS ratios with LAUS quarterly state unemployment rates. See technical appendix for detail
  mutate(final_urate = laus_qtr_unemp*((st_ratio*st_weight)+(natl_ratio*natl_weight)))


# Create a table of state unemployment rates by quarter
state_unemp_rates_final <- state_unemp_rates_raw %>% 
  select(qtr, state, wbhao, final_urate) %>% 
  pivot_wider(id_cols = c(qtr, state), names_from=wbhao, values_from = final_urate) %>% 
  arrange(desc(qtr))

# Black/Hispanic:White unemployment ratios
all_ratios_wide <- state_unemp_rates_raw %>%
  filter(gender=='All') %>% 
  select(wbhao, final_urate, state, qtr) %>% 
  pivot_wider(names_from=c(wbhao), values_from = final_urate) %>% 
  mutate(bw.ratio = Black/White,
         hw.ratio = Hispanic/White) %>% 
  select(state, qtr, bw.ratio, hw.ratio) %>% 
  pivot_wider(id_cols = c(state), names_from = c(qtr), values_from = c(bw.ratio, hw.ratio))

# Alternative long output for BH:W ratios
all_ratios_long <- state_unemp_rates_raw %>%
  filter(gender=='All') %>% 
  select(wbhao, final_urate, state, qtr) %>% 
  pivot_wider(names_from=c(wbhao), values_from = final_urate) %>% 
  mutate(bw.ratio = Black/White,
         hw.ratio = Hispanic/White) %>% 
  select(state, qtr, bw.ratio, hw.ratio) %>% 
  arrange(desc(qtr))

#Create dataframe of 2021 Q1 data (pre-pandemic) for comparison
q1_2020 <- state_unemp_rates_raw %>% 
  filter(qtr=='2020 Q1') %>% 
  select(state, wbhao, final_urate) %>% 
  rename(urate_2020q1 = final_urate)

#this compares all quarters [2020 Q1 - present] of state unemployment rates relative to 2020 Q1
change_since_2020q1 <- state_unemp_rates_raw %>% 
  filter(gender=='All') %>% 
  select(state, wbhao, qtr, final_urate) %>%
  left_join(q1_2020) %>%
  arrange(desc(qtr)) %>% 
  mutate(across(final_urate|urate_2020q1, ~.x*100),
         change_since_2020q1 = ifelse(!is.na(final_urate) & !is.na(urate_2020q1), yes=final_urate-urate_2020q1, no=NA)) %>% 
  pivot_wider(id_cols = c(qtr, state), names_from = wbhao, values_from = change_since_2020q1)
