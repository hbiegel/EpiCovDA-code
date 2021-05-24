# COVIDcast EpiData
# Updated 01/12/21

# download data updated as of 2021-01-10

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

setwd("~/Dropbox/UA/Research/HRB_COVID_code_v3-withPriorPerturbation-JHU/r_code/JHU-2021-01-10")

# # Example of downloading data
# covidcast_signal(data_source = "doctor-visits", signal = "smoothed_cli",
#                  start_day = "2020-05-01", end_day = "2020-05-01",
#                  geo_type = "state", geo_values = "pa", as_of = "2020-05-07")

# JHU Signals can be found here:
# https://cmu-delphi.github.io/delphi-epidata/api/covidcast-signals/jhu-csse.html




state_list <- read.csv("list_of_states.csv")
state_list_lower <- mutate_all(state_list,.funs=tolower)

for (s_j in 2:length(state_list_lower$x)){
  curr_state = state_list_lower[s_j,1]
  print(curr_state)
  

    sig1 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "confirmed_cumulative_num",
                     start_day = "2020-01-22", end_day = "2020-12-31",
                     geo_type = "state", geo_values = curr_state, as_of = as.Date("2021-01-10")) )
                     #as.Date(curr_forecast_date)+3))
    print("sig1")
    
    sig2 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "deaths_cumulative_num",
                                              start_day = "2020-01-22", end_day = "2020-12-31",
                                              geo_type = "state", geo_values = curr_state, 
                                              as_of = as.Date("2021-01-10")) )
    #as.Date(curr_forecast_date)+3))
    
    print("sig2")
    sig3 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "confirmed_incidence_num",
                                              start_day = "2020-01-22", end_day = "2020-12-31",
                                              geo_type = "state", geo_values = curr_state, 
                                              as_of = as.Date("2021-01-10")) )
    #as.Date(curr_forecast_date)+3))
  print("sig3")
    sig4 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "deaths_incidence_num",
                                              start_day = "2020-01-22", end_day = "2020-12-31",
                                              geo_type = "state", geo_values = curr_state, 
                                              as_of = as.Date("2021-01-10")) )
    #as.Date(curr_forecast_date)+3))
    
    print("sig4")
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

    curr_filename <- sprintf("state_%s_2021-01-10.csv",state_list[s_j,1])

    write.csv(curr_df,curr_filename,row.names = FALSE)
    
  
}