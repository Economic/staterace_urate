#State analysis function

#empty lists to store dfs
output_dfs <- list()

state_analysis <- function(quarters){
  
  for(i in 1:length(qtr_list)){ 
    
    #Aggregate monthly LAUS into quarterly data
    quarterly_laus <- laus %>% 
      filter(qtr==qtr_list[i+3]) %>% 
      group_by(st_abbr) %>%
      summarize(laus_qtr_unemp = mean(urate))  
    
    #Calculate CPS state unemployment rates using most recent 12 months of data
    state_urates <- cps %>% 
      filter(qtr==qtr_list[i] | qtr == qtr_list[i+1] | qtr == qtr_list[i+2] | qtr == qtr_list[i+3]) %>% 
      group_by(st_abbr) %>% 
      summarize(st_urate_12mos = weighted.mean(unemp, w=basicwgt/12, na.rm=TRUE))

    
    #Calculates CPS unemp. rates for "super-groups" i.e. all states, all genders, all race/ethnicity and their combinations
    us_subgroup_urates <- cps %>% 
      filter(qtr==qtr_list[i] | qtr == qtr_list[i+1] | qtr == qtr_list[i+2] | qtr == qtr_list[i+3]) %>% 
      mutate(overall= paste('US','-','All','-','All'),
             gender = paste('US','-','All','-',female),
             race = paste('US','-',wbhao,'-','All'),
             genderXrace = paste('US','-',wbhao,'-',female)) %>% 
      summarize_groups(overall|race|gender|genderXrace,
                       subgroup_urate = weighted.mean(unemp, w=basicwgt/12, na.rm=TRUE),
                       n=n()) %>% 
      separate(group_value, c('st_abbr','wbhao','gender')) %>% #creates st_abbr, wbho, gender variables
      mutate(st_urate_12mos = subgroup_urate[1],
             st_abbr = 'US',
             st_ratio = ifelse(subgroup_urate==0, yes=0, no=subgroup_urate/st_urate_12mos))
               
    us_urate <- us_subgroup_urates %>% 
      filter(gender=='All', st_abbr=='US') %>%
      rename(natl_urate_12mos = st_urate_12mos,
             natl_ratio = st_ratio) %>% 
      select(wbhao, gender, natl_urate_12mos, natl_ratio)

    #Progress tracker!
    print(paste("Calculating subgroup urates for: ", qtr_list[i+3]))
    
    #Calculate all subgroup unemployment rates, then merge above chunks
    all_subgroup_urates <- cps %>% 
      #restrict data to last 12 months
      filter(qtr==qtr_list[i] | qtr == qtr_list[i+1] | qtr == qtr_list[i+2] | qtr == qtr_list[i+3]) %>% 
      #create subgroup variables
      mutate(stateXrace = paste(st_abbr,'-', wbhao,'-','All'),
             stateXgender = paste(st_abbr,'-','All','-',female),
             stXraceXgender = paste(st_abbr,'-',wbhao,'-',female)) %>% 
      #Estimate unemployment rates and sample sizes by subgroups
      summarize_groups(st_abbr|stateXrace|stXraceXgender|stateXgender,
                       subgroup_urate = weighted.mean(unemp, w=basicwgt/12, na.rm=TRUE),
                       n=n()) %>% 
      #split group_value variable to create st_abbr, wbho, gender labels
      separate(group_value, c('st_abbr','wbhao','gender')) %>% 
      mutate(wbhao = replace_na(wbhao, 'All'),
             gender = replace_na(gender, 'All')) %>% 
      #merge statefips labels by st_abbr to get fips codes and CPS estimated urates
      left_join(state_urates) %>% 
      arrange(st_abbr, desc(n)) %>% 
      #Append US unemployment rates from above
      bind_rows(us_subgroup_urates) %>% 
      left_join(us_urate) %>% 
      #merge quarterly laus urates from above
      left_join(quarterly_laus) %>% 
      #get ratio of (12-month state avg:subgroup) unemployment rate
      mutate(st_ratio = ifelse(subgroup_urate==0, yes=0, no=subgroup_urate/st_urate_12mos)) %>% 
      mutate(grp_qtrs = paste(qtr_list[i],'+',qtr_list[i+1],'+',qtr_list[i+2],'+', qtr_list[i+3]),
             qtr = paste(qtr_list[i+3]))
    
    output_dfs[[i]] <- all_subgroup_urates # save your dataframes into the list
    
  }
  return(output_dfs)
}