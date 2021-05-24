# COVIDcast EpiData National Level
# Updated 1/12/21

# download data as of 2021-01-10


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

setwd("~/Dropbox/UA/Research/HRB_COVID_code_v3-withPriorPerturbation-JHU/r_code/JHU-2021-01-10")

# # Example of downloading data
# test <- covidcast_signal(data_source = "jhu-csse", signal = "confirmed_incidence_num",
#                  start_day = "2020-04-12", end_day = "2020-04-12",
#                  geo_type = "state", geo_values ="al", as_of = "2020-05-07")

# JHU Signals can be found here:
# https://cmu-delphi.github.io/delphi-epidata/api/covidcast-signals/jhu-csse.html







  curr_state = "US" #state_list_lower[s_j,1]
  print(curr_state)
  
  

    sig1 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "confirmed_cumulative_num",
                                              start_day = "2020-01-22", end_day = "2020-12-31",
                                              geo_type = "state", as_of = as.Date("2021-01-10")) )
    sig1_us = aggregate(sig1$value, by=list(time_value=sig1$time_value), FUN=sum)

    
    
    sig2 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "deaths_cumulative_num",
                                              start_day = "2020-01-22", end_day = "2020-12-31",
                                              geo_type = "state", 
                                              as_of = as.Date("2021-01-10")) )
    sig2_us = aggregate(sig2$value, by=list(time_value=sig2$time_value), FUN=sum)
    

    sig3 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "confirmed_incidence_num",
                                              start_day = "2020-01-22", end_day = "2020-12-31" ,
                                              geo_type = "state",
                                              as_of = as.Date("2021-01-10")) )
    sig3_us = aggregate(sig3$value, by=list(time_value=sig3$time_value), FUN=sum)
    
    sig4 <- suppressMessages(covidcast_signal(data_source = "jhu-csse", signal = "deaths_incidence_num",
                                              start_day = "2020-01-22", end_day = "2020-12-31" ,
                                              geo_type = "state", 
                                              as_of = as.Date("2021-01-10")) )
    
    sig4_us = aggregate(sig4$value, by=list(time_value=sig4$time_value), FUN=sum)

    
    curr_df <- data.frame(date = sig1_us$time_value,
                          positive = sig1_us$x,
                          death = sig2_us$x,
                          positiveIncrease = sig3_us$x,
                          deathIncrease = sig4_us$x
    )
    
    curr_filename <- sprintf("state_%s.csv","US")
    
    write.csv(curr_df,curr_filename,row.names = FALSE)
    
