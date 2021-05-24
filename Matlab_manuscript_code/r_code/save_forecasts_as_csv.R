# save_forecasts_as_csv
# Author: Hannah Biegel (hbiegel@math.arizona.edu)

## Updated 5/24/21
# Save SIRICC forecasts according to COVID-19 Forecasting Hub guidelines
# Use the COVID Tracking Project (2020-11-16) as truth

library("R.matlab")
library("cdlTools")
library("envDocument")


# Set working directory to current location of this file
current_path_with_file <- getScriptPath()
current_path <- substr(current_path_with_file,1,nchar(current_path_with_file)-nchar("/save_forecasts_as_csv.R"))
setwd(current_path)


save_folder_name <- "EpiCovDA_forecasts"

state_list <- read.csv("../list_of_states.csv")
all_states <- c(1:53)

all_forecast_dates =
  c("2020-05-03",
    "2020-05-10","2020-05-17","2020-05-24","2020-05-31",
    "2020-06-07","2020-06-14","2020-06-21","2020-06-28",
    "2020-07-05",'2020-07-12','2020-07-19',
    '2020-07-26','2020-08-02','2020-08-09',
    '2020-08-16','2020-08-23','2020-08-30',
    '2020-09-06','2020-09-13')




all_data_choices = c('C','G','DC','DG')

for (forecast_date in all_forecast_dates){
  next_sat_ind <- 6
  next_sat <- next_sat_ind + as.Date(forecast_date) # 1 wk ahead forecast date
  tarType <- c("%d day ahead cum case","%d day ahead inc case","%d day ahead cum death","%d day ahead inc death")
  tarTypeCum <- c("%d wk ahead cum case","%d wk ahead inc case","%d wk ahead cum death","%d wk ahead inc death")


  quants_wanted <- c(0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99);

  submit_df <- data.frame()
  for (st in all_states){
    state_id <- state_list[st,1]
    state_id_fips = fips(state_id)

    if (st == 53){
      state_id_fips = "US"
    }

    if (state_id_fips < 10){
      state_id_fips = paste0("0",state_id_fips)
    }

    print(state_id_fips)




    for (k in 1:4){
      data_choice <- all_data_choices[k]
      curr_tar_type<- tarType[k]
      curr_tar_typeCum<- tarTypeCum[k]
      forecastfile = sprintf('../quantile_forecasts/%s_%s_%s.csv',
                             data_choice,state_id,forecast_date)


      temp_df<- read.csv("../state_hosp_data_2020-11-16/JHU_state_US.csv")
      temp_df$date <- as.Date(temp_df$date)

      current_deaths = temp_df[temp_df$date==(as.Date(forecast_date)),"death"]

      if (data_choice == "C"){
        current_deaths = temp_df[temp_df$date==(as.Date(forecast_date)),"positive"]

      }

      if ((st < 53)){
        JHU_state_file = sprintf('../state_hosp_data_2020-11-16/JHU_state_%s.csv',state_id)
        curr_JHU <- read.csv(JHU_state_file)
        curr_JHU$date <- as.Date(curr_JHU$date)
        current_deaths = curr_JHU[curr_JHU$date==(as.Date(forecast_date)),"death"]
        if (data_choice == "C"){
          current_deaths = curr_JHU[curr_JHU$date==(as.Date(forecast_date)),"positive"]

        }
      }

      update_term = current_deaths

      if (data_choice == 'DG'){
        update_term = 0
      }


      day_ahead_quants = read.csv(forecastfile,header=FALSE)
      ndp = length(day_ahead_quants[1,])

      # wk ahead forecasts
      for (j in 0:3){

        target <- sprintf(curr_tar_typeCum,j+1)
        value <- day_ahead_quants[,next_sat_ind+7*j] + update_term

        if ((k == 2 )|| (k == 4)){
          forecastfile2 = sprintf('../quantile_forecasts/%s_wk_%s_%s.csv',
                                  data_choice,state_id,forecast_date)
          wk_ahead_quants = read.csv(forecastfile2,header=FALSE)
          value <- wk_ahead_quants[,next_sat_ind+7*j]
        }

        curr_df <- data.frame(value)
        curr_df$target <- target
        curr_df$location <- as.character(state_id_fips)
        curr_df$type <- "quantile"
        curr_df$quantile <- quants_wanted
        curr_df$target_end_date <- next_sat+7*(j)
        curr_df$forecast_date <- forecast_date

        curr_df <- curr_df[,c("forecast_date","target","target_end_date",
                              "location",
                              "type","quantile","value")]

        point_df <- data.frame()
        point_df <- curr_df[1,]
        point_df$type <- "point"
        point_df$value <- curr_df$value[12] #median
        point_df$quantile <- NA


        submit_df <- rbind(submit_df,point_df,curr_df)
      }
    }
  }

  filename = sprintf("%s/%s-UA-EpiCovDA.csv",save_folder_name,as.Date(forecast_date))
  write.csv(submit_df,filename,row.names=FALSE)
}


