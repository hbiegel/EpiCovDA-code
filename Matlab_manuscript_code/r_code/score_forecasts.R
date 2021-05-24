# score forecasts

# Updated 6/24/20     HRB
#                     Load forecast submission and calculate score


forecasts = read.csv("UA-EpiCovDA/2020-05-31-UA-EpiCovDA.csv")
zoltar_truth = read.csv("zoltar-truth-validated.csv")




# add target_end_date column
zoltar_truth$target_end_date = as.Date(zoltar_truth$timezero)
for (j in 1:4){
  curr_wk_ahead = sprintf("%d wk ahead",j)
  
  zoltar_truth[grepl(curr_wk_ahead,zoltar_truth$target),"target_end_date"] = 
    zoltar_truth[grepl(curr_wk_ahead,zoltar_truth$target),"target_end_date"]+(j)*7
}

forecasted_locations = forecasts[(forecasts$target=="1 wk ahead cum death")&
                                   (forecasts$type=="point"),"location"]
end_dates = forecasts[(forecasts$location=="US")&
                        (forecasts$type=="point"),"target_end_date"]

# create data frame to hold scores
scores <- data.frame()

for (loc in forecasted_locations){
  for (dts in end_dates){
    
   
    
  }
}


forecasts[grepl("US",forecasts$location)&
            grepl("2020-06-20",forecasts$target_end_date)&
            grepl("point",forecasts$type),]



