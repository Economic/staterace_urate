# Division analysis function


#empty lists to store dfs
div_dfs <- list()

division_analysis <- function(quarters){
  
  for(i in 1:length(qtr_list)){ 
    
    laus_div_urates <- laus %>% 
      filter(qtr==qtr_list[i+3]) %>% 
      group_by(div_label) %>%
      summarize(laus_qtr_unemp = mean(urate))  
    
    cps_div_urates <- cps %>% 
      filter(qtr==qtr_list[i] | qtr == qtr_list[i+1] | qtr == qtr_list[i+2] | qtr == qtr_list[i+3]) %>% 
      group_by(div_label) %>% 
      summarize(div_urate_12mos = weighted.mean(unemp, w=basicwgt/12, na.rm=TRUE))
    
    us_subgroup_urates <- cps %>% 
      filter(qtr==qtr_list[i] | qtr == qtr_list[i+1] | qtr == qtr_list[i+2] | qtr == qtr_list[i+3]) %>% 
      mutate(overall= paste('US','-','All','-','All'),
             gender = paste('US','-','All','-',female),
             race = paste('US','-',wbhao,'-','All'),
             genderXrace = paste('US','-',wbhao,'-',female)) %>% 
      summarize_groups(overall|race|gender|genderXrace,
                       subgroup_urate = weighted.mean(unemp, w=basicwgt/12, na.rm=TRUE),
                       n=n()) %>% 
      #creates st_abbr, wbho, gender variables
      separate(group_value, c('div_label','wbhao','gender'), sep= ' - ') %>% 
      mutate(across(wbhao|gender, ~ str_squish(.x)),
             div_urate_12mos = subgroup_urate[1],
             div_label = "US",
             ratio = ifelse(subgroup_urate==0, NA, subgroup_urate/div_urate_12mos))
    
    #Progress tracker!
    print(paste("Calculating subgroup urates for: ", qtr_list[i+3]))
    
    all_subgroup_urates<- cps %>% 
      #restrict data to current quarters
      filter(qtr==qtr_list[i] | qtr == qtr_list[i+1] | qtr == qtr_list[i+2] | qtr == qtr_list[i+3]) %>% 
      #create subgroup variables
      mutate(divXrace = paste(div_label,'-', wbhao,'-','All'),
             divXgender = paste(div_label,'-','All','-',female),
             divXraceXgender = paste(div_label,'-',wbhao,'-',female)) %>% 
      #Estimate unemployment rates and sample sizes by subgroups
      summarize_groups(div_label|divXrace|divXraceXgender|divXgender,
                       subgroup_urate = weighted.mean(unemp, w=basicwgt/12, na.rm=TRUE),
                       n=n()) %>%
      #split group_value variable to create st_abbr, wbho, gender labels
      separate(group_value, c('div_label','wbhao','gender'), sep = ' - ') %>% 
      #merge statefips labels by st_abbr to get fips codes and CPS estimated urates
      left_join(cps_div_urates) %>% 
      #get ratio of (12-month state avg:subgroup) unemployment rate
      #NOTE: due to small sample sizes, occasionally subgroups show an unemployment rate of 0%
      #Using ifelse() function, I avoid using these 0 values as a divisor.
      mutate(ratio = ifelse(subgroup_urate==0, NA, subgroup_urate/div_urate_12mos)) %>% 
      arrange(div_label, desc(n)) %>% 
      #Append US unemployment rates from above
      bind_rows(us_subgroup_urates) %>% 
      #merge quarterly laus urates from above
      left_join(laus_div_urates) %>% 
      # Create standard error, CV from subgroup urates, while avoid using 0's where sample size is too small.
      mutate(qtr_div_urate_by_reg = ratio * laus_qtr_unemp,
             se = ifelse(subgroup_urate==0, NA, sqrt(qtr_div_urate_by_reg*(1-qtr_div_urate_by_reg)/n)),
             cv = ifelse(subgroup_urate==0, NA, se / qtr_div_urate_by_reg)) %>% 
      # Thresh.15 suppresses all urates where the associated coefficient of variation is greater than 0.15
      # Thresh700 suppresses all urates where associated sample size is less than 700 (old methodology)
      mutate(thresh.15 = replace(qtr_div_urate_by_reg, cv>.15, NA),
             thresh700 = replace(qtr_div_urate_by_reg, n<700, NA)) %>%  
      select(div_label, gender, wbhao, n, subgroup_urate,
             div_urate_12mos, ratio, laus_qtr_unemp, qtr_div_urate_by_reg,
             se, cv, thresh.15, thresh700) %>% # Clean our data up
      mutate(wbhao = replace_na(wbhao, 'All'),
             gender = replace_na(gender, 'All'),
             grp_qtrs = paste(qtr_list[i],'+',qtr_list[i+1],'+',qtr_list[i+2],'+', qtr_list[i+3]),
             qtr = paste(qtr_list[i+3])) %>% 
      filter(wbhao!='Other')
    
    div_dfs[[i]] <- all_subgroup_urates # save your dataframes into the list
    
  }
  return(div_dfs)
}


#call quarterly division function passing all quarters as arguments
my_div_dfs <- division_analysis(qtr_list) 

#bind each data frame returned from function
all_qtrs_div <- bind_rows(my_div_dfs)%>% 
  filter(qtr!='NA')

