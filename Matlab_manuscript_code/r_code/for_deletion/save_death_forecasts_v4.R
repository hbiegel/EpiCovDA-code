# save_death_forecasts_v4

## Updated 7/05/20
# Save SIRICC forecasts version 2.0
# Update to follow new submission guidelines

setwd("/Users/hannah.biegel/Dropbox/Research-Materials-Hannah/covid_related/HRB_COVID_code/r_code")




library(R.matlab)
# library(zoo)
library("cdlTools")


state_list <- read.csv("../state_hosp_data/list_of_states.csv")
# state_num_days <- read.csv("../state_hosp_data/list_of_num_days.csv")
# state_num_days[53,1] <- 145 #138 #131 # 122, 117
all_states <- c(1:39,41:53)



all_data_choices = c('DC','DG')
forecast_date <- '2020-07-26'  #YYYY-MM-DD
next_sat <- as.Date('2020-08-01') # 1 wk ahead forecast date
next_sat_ind <- 6
tarType <- c("%d day ahead cum death","%d day ahead inc death")
tarTypeCum <- c("%d wk ahead cum death","%d wk ahead inc death")


quants_wanted <- c(0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99);

submit_df <- data.frame()
for (st in all_states){
  state_id <- state_list[st,1]
  state_id_fips = fips(state_id)
  
  if (st == 53){
    state_id_fips = "US"
  }
  
  if (state_id_fips < 10){
    state_id_fips = paste0("0",state_id_fips)
  }
  
  print(state_id_fips)
  
  
  last_day = state_num_days[st,1] 
  
  for (k in 1:2){
    data_choice <- all_data_choices[k]
    curr_tar_type<- tarType[k]
    curr_tar_typeCum<- tarTypeCum[k]
    forecastfile = sprintf('../quantile_forecasts/%s_%s_%s.csv',
                           data_choice,state_id,forecast_date)
    
    
    temp_df<- read.csv("../state_hosp_data/JHU_state_us.csv")
    temp_df$date <- as.Date(temp_df$date)
    current_deaths = 	146935 #temp_df[temp_df$date==(as.Date(forecast_date)),"death"]
    
    if (st < 53){
      JHU_state_file = sprintf('../state_hosp_data/JHU_state_%s.csv',state_id)
      curr_JHU <- read.csv(JHU_state_file)
      curr_JHU$date <- as.Date(curr_JHU$date)
      current_deaths = curr_JHU[curr_JHU$date==(as.Date(forecast_date)),"death"]
      # NN = length(curr_JHU$death)
      # current_deaths = curr_JHU$death[NN]
      # current_deaths
    }
    
    update_term = current_deaths
    
    if (data_choice == 'DG'){
      update_term = 0
    }
    
    
    day_ahead_quants = read.csv(forecastfile,header=FALSE)
    ndp = length(day_ahead_quants[1,])
    # 
    # for (i in 1:ndp){
    #   
    #   target <- sprintf(curr_tar_type,i)
    #   value <- day_ahead_quants[,i] + update_term
    #   
    #   curr_df <- data.frame(value)
    #   curr_df$target <- target
    #   curr_df$location <- as.character(state_id_fips)
    #   curr_df$location_name <- state_id
    #   curr_df$type <- "quantile"
    #   curr_df$quantile <- quants_wanted
    #   curr_df$target_end_date <- as.Date(forecast_date)+i
    #   curr_df$forecast_date <- forecast_date
    #   
    #   curr_df <- curr_df[,c("forecast_date","target","target_end_date",
    #                         "location","location_name",
    #                         "type","quantile","value")]
    #   
    #   point_df <- data.frame()
    #   point_df <- curr_df[1,]
    #   point_df$type <- "point"
    #   point_df$value <- curr_df$value[12] #median
    #   point_df$quantile <- NA
    #   
    #   
    #   submit_df <- rbind(submit_df,point_df,curr_df)
    #   
    # }
    
    # wk ahead forecasts
    for (j in 0:3){
      
      target <- sprintf(curr_tar_typeCum,j+1)
      value <- day_ahead_quants[,next_sat_ind+7*j] + update_term
      
      if (k == 2){
        forecastfile2 = sprintf('../quantile_forecasts/%s_wk_%s_%s.csv',
                                data_choice,state_id,forecast_date)
        wk_ahead_quants = read.csv(forecastfile2,header=FALSE)
        value <- wk_ahead_quants[,next_sat_ind+7*j]
      }
      
      curr_df <- data.frame(value)
      curr_df$target <- target
      curr_df$location <- as.character(state_id_fips)
      # curr_df$location_name <- state_id
      curr_df$type <- "quantile"
      curr_df$quantile <- quants_wanted
      curr_df$target_end_date <- next_sat+7*(j)
      curr_df$forecast_date <- forecast_date
      
      curr_df <- curr_df[,c("forecast_date","target","target_end_date",
                            "location",
                            "type","quantile","value")]
      
      point_df <- data.frame()
      point_df <- curr_df[1,]
      point_df$type <- "point"
      point_df$value <- curr_df$value[12] #median
      point_df$quantile <- NA
      
      
      submit_df <- rbind(submit_df,point_df,curr_df)
      
      
    }
    
    
    
    
  }
}
filename = sprintf("UA-EpiCovDA-test/%s-UA-EpiCovDA.csv",forecast_date)
write.csv(submit_df,filename,row.names=FALSE)

source("code/validation/functions_plausibility.R")
rt <- validate_file(filename)


comp_name <- sprintf("../state_hosp_data/JHU_state_%s.csv",state_list[all_states[length(all_states)],1])

compare_df = read.csv(comp_name)
compare_df$date <- as.Date(compare_df$date,format = "%Y-%m-%d")

require(ggplot2)

submit_cuml <- submit_df[grepl("cum",submit_df$target),,drop=FALSE]

submit_inc <- submit_df[grepl("inc",submit_df$target),,drop=FALSE]



ggplot(data=submit_cuml)+
  geom_point(mapping=aes(target_end_date,value,
                         group=target,color=as.character(quantile)))+
  # scale_color_hue(l=40, c=35)+
  theme(legend.position ="none")+
  geom_line(data=compare_df,mapping=aes(date,death)) 


ggplot(data=submit_inc)+
  geom_point(mapping=aes(target_end_date,value,
                         group=target,color=as.character(quantile)))+
  # scale_color_hue(l=40, c=35)+
  theme(legend.position ="none")+
  geom_line(data=compare_df,mapping=aes(date,deathIncrease))

