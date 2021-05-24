# download covidtracking.com data

# Udpated 05/24/21 HRB

library("envDocument") # package to find current path
require("httr")
require("jsonlite")

# Set working directory to current location of this file
current_path_with_file <- getScriptPath()
current_path <- substr(current_path_with_file,1,nchar(current_path_with_file)-nchar("/r_code/update_main_data.R"))
setwd(current_path)


res = GET("https://covidtracking.com/api/v1/states/daily.json")
curr_state_data = fromJSON(rawToChar(res$content))

curr_state_data$date <- as.Date(as.character(curr_state_data$date),format="%Y%m%d")

state_abbr = read.csv("list_of_states.csv")
state_abbr = state_abbr$x
state_num_days <- c()


for (i in 1:length(state_abbr)){
  temp_sub = subset(curr_state_data,state==state_abbr[i])
  temp_sub = temp_sub[order(temp_sub$date),]
  
  temp_save <- subset(temp_sub,select=c("date","positive",
                                        "death",
                                        "positiveIncrease","deathIncrease",
                                        "hospitalized","hospitalizedIncrease","hospitalizedCurrently"))
  
  temp_save <- temp_save[order(temp_save$date),]
  
  temp_save[is.na(temp_save)] <- 0;
  
  # temp_save = temp_save[as.Date(temp_save$date)< as.Date('2020-04-01'),]
  
  temp_name <- paste("updated_state_data/state_",state_abbr[i],".csv",sep="")
  
  write.csv(temp_save,temp_name,row.names=FALSE)
  
}



## save new national data
res_nat = GET("https://covidtracking.com/api/v1/us/daily.json")
curr_nat_data = fromJSON(rawToChar(res_nat$content))
curr_nat_data$date <- as.Date(as.character(curr_nat_data$date),format="%Y%m%d")
curr_nat <- curr_nat_data[order(curr_nat_data$date),]
save_nat_df <- subset(curr_nat,select=c("date","positive",
                                     "death",
                                     "positiveIncrease","deathIncrease",                                                    "hospitalized",
                                     "hospitalizedIncrease",
                                     "hospitalizedCurrently"))
save_nat_df[is.na(save_nat_df)] <- 0;

# save_nat_df = save_nat_df[as.Date(save_nat_df$date)< as.Date('2020-04-01'),] 

temp_name_nat <- paste("updated_state_data/state_US.csv",sep="")

write.csv(save_nat_df,temp_name_nat,row.names=FALSE)



