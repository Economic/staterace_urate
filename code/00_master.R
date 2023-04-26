#Master file for quarterly state/division unemployment by race/ethnicity, and gender

# See technical appendix: Detailing the new methodology behind EPI’s quarterly state unemployment rates by race and ethnicity series
# https://www.epi.org/publication/new-methodology-quarterly-state-unemployment-rates-by-race-and-ethnicity-series/

#Author: Daniel Perez, 8/29/2022

#libraries
library(tidyverse)
library(epiextractr)
library(epidatatools)
library(blsAPI)
library(here)
library(readxl)
library(openxlsx)
library(data.table)
library(zoo)
library(lubridate)
library(janitor)
library(ggplot2)
library(wesanderson)

#BLS registration key needed for api version 2. register here: https://data.bls.gov/registrationEngine/
bls_key <- Sys.getenv("BLS_REG_KEY")

#NOTE: The lower bound year for this script is 1989, due to the limited availability of the wbhao variable. 
# See https://microdata.epi.org/variables/demographics/wbhao/.
start_year=2018
end_year=2023
# end_year=year(Sys.Date())

########### Data cleaning ###########

#Load data files; LAUS, CPS, Geographic labels
source("code/01_urate_data.R", echo = TRUE)


########### Analysis function ###########

#Function for estimating state level unemployment by race/ethnicity
source("code/02_state_analysis.R", echo = TRUE)

########### Primary output ###########

#Primary output; includes:
## State unemployment rates, Black/Hispanic - White unemployment ratios, and change since 2020Q1
source("code/03_primary_output.R", echo = TRUE)

########### Supplemental data ###########

source("code/04_supplement_data.R", echo = TRUE)

#supplemental data includes:
# - unsuppressed unemployment rate counts by state/division, 
# - CPS quarterly/monthly unemployment rates
# - LAUS quarterly/monthly unemployment rates
# - State share of division unemployment
# - WBHAO share of state unemployment


########### GG charts for technical appendix ###########

#Create state unemployment by race/ethnicity line charts for technical appendix
# source("code/ggcharts.R", echo = TRUE)

########### WordPress formatted data ###########

source("code/05_wordpress_figures.R", echo = TRUE)

########### Export data ###########

source("code/06_excel_export.R", echo = TRUE)



