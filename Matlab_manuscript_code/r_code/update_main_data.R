# download covidtracking.com data
setwd("/users/hannah.biegel")
folder_path <- paste0("Dropbox/Research-Materials-Hannah/covid_related/HRB_COVID_code")
setwd(folder_path)


require("httr")
require("jsonlite")

res = GET("https://covidtracking.com/api/v1/states/daily.json")
curr_state_data = fromJSON(rawToChar(res$content))

curr_state_data$date <- as.Date(as.character(curr_state_data$date),format="%Y%m%d")

state_abbr = read.csv("state_hosp_data/list_of_states.csv")
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
  
  # temp_save[is.na(temp_save)] <- 0;
  
  temp_save = temp_save[as.Date(temp_save$date)< as.Date('2020-04-01'),]
  
  # temp_name <- paste("state_hosp_data/state_",state_abbr[i],".csv",sep="")
  temp_name <- paste("state_data_early/state_",state_abbr[i],".csv",sep="")
  
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

save_nat_df = save_nat_df[as.Date(save_nat_df$date)< as.Date('2020-04-01'),] 

# temp_name_nat <- paste("state_hosp_data/state_US.csv",sep="")
temp_name_nat <- paste("state_data_early/state_US.csv",sep="")

write.csv(save_nat_df,temp_name_nat,row.names=FALSE)



