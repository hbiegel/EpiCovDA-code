# save_all_forecasts_with_truth

# Updated 10/8/20  HRB

library("cdlTools") # package to convert fips to state abbreviations
library("envDocument") # package to find current path



# Set working directory to current location of this file
current_path_with_file <- getScriptPath()
current_path <- substr(current_path_with_file,1,nchar(current_path_with_file)-nchar("/save_all_forecasts_with-truth.R"))
setwd(current_path)

folderName = "UA-EpiCovDA-forecasts"
modelName = "UA-EpiCovDA"


submission_scores <- data.frame()

forecasts = read.csv(
  sprintf("%s/%s-%s.csv",folderName,"2020-05-03",modelName))
forecasted_locations = forecasts[(forecasts$target=="1 wk ahead cum death")&
                                   (forecasts$type=="point"),"location"]


all_forecast_dates =
  c("2020-05-03",
    "2020-05-10","2020-05-17","2020-05-24","2020-05-31",
    "2020-06-07","2020-06-14","2020-06-21","2020-06-28",
    "2020-07-05",'2020-07-12','2020-07-19',
    '2020-07-26','2020-08-02','2020-08-09',
    '2020-08-16','2020-08-23','2020-08-30',
    '2020-09-06','2020-09-13')

for (forecast_date in all_forecast_dates){


  forecasts = read.csv(
    sprintf("%s/%s-%s.csv",folderName,forecast_date,modelName))



  for (fips_loc in forecasted_locations){
    curr_abbrev = fips(fips_loc,to="Abbreviation")
    if (fips_loc == "US"){
      curr_abbrev = "US"
    }
    state_data = read.csv(paste0("../state_hosp_data_2020-11-16/state_",curr_abbrev,".csv"))
    for (j in 1:4){
      for (cat in c("case","death")){
      curr_target = sprintf("%d wk ahead cum %s",j,cat)


      curr_pred = forecasts[(forecasts$target==curr_target)&
                                 (forecasts$location==fips_loc),]

      if (as.Date(curr_pred$target_end_date[1]) <= as.Date("2020-10-19")){



        curr_truth = state_data[as.Date(state_data$date) ==
                                  as.Date(curr_pred$target_end_date[1]),"death"]

        time0truth = state_data[as.Date(state_data$date) ==
                                  as.Date(forecast_date),"death"]

        if (cat == "case"){
          curr_truth = state_data[as.Date(state_data$date) ==
                                    as.Date(curr_pred$target_end_date[1]),"positive"]

          time0truth = state_data[as.Date(state_data$date) ==
                                    as.Date(forecast_date),"positive"]
        }



        curr_pred$truth = curr_truth
        curr_pred$time0truth = time0truth

        submission_scores = rbind(submission_scores,curr_pred)
      }
      }
    }
  }
}

saveName = sprintf("%s/forecasts_with_truth-%s-CTP.csv",folderName,modelName)

write.csv(submission_scores,saveName,row.names = FALSE)

