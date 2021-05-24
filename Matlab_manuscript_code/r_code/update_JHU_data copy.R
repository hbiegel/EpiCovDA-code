# update JHU data

require("openintro")
require("curl")
library("envDocument")


# Set working directory to current location of this file
current_path_with_file <- getScriptPath()
current_path <- substr(current_path_with_file,1,nchar(current_path_with_file)-nchar("/r_code/update_JHU_data.R"))
setwd(current_path)
# https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports

setwd("/Users/hannah.biegel")
JHU_path <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports_us"

all_file_names <- c( "04-12-2020.csv", "04-13-2020.csv", "04-14-2020.csv",
                     "04-15-2020.csv", "04-16-2020.csv", "04-17-2020.csv",
                     "04-18-2020.csv", "04-19-2020.csv", "04-20-2020.csv",
                     "04-21-2020.csv", "04-22-2020.csv", "04-23-2020.csv",
                     "04-24-2020.csv", "04-25-2020.csv", "04-26-2020.csv",
                     "04-27-2020.csv", "04-28-2020.csv", "04-29-2020.csv",
                     "04-30-2020.csv", "05-01-2020.csv", "05-02-2020.csv",
                     "05-03-2020.csv", "05-04-2020.csv", "05-05-2020.csv",
                     "05-06-2020.csv", "05-07-2020.csv", "05-08-2020.csv",
                     "05-09-2020.csv", "05-10-2020.csv", "05-11-2020.csv",
                     "05-12-2020.csv", "05-13-2020.csv", "05-14-2020.csv",
                     "05-15-2020.csv", "05-16-2020.csv", "05-17-2020.csv",
                     "05-18-2020.csv", "05-19-2020.csv", "05-20-2020.csv",
                     "05-21-2020.csv", "05-22-2020.csv", "05-23-2020.csv",
                     "05-24-2020.csv", "05-25-2020.csv", "05-26-2020.csv",
                     "05-27-2020.csv", "05-28-2020.csv", "05-29-2020.csv",
                     "05-30-2020.csv", "05-31-2020.csv", "06-01-2020.csv",
                     "06-02-2020.csv", "06-03-2020.csv", "06-04-2020.csv",
                     "06-05-2020.csv", "06-06-2020.csv", "06-07-2020.csv",
                     "06-08-2020.csv", "06-09-2020.csv", "06-10-2020.csv",
                     "06-11-2020.csv", "06-12-2020.csv", "06-13-2020.csv",
                     "06-14-2020.csv", "06-15-2020.csv", "06-16-2020.csv",
                     "06-17-2020.csv", "06-18-2020.csv", "06-19-2020.csv",
                     "06-20-2020.csv", "06-21-2020.csv", "06-22-2020.csv",
                     "06-23-2020.csv", "06-24-2020.csv", "06-25-2020.csv",
                     "06-26-2020.csv", "06-27-2020.csv", "06-28-2020.csv",
                     "06-29-2020.csv", "06-30-2020.csv", "07-01-2020.csv",
                     "07-02-2020.csv", "07-03-2020.csv", "07-04-2020.csv",
                     "07-05-2020.csv", "07-06-2020.csv", "07-07-2020.csv",
                     "07-08-2020.csv", "07-09-2020.csv", "07-10-2020.csv",
                     "07-11-2020.csv", "07-12-2020.csv", "07-13-2020.csv",
                     "07-14-2020.csv", "07-15-2020.csv", "07-16-2020.csv",
                     "07-17-2020.csv", "07-18-2020.csv", "07-19-2020.csv",
                     "07-20-2020.csv", "07-21-2020.csv", "07-22-2020.csv",
                     "07-23-2020.csv", "07-24-2020.csv", "07-25-2020.csv",
                     "07-26-2020.csv")

num_days = length(all_file_names)

all_fips = c(1,2,4:6,8:13,15:42,44:51,53:56)

for (state_fips in all_fips){
  state_JHU_df <- data.frame()
  
  for (i in 1:num_days){
    curr_filename <- all_file_names[i]
    day <- as.Date(substr(curr_filename,1,10),format="%m-%d-%Y")
    
    
    
    
    currJHUdata <- read.csv(curl(paste0(JHU_path,"/",curr_filename)))
    
    tempJHU <- subset(currJHUdata,FIPS == state_fips,
                      select = c(Province_State,Confirmed,Deaths,
                                 People_Hospitalized))
    tempJHU <- cbind(day,tempJHU)
    state_JHU_df <- rbind(state_JHU_df,tempJHU)
    
    
  }
  
  state_JHU_df$positiveIncrease <- 0;
  state_JHU_df$positiveIncrease[-1] <- state_JHU_df$Confirmed[-1] -
    state_JHU_df$Confirmed[-num_days]
  
  
  state_JHU_df$deathIncrease <- 0;
  state_JHU_df$deathIncrease[-1] <- state_JHU_df$Deaths[-1] -
    state_JHU_df$Deaths[-num_days]
  
  
  state_JHU_df$hospitalizedIncrease <- 0;
  state_JHU_df$hospitalizedIncrease[-1] <- state_JHU_df$People_Hospitalized[-1] -
    state_JHU_df$People_Hospitalized[-num_days]
  
  names(state_JHU_df) <- c("date","state","positive","death","hospitalized",
                           "positiveIncrease","deathIncrease",
                           "hospitalizedIncrease")
  
  curr_abbrev <- state2abbr(state_JHU_df$state[1])
  state_JHU_df <- state_JHU_df[-1,c("date","positive","death",
                                    "positiveIncrease","deathIncrease",
                                    "hospitalized","hospitalizedIncrease")]
  
  
  JHU_save_name <- 
    sprintf("updated_state_data/JHU_state_%s.csv",
                           curr_abbrev)
  write.csv(state_JHU_df,JHU_save_name,row.names=FALSE)
  
  
  
}


