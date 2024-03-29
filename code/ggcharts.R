#Line charts of qtly state unemployment rates by race/ethnicity

plotdata <- state_unemp_rates_raw %>% 
  mutate(qtr = as.yearqtr(qtr)) %>% 
  filter(gender=='All', wbhao!='NA')

plotstates <- unique(plotdata$state)

#a potential function version?
st_plot_function <- function(plotstates){
  
  for(i in 1:length(plotstates)){
    
    df <- plotdata %>% 
      filter(state==plotstates[i])
    
    ggplot(aes(x=qtr, y=final_urate, group=wbhao, color=wbhao), data=df)+
      theme_light()+
      theme(plot.title = element_text(size=16, face="bold.italic"))+
      labs(title = plotstates[i], y="Final subgroup urate (3-mon LAUS * ((st weight*12mos state ratio) + (natl. weight*12-mon natl ratio))", x="Year-Quarter")+
      scale_color_manual(values = wes_palette(n=5, name = "Cavalcanti1"), name="Race/ethnicity")+
      geom_line(size=1)
    
    #save photo to output
    ggsave(here(paste0('output/stateplots/',plotstates[i],'.png')), plot = last_plot(), dpi=300, width = 9, height = 5)
    
  }
}

st_plot_function(plotstates) 