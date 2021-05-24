# COVIDcast EpiData National Level
# Updated 12/30/20


# Download notes:
# Daily data available back through 1/22/20 
# HOWEVER the first posting of these data was 5/7/20

# "2020-05-10","2020-05-17" <- data posted 2 days later
# "2020-05-24","2020-05-31" <- data posted 3 days later (missing 5/21)

# data posted 2 days later
# "2020-06-07","2020-06-14", "2020-06-21", "2020-06-28" 
# "2020-07-05", '2020-07-12', '2020-07-19'


# # To install with vignettes:
# devtools::install_github("cmu-delphi/covidcast", ref = "main",
#                          subdir = "R-packages/covidcast",
#                          build_vignettes = TRUE,
#                          dependencies = TRUE)

# # To install without vignettes:
# devtools::install_github("cmu-delphi/covidcast", ref = "main",
#                          subdir = "R-packages/covidcast")

library(covidcast)
library(dplyr)

setwd("~/Dropbox/Research-Materials-Hannah/covid_related/COVIDcast_epidata")

# # Example of downloading data
# test <- covidcast_signal(data_source = "jhu-csse", signal = "confirmed_incidence_num",
#                  start_day = "2020-04-12", end_day = "2020-04-12",
#                  geo_type = "state", geo_values ="al", as_of = "2020-05-07")

# JHU Signals can be found here:
# https://cmu-delphi.github.io/delphi-epidata/api/covidcast-signals/jhu-csse.html






all_forecast_dates =
  c("2020-04-12","2020-04-19","2020-04-26","2020-05-03",
    "2020-05-10","2020-05-17","2020-05-24","2020-05-31",
    "2020-06-07","2020-06-14","2020-06-21","2020-06-28",
    "2020-07-05",'2020-07-12','2020-07-19',
    '2020-07-26','2020-08-02','2020-08-09',
    '2020-08-16','2020-08-23','2020-08-30',
    '2020-09-06','2020-09-13')

# state_list <- read.csv("list_of_states.csv")
# state_list_lower <- mutate_all(state_list,.funs=tolower)

# for (s_j in 40){ #1:length(state_list_lower$x)){
  curr_state = "US" #state_list_lower[s_j,1]
  print(curr_state)
  
  
  for (fd_j in 18:23){#5:20){ #length(all_forecast_dates)){
    curr_forecast_date = all_forecast_dates[fd_j]
    print(curr_forecast_date)
    sig1 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "confirmed_cumulative_num",
                                              start_day = "2020-01-22", end_day = curr_forecast_date,
                                              geo_type = "state", as_of = as.Date(curr_forecast_date)+2) )
    sig1_us = aggregate(sig1$value, by=list(time_value=sig1$time_value), FUN=sum)

    
    
    sig2 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "deaths_cumulative_num",
                                              start_day = "2020-01-22", end_day = curr_forecast_date ,
                                              geo_type = "state", 
                                              as_of = as.Date(curr_forecast_date)+2) )
    sig2_us = aggregate(sig2$value, by=list(time_value=sig2$time_value), FUN=sum)
    

    sig3 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "confirmed_incidence_num",
                                              start_day = "2020-01-22", end_day = curr_forecast_date ,
                                              geo_type = "state",
                                              as_of = as.Date(curr_forecast_date)+2) )
    sig3_us = aggregate(sig3$value, by=list(time_value=sig3$time_value), FUN=sum)
    
    sig4 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "deaths_incidence_num",
                                              start_day = "2020-01-22", end_day = curr_forecast_date ,
                                              geo_type = "state", 
                                              as_of = as.Date(curr_forecast_date)+2) )
    
    sig4_us = aggregate(sig4$value, by=list(time_value=sig4$time_value), FUN=sum)

    
    curr_df <- data.frame(date = sig1_us$time_value,
                          positive = sig1_us$x,
                          death = sig2_us$x,
                          positiveIncrease = sig3_us$x,
                          deathIncrease = sig4_us$x
    )
    
    curr_filename <- sprintf("state_%s_%s.csv","US",curr_forecast_date)
    
    write.csv(curr_df,curr_filename,row.names = FALSE)
    
  }
# }