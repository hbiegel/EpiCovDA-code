# COVIDcast EpiData
# Updated 11/11/20

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
# covidcast_signal(data_source = "doctor-visits", signal = "smoothed_cli",
#                  start_day = "2020-05-01", end_day = "2020-05-01",
#                  geo_type = "state", geo_values = "pa", as_of = "2020-05-07")

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

state_list <- read.csv("list_of_states.csv")
state_list_lower <- mutate_all(state_list,.funs=tolower)

for (s_j in 40){ #1:length(state_list_lower$x)){
  curr_state = state_list_lower[s_j,1]
  print(curr_state)
  
  
  for (fd_j in 15:20){ #length(all_forecast_dates)){
    curr_forecast_date = all_forecast_dates[fd_j]
    print(curr_forecast_date)
    sig1 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "confirmed_cumulative_num",
                     start_day = "2020-01-22", end_day = curr_forecast_date,
                     geo_type = "state", geo_values = curr_state, as_of = as.Date("2020-08-30")) )
                     #as.Date(curr_forecast_date)+3))
    
    
    sig2 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "deaths_cumulative_num",
                                              start_day = "2020-01-22", end_day = curr_forecast_date ,
                                              geo_type = "state", geo_values = curr_state, 
                                              as_of = as.Date("2020-08-30")) )
    #as.Date(curr_forecast_date)+3))
    sig3 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "confirmed_incidence_num",
                                              start_day = "2020-01-22", end_day = curr_forecast_date ,
                                              geo_type = "state", geo_values = curr_state, 
                                              as_of = as.Date("2020-08-30")) )
    #as.Date(curr_forecast_date)+3))

    sig4 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "deaths_incidence_num",
                                              start_day = "2020-01-22", end_day = curr_forecast_date ,
                                              geo_type = "state", geo_values = curr_state, 
                                              as_of = as.Date("2020-08-30")) )
    #as.Date(curr_forecast_date)+3))
    # sig6 <- suppressMessages(covidcast_signal(data_source = "hospital-admissions", signal = "smoothed_adj_covid19_from_claims",
    #                                           start_day = "2020-01-01", end_day = curr_forecast_date ,
    #                                           geo_type = "state", geo_values = curr_state, as_of = "2020-05-07"))
    # 
    # sig5 <- sig6
    # sig5$value <- cumsum(sig6$value)

    curr_df <- data.frame(date = sig1$time_value,
                          positive = sig1$value,
                          death = sig2$value,
                          positiveIncrease = sig3$value,
                          deathIncrease = sig4$value
                          )

    curr_filename <- sprintf("state_%s_%s.csv",state_list[s_j,1],curr_forecast_date)

    write.csv(curr_df,curr_filename,row.names = FALSE)
    
  }
}