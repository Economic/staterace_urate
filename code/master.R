#Master file for quarterly state/division unemployment by race/ethnicity, and gender
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
end_year=year(Sys.Date())

#Load data files; LAUS, CPS, Geographic labels
source("code/urate_data.R", echo = TRUE)

# Formula we need is LAUS * (subgroupUSA * national ratio)+(subgroupState * state ratio)

#Function for estimating state level unemployment by race/ethnicity
source("code/state_analysis.R", echo = TRUE)

#Primary output; includes:
## State unemployment rates, Black/Hispanic - White unemployment ratios, and change since 2020Q1
source("code/primary_output.R", echo = TRUE)

#supplemental data including:
## unsuppressed urate counts by state/division, 
## CPS quarterly/monthly unemployment rates
## LAUS quarterly/monthly unemployment rates
## State share of division unemployment
## WBHAO share of state unemployment
source("code/supplement_data.R", echo = TRUE)

#Create state unemployment by race/ethnicity line charts
source("code/ggcharts.R", echo = TRUE)

#Excel workbook export
source("code/excel_export.R", echo = TRUE)



