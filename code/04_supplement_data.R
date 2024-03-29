#Supplemental data

# df of LAUS monthly unemployment rates by state
laus_monthly <- laus %>% 
  select(state, date, urate) %>%
  pivot_wider(id_cols = state, names_from=date, values_from=urate)

# df of LAUS quarterly unemployment rates by state
laus_qtrly <- laus %>% 
  select(state, qtr, urate) %>% 
  group_by(state, qtr) %>% 
  summarize(qtr_urate = mean(urate)) %>% 
  pivot_wider(id_cols = state, names_from=qtr, values_from=qtr_urate)

# df of CPS monthly unemployment rates by state
cps_monthly <- cps %>% 
  group_by(st_abbr, date) %>% 
  summarize(urate = weighted.mean(unemp, w=basicwgt)) %>%
  pivot_wider(id_cols = st_abbr, names_from=date, values_from = urate)

# df of CPS quarterly unemployment rates by state
cps_qtrly <- cps %>% 
  group_by(st_abbr, qtr) %>% 
  summarize(urate = weighted.mean(unemp, w=basicwgt/6)) %>%
  pivot_wider(id_cols = st_abbr, names_from=qtr, values_from = urate) 


#Additional dataframe used for calculating state share of division population
pop_cps <-load_basic(2021, year, month, basicwgt, age, female, wbhao, statefips, division, unemp, lfstat) %>% 
  mutate(date = as.Date(paste(year, month, 1, sep = "-"), "%Y-%m-%d")) %>% 
  #create quarterly date periods
  mutate(qtr=as.yearqtr(date)) %>%  
  #merge optional labels
  left_join(geographic_labels) %>% 
  mutate(across(wbhao|female, ~ as.character(haven::as_factor(.x))),
         div_label = as_factor(division))

#Calculates state labor force for 2021
state_lforce <- cps %>%
  filter(year==2021) %>%
  group_by(st_abbr) %>%
  summarize(st_lforce = sum(basicwgt/12, na.rm=TRUE),
            st_n=n())

#Calculates div labor force for 2021, merges state labor force, then calculates each state share of division
div_lforce <- cps %>%
  filter(year==2021) %>%
  group_by(div_label) %>%
  summarize(div_lforce = sum(basicwgt/12, na.rm=TRUE),
            div_n=n()) %>%
  left_join(geographic_labels) %>%
  left_join(state_lforce) %>%
  select(-division,-statefips) %>%
  relocate(st_abbr, state, .after=div_label) %>% 
  mutate(div_st_lfshare = st_lforce/div_lforce) %>% 
  relocate(contains('_n'), .after = div_st_lfshare)

#Calculates state labor force for 2021 by wbhao (race and ethnicity)
st_wbhao_lforce <- cps %>%
  filter(year==2021) %>%
  group_by(st_abbr, wbhao) %>%
  summarize(st_wbhao_lforce = sum(basicwgt/12, na.rm=TRUE),
            st_wbhao_n=n())

div_wbhao_lforce <- cps %>% 
  filter(year==2021) %>% 
  group_by(div_label, wbhao) %>% 
  summarize(div_wbhao_lforce = sum(basicwgt/12, na.rm=TRUE),
            div_wbhao_n=n())

#Calculates div labor force for 2021, merges state labor force, then calculates each state share of division by wbhao (race and)
div_share_wbhao <- div_lforce %>%
  left_join(st_wbhao_lforce) %>%
  left_join(div_wbhao_lforce) %>%
  mutate(st_wbhao_lfshare = st_wbhao_lforce/st_lforce,
         div_wbhao_lfshare = div_wbhao_lforce/div_lforce) %>% 
  select(div_label, state, div_lforce, st_lforce, div_st_lfshare, wbhao, div_wbhao_lforce, div_wbhao_lfshare, st_wbhao_lforce, st_wbhao_lfshare,
         div_n, st_n, div_wbhao_n, st_wbhao_n)

