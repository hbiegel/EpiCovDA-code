# check_API_download

# Updated 11/30/20

# COVIDcast EpiData
# Updated 11/11/20



setwd("~/Dropbox/Research-Materials-Hannah/covid_related/COVIDcast_epidata")

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

for (s_j in 1:length(state_list_lower$x)){
  curr_state = state_list_lower[s_j,1]

  
  
  for (fd_j in 1:length(all_forecast_dates)){
    curr_forecast_date = all_forecast_dates[fd_j]

 
    curr_avail_dates <- as.Date(as.Date("2020-01-22"):as.Date(curr_forecast_date),format=
                                  +             "%Y-%mm-%dd",origin=as.Date("1970-01-01"))
    
    
    curr_filename <- sprintf("state_%s_%s.csv",state_list[s_j,1],curr_forecast_date)
    
    curr_file <- read.csv(curr_filename)
    
    # curr_522 <- curr_file[curr_file$date=="2020-05-22",]
    # curr_520 <- curr_file[curr_file$date=="2020-05-20",]
    # 
    # temp_pos521 = curr_522$positive - curr_522$positiveIncrease
    # temp_death521 = curr_522$death - curr_522$deathIncrease
    # temp_posInc521 = temp_pos521 - curr_520$positive
    # temp_deathInc521 = temp_death521 - curr_520$death
    # 
    # tempdf <- data.frame(date = "2020-05-21", positive = temp_pos521, 
    #                      death = temp_death521, 
    #                      positiveIncrease =  temp_posInc521,
    #                      deathIncrease = temp_deathInc521)
    # 
    # 
    # curr_file <- rbind(subset(curr_file,as.Date(date)<as.Date("2020-05-21")),
    #                    tempdf,
    #                    subset(curr_file,as.Date(date)>as.Date("2020-05-21")))
    # 
    # write.csv(curr_file,curr_filename,row.names = FALSE)

    missing_dates <- curr_avail_dates[!(curr_avail_dates %in% as.Date(curr_file$date))]
    if(length(missing_dates>0)){
      print(paste("from", curr_state,",", curr_forecast_date, "missing:"))
    print(missing_dates)}
  }
}