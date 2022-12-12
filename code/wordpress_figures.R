#WordPress figures
# Figures
#   1. State unemployment data with asterisks
#   2. Change since 2021 Q1 data with asterisks
#   3. Black-White, Hispanic-White unemployment ratios with asterisks


#formatted tables with asterisks
state_unemp_rates_asterisk <- state_unemp_rates_raw %>% 
  select(qtr, state, wbhao, asterisk_urate) %>% 
  pivot_wider(id_cols = c(qtr, state), names_from=wbhao, values_from = asterisk_urate) %>% 
  arrange(desc(qtr))

ratio_asterisk <- all_ratios_long %>% 
  left_join(natl_st_ratio_table) %>% 
  select(qtr, state, bw.ratio, hw.ratio, natl_wgt_black, natl_wgt_hispanic) %>% 
  mutate(ast_bw.ratio = ifelse(natl_wgt_black>=.7 & state!="United States", yes=paste0(formatC(round(bw.ratio, digits = 1), 1, format='f'),"*"), no=formatC(round(bw.ratio, digits=1),1,format='f')),
         ast_hw.ratio = ifelse(natl_wgt_hispanic>=.7 & state!="United States", yes=paste0(formatC(round(hw.ratio, digits = 1),1,format='f'),"*"), no=formatC(round(hw.ratio, digits=1),1,format='f'))) %>% 
  select(-bw.ratio, -hw.ratio)

change_2020q1_asterisk <- change_since_2020q1 %>% 
  left_join(natl_st_ratio_table, by="state") %>% 
  mutate(ast_all = ifelse(natl_wgt_all>=.7 & state!="United States", yes=paste0(formatC(round(All, digits = 1),1, format='f'),"*"), no=formatC(round(All, digits=1), 1,format = 'f')),
         ast_white = ifelse(natl_wgt_white>=.7 & state!="United States", yes=paste0(formatC(round(White, digits = 1), 1, format='f'),"*"), no=formatC(round(White, digits=1),1,format = 'f')),
         ast_black = ifelse(natl_wgt_black>=.7 & state!="United States", yes=paste0(formatC(round(Black, digits = 1),1, format='f'),"*"), no=formatC(round(Black, digits=1),1,format = 'f')),
         ast_hispanic = ifelse(natl_wgt_hispanic>=.7 & state!="United States", yes=paste0(formatC(round(Hispanic, digits = 1),1, format='f'),"*"), no=formatC(round(Hispanic, digits=1),1, format = 'f')),
         ast_asian = ifelse(natl_wgt_asian>=.7 & state!="United States", yes=paste0(formatC(round(Asian, digits = 1),1, format='f'),"*"), no=formatC(round(Asian, digits=1),1, format = 'f'))) %>% 
  select(qtr, state,natl_wgt_asian:ast_asian)



formatC(round(a,2),2,format="f")