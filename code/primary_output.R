#Primary output

## Suppress state urates by CV threshold of .15
urates_wbhao_state_cv.15 <- all_qtrs %>% 
  filter(gender=='All') %>% 
  select(state, wbhao, qtr, thresh.15) %>%
  arrange(wbhao, desc(qtr)) %>% 
  pivot_wider(id_cols = c(qtr, wbhao), names_from = c(state), values_from = thresh.15)

urates_wbhao_division_cv.15 <- all_qtrs_div %>% 
  filter(gender=='All') %>% 
  select(div_label, wbhao, qtr, thresh.15) %>%
  arrange(wbhao, desc(qtr)) %>% 
  pivot_wider(id_cols = c(qtr, wbhao), names_from = c(div_label), values_from = thresh.15)

## Suppress state urates by a sample size threshold of 700
urates_wbhao_state_n700 <- all_qtrs %>% 
  filter(gender=='All') %>% 
  select(state, wbhao, qtr, thresh700) %>%
  arrange(wbhao, desc(qtr)) %>% 
  pivot_wider(id_cols = c(qtr, wbhao), names_from = c(state), values_from = thresh700)

urates_wbhao_division_n700 <- all_qtrs_div %>% 
  filter(gender=='All') %>% 
  select(div_label, wbhao, qtr, thresh700) %>%
  arrange(wbhao, desc(qtr)) %>% 
  pivot_wider(id_cols = c(qtr, wbhao), names_from = c(div_label), values_from = thresh700)


# Black/Hispanic:White unemployment ratios
all_ratios_wide <- all_qtrs %>%
  filter(gender=='All') %>% 
  select(wbhao, thresh.15, state, qtr) %>% 
  pivot_wider(names_from=c(wbhao), values_from = thresh.15) %>% 
  mutate(bw.ratio = Black/White,
         hw.ratio = Hispanic/White) %>% 
  select(state, qtr, bw.ratio, hw.ratio) %>% 
  pivot_wider(id_cols = c(state), names_from = c(qtr), values_from = c(bw.ratio, hw.ratio))

# Alternative long output for BH:W ratios
all_ratios_long <- all_qtrs %>%
  filter(gender=='All') %>% 
  select(wbhao, thresh.15, state, qtr) %>% 
  pivot_wider(names_from=c(wbhao), values_from = thresh.15) %>% 
  mutate(bw.ratio = Black/White,
         hw.ratio = Hispanic/White) %>% 
  select(state, qtr, bw.ratio, hw.ratio) %>% 
  arrange(desc(qtr))


#this compares all quarters [2020 Q1 - present] of state unemployment rates relative to 2020 Q1
change_since_2020q1 <- all_qtrs %>% 
  filter(gender=='All') %>% 
  select(state, wbhao, qtr, thresh.15) %>% 
  pivot_wider(id_cols = c(state,wbhao), names_from = qtr, values_from = thresh.15) %>% 
  clean_names('all_caps') %>% 
  select(STATE, WBHAO, X2020_Q1:X2022_Q1) %>% 
  #subtract all columns by 2020 Q1 column, mult by 100 to get change since 2020 Q1
  mutate(across(X2020_Q1:X2022_Q1, .fns =  ~(.x - X2020_Q1)*100)) %>% 
  pivot_longer(!c(STATE, WBHAO), names_to = 'qtr', values_to = 'change') %>% 
  arrange(qtr) %>% 
  pivot_wider(id_cols = c(STATE), names_from = c(WBHAO,qtr), values_from = change)
