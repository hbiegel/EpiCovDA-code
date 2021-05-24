# save_all_forecasts_with_truth

# Updated 10/8/20  HRB

library("cdlTools") # package to convert fips to state abbreviations
# setwd("/Users/hannah.biegel/Dropbox/Research-Materials-Hannah/covid_related/EpiCovDA_Forecasts")
setwd("/users/hannah.biegel")
folder_path <- paste0("Dropbox/UA/Research/HRB_COVID_code_PAPER/r_code")
setwd(folder_path)

# folderName = "UA-EpiCovDA-v3-alphaData-tube1-prior-2020-11-09-JHU-PAPER"
# modelName = "UA-EpiCovDA"

folderName = "COVIDhub-ensemble-comp-PR"
modelName = "COVIDhub-ensemble"
# 
# folderName = "UA-EpiCovDA-v3-half-inf-1tube"

# folderName = "UA-EpiCovDA-v3-dataInf-tube"
# modelName = "UA-EpiCovDA"


submission_scores <- data.frame()

forecasts = read.csv(
  sprintf("%s/%s-%s.csv","UA-EpiCovDA-v3-alphaData-tube1-prior-2020-11-16-PAPER","2020-04-26","UA-EpiCovDA"))
forecasted_locations = forecasts[(forecasts$target=="1 wk ahead cum death")&
                                   (forecasts$type=="point"),"location"]


# all_forecast_dates = c("2020-04-12",
#                        # "2020-04-19", # missing 04/19/20 for some reason
#                        "2020-04-26","2020-05-03",
#                        "2020-05-10","2020-05-17","2020-05-24","2020-05-31",
#                        "2020-06-07","2020-06-14","2020-06-21","2020-06-28",
#                        "2020-07-05")

all_forecast_dates =
  c(#"2020-04-12","2020-04-19",
    "2020-04-26","2020-05-03",
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
      for (cat in c("death")){ #c("case","death")){
      curr_target = sprintf("%d wk ahead cum %s",j,cat)
      # curr_pt_pred = forecasts[(forecasts$target==curr_target)&
      #                            (forecasts$type=="point")&
      #                            (forecasts$location==fips_loc),
      #                          c("target_end_date","value")]

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


        # rel_error = (curr_truth - curr_pt_pred$value)/max((curr_truth - time0truth),1)
        # error = curr_truth - curr_pt_pred$value

        # temp_df = data.frame(location = curr_abbrev,target = curr_target,
        #                      predicted_value = curr_pt_pred$value,truth = curr_truth,
        #                      error = error,
        #                      truth_zero = time0truth,
        #                      relative_error = rel_error,
        #                      forecast_date = forecast_date,
        #                      target_end_date = curr_pt_pred$target_end_date[1])

        curr_pred$truth = curr_truth
        curr_pred$time0truth = time0truth

        # submission_scores = rbind(submission_scores,temp_df)
        submission_scores = rbind(submission_scores,curr_pred)
      }
      }
    }
  }
}

saveName = sprintf("%s/forecasts_with_truth-%s-CTP.csv",folderName,modelName)

write.csv(submission_scores,saveName,row.names = FALSE)
























# all_forecast_dates =
#   c("2020-04-12","2020-04-19","2020-04-26","2020-05-03",
#     "2020-05-10","2020-05-17","2020-05-24","2020-05-31",
#     "2020-06-07","2020-06-14","2020-06-21","2020-06-28",
#     "2020-07-05")
# 
# 
# versionName = "v3-full-inf1"
# 
# 
# submission_scores <- data.frame()
# 
# forecasts = read.csv(
#   sprintf("UA-EpiCovDA-%s/%s-UA-EpiCovDA.csv",versionName,
#           "2020-04-12"))
# forecasted_locations = forecasts[(forecasts$target=="1 wk ahead cum death")&
#                                    (forecasts$type=="point"),"location"]
# # 
# # 
# # all_forecast_dates = c("2020-04-12","2020-04-19","2020-04-26","2020-05-03",
# #                        "2020-05-10","2020-05-17","2020-05-24","2020-05-31",
# #                        "2020-06-07","2020-06-14","2020-06-21","2020-06-28",
# #                        "2020-07-05")
# # 
# # for (forecast_date in all_forecast_dates){
# #   
# #   # forecast_date = "2020-05-31"
# #   
# #   forecasts = read.csv(
# #     sprintf("UA-EpiCovDA-%s/%s-UA-EpiCovDA.csv",versionName,
# #             forecast_date))
# #   
# #   
# #   
# #   for (fips_loc in forecasted_locations){
# #     curr_abbrev = fips(fips_loc,to="Abbreviation")
# #     if (fips_loc == "US"){
# #       curr_abbrev = "US"
# #     }
# #     state_data = read.csv(paste0("state_hosp_data/state_",curr_abbrev,".csv"))
# #     for (j in 1:4){
# #       for (cat in c("case","death")){
# #       curr_target = sprintf("%d wk ahead cum %s",j,cat)
# #       # curr_pt_pred = forecasts[(forecasts$target==curr_target)&
# #       #                            (forecasts$type=="point")&
# #       #                            (forecasts$location==fips_loc),
# #       #                          c("target_end_date","value")]
# #       
# #       curr_pred = forecasts[(forecasts$target==curr_target)&
# #                                  (forecasts$location==fips_loc),]
# #       
# #       if (as.Date(curr_pred$target_end_date[1]) <= as.Date("2020-10-04")){
# #         
# #         
# #         
# #         curr_truth = state_data[as.Date(state_data$date) == 
# #                                   as.Date(curr_pred$target_end_date[1]),"death"]
# #         
# #         time0truth = state_data[as.Date(state_data$date) == 
# #                                   as.Date(forecast_date),"death"]
# #         
# #         if (cat == "case"){
# #           curr_truth = state_data[as.Date(state_data$date) == 
# #                                     as.Date(curr_pred$target_end_date[1]),"positive"]
# #           
# #           time0truth = state_data[as.Date(state_data$date) == 
# #                                     as.Date(forecast_date),"positive"]
# #         }
# #         
# #         
# #         # rel_error = (curr_truth - curr_pt_pred$value)/max((curr_truth - time0truth),1)
# #         # error = curr_truth - curr_pt_pred$value
# #         
# #         # temp_df = data.frame(location = curr_abbrev,target = curr_target, 
# #         #                      predicted_value = curr_pt_pred$value,truth = curr_truth,
# #         #                      error = error,
# #         #                      truth_zero = time0truth,
# #         #                      relative_error = rel_error,
# #         #                      forecast_date = forecast_date,
# #         #                      target_end_date = curr_pt_pred$target_end_date[1])
# #         
# #         curr_pred$truth = curr_truth
# #         curr_pred$time0truth = time0truth
# #         
# #         # submission_scores = rbind(submission_scores,temp_df)
# #         submission_scores = rbind(submission_scores,curr_pred)
# #       }
# #       }
# #     }
# #   }
# # }
# # 
# # saveName = sprintf("UA-EpiCovDA-%s/forecasts_with_truth.csv",versionName)
# # 
# # write.csv(submission_scores,saveName,row.names = FALSE)