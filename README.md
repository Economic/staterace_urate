# Quarterly state and division unemployment by race/ethnicity and gender
 
 This repository outputs estimated quarterly unemployment rates at the state and geographic division levels by race/ethnicity and gender. This data is updated and hosted on the Economic Policy Institute Economic indicators page on a quarterly basis, found [here](https://www.epi.org/indicators/state-unemployment-race-ethnicity/).  
## Data sources
BLS publishes Local Area Unemployment Statistics (LAUS) every month when the most current data are available. A schedule of the LAUS release can be found [here](https://www.bls.gov/schedule/news_release/laus.htm).

BLS publishes an Employment Situation report every month when the most current unemployment and labor statistics data is available. A schedule of the Employment Situation report release date can be found [here](https://www.bls.gov/schedule/news_release/empsit.htm). A pdf of the Employment Situation report can be found [here](https://www.bls.gov/news.release/pdf/empsit.pdf).

## API registration
In order to automate the collection of unemployment and labor statistics, BLS requires each user to acquire a registration key to access their APIs. BLS registration key can be found [here](https://data.bls.gov/registrationEngine/).

## Create from source
Run `master.R` from the code folder in the project root to automatically create the excel workbook output and state line charts in this project. To access excel workbooks view the output folder in the project root. To access line charts see the `output/stateplots` folder in the output subdirectory.
