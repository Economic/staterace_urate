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
             ratio = ifelse(subgroup_urate==0, NA, subgroup_urate/st_urate_12mos))
    
    #Progress tracker!
    print(paste("Calculating subgroup urates for: ", qtr_list[i+3]))
    
    #Calculate all subgroup unemployment rates, then merge above chunks
    all_subgroup_urates<- cps %>% 
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
      #merge statefips labels by st_abbr to get fips codes and CPS estimated urates
      left_join(state_urates) %>% 
      #get ratio of (12-month state avg:subgroup) unemployment rate
        ##NOTE: due to small sample sizes, occasionally subgroups show an unemployment rate of 0%
        ##Using ifelse() function, I avoid using these 0 values as a divisor.
      mutate(ratio = ifelse(subgroup_urate==0, NA, subgroup_urate/st_urate_12mos)) %>% 
      arrange(st_abbr, desc(n)) %>% 
      #Append US unemployment rates from above
      bind_rows(us_subgroup_urates) %>% 
      #merge quarterly laus urates from above
      left_join(quarterly_laus) %>% 
      
      # Create standard error, CV from subgroup urates, while avoid using 0's where sample size is too small.
      mutate(qtr_st_urate_by_reg = ratio * laus_qtr_unemp,
             se = ifelse(subgroup_urate==0, NA, sqrt(qtr_st_urate_by_reg*(1-qtr_st_urate_by_reg)/n)),
             cv = ifelse(subgroup_urate==0, NA, se / qtr_st_urate_by_reg)) %>% 
      
      # Thresh.15 suppresses all urates where the associated coefficient of variation is greater than 0.15
      # Thresh700 suppresses all urates where associated sample size is less than 700 (old methodology)
      mutate(thresh.15 = replace(qtr_st_urate_by_reg, cv>.15, NA),
             thresh700 = replace(qtr_st_urate_by_reg, n<700, NA)) %>%  
      left_join(geographic_labels) %>% 
      select(state, st_abbr, gender, wbhao, n, subgroup_urate,
             st_urate_12mos, ratio, laus_qtr_unemp, qtr_st_urate_by_reg,
             se, cv, thresh.15, thresh700) %>% # Clean our data up
      mutate(wbhao = replace_na(wbhao, 'All'),
             gender = replace_na(gender, 'All'),
             grp_qtrs = paste(qtr_list[i],'+',qtr_list[i+1],'+',qtr_list[i+2],'+', qtr_list[i+3]),
             qtr = paste(qtr_list[i+3])) %>% 
      filter(wbhao!='Other')
    
    output_dfs[[i]] <- all_subgroup_urates # save your dataframes into the list
    
  }
  return(output_dfs)
}


#call quarterly state function passing all quarters as arguments
my_state_dfs <- state_analysis(qtr_list)

#bind each data frame returned from function
all_qtrs <- bind_rows(my_state_dfs) %>% 
  filter(qtr!='NA')
