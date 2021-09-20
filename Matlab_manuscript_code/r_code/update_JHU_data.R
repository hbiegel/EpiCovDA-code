# "update JHU data"
# Updated 9/19/21 Hannah Biegel



library("openintro")
library("curl")
library("envDocument")


# Set working directory to current location of this file
# current_path_with_file <- getScriptPath()
# current_path <- substr(current_path_with_file,1,nchar(current_path_with_file)-nchar("/r_code/update_JHU_data.R"))
# setwd(current_path)
# https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports


print("The working directory is:")
print(getwd())



JHU_path <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports_us"


yesterday <- as.Date(format(Sys.time(),"%m-%d-%Y"),"%m-%d-%Y")-1

all_file_names <- as.Date("04-12-2020","%m-%d-%Y"):yesterday


num_days = length(all_file_names)

all_fips = c(1,2,4:6,8:13,15:42,44:51,53:56)


all_JHU <- data.frame()
for (i in 1:num_days){
  curr_filename <- all_file_names[i]
  day <- as.Date(all_file_names[i],origin="1970-01-01")

  curr_filename_format <- format(day,"%m-%d-%Y")

  currJHUdata <- read.csv(curl(paste0(JHU_path,"/",curr_filename_format, '.csv')))


  currJHUdata <- cbind(day,currJHUdata)

  currJHUdata <- currJHUdata[,c("day", "FIPS", "Province_State","Confirmed",
                                 "Deaths","People_Hospitalized")]

  all_JHU <- rbind(all_JHU,currJHUdata)


}









for (state_fips in all_fips){

  state_JHU_df <- subset(all_JHU,FIPS == state_fips,
                    select = c(day, Province_State,Confirmed,Deaths,
                               People_Hospitalized))



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

  state_JHU_df[is.na(state_JHU_df)] <- 0;

  JHU_save_name <-
    sprintf("../updated_state_data/JHU_state_%s.csv",
                           curr_abbrev)
  write.csv(state_JHU_df,JHU_save_name,row.names=FALSE)



}


