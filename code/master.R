#Master file for Quarterly state/division unemployment by race/ethnicity, and gender
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
start_year=2012
end_year=year(Sys.Date())

#Load data files; LAUS, CPS, Geographic labels
source("code/urate_data.R", echo = TRUE)

#State analysis function
source("code/state_analysis.R", echo = TRUE)

#Geographic division analysis function
source("code/division_analysis.R", echo = TRUE)

#Primary output; includes:
## State/division unemployment rates, Black/Hispanic - White unemployment ratios, and change since 2020Q1
source("code/primary_output.R", echo = TRUE)

#supplemental data
source("code/supplement_data.R", echo = TRUE)

#Create state line charts
source("code/ggcharts.R", echo = TRUE)

#Excel workbook export
source("code/excel_expt.R", echo = TRUE)



