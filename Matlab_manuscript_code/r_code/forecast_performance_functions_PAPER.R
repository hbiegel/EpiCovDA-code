# forecast_performance_functions_PAPER

# Updated 2/22/21
#   Calculate statistics for all forecasts (including CO on 2020-05-10)
#     after 2020-05-01

# Updated 04/11/21
#   Include scoring calculations per 100,000


calculatePerformanceStatisticsByPop <- function(score_df){
  
  score_df = subset(score_df,
                    (as.Date(forecast_date) >= as.Date('2020-05-01')) )
  # score_df = subset(score_df,(location != "US") )
  
  score_df$abs_rel_error = abs(score_df$relative_error)
  
  score_df$forecast_date = as.Date(score_df$forecast_date)
  score_df$target_end_date = as.Date(score_df$target_end_date)
  
  score_df$abs_error = abs(score_df$error)
  
  death_score_statistics <- c(mean_abs_pop(score_df,"error"),
                              median_abs_pop(score_df,"error"),
                              mean_abs_pop(score_df,"relative_error"),
                              median_abs_pop(score_df,"relative_error"),
                              mean_abs_pop(score_df,"error","1 wk ahead cum death"),
                              median_abs_pop(score_df,"error","1 wk ahead cum death"),
                              mean_abs_pop(score_df,"error","2 wk ahead cum death"),
                              median_abs_pop(score_df,"error","2 wk ahead cum death"),
                              mean_abs_pop(score_df,"error","3 wk ahead cum death"),
                              median_abs_pop(score_df,"error","3 wk ahead cum death"),
                              mean_abs_pop(score_df,"error","4 wk ahead cum death"),
                              median_abs_pop(score_df,"error","4 wk ahead cum death"),
                              mean_abs_pop(score_df,"relative_error","1 wk ahead cum death"),
                              median_abs_pop(score_df,"relative_error","1 wk ahead cum death"),
                              mean_abs_pop(score_df,"relative_error","2 wk ahead cum death"),
                              median_abs_pop(score_df,"relative_error","2 wk ahead cum death"),
                              mean_abs_pop(score_df,"relative_error","3 wk ahead cum death"),
                              median_abs_pop(score_df,"relative_error","3 wk ahead cum death"),
                              mean_abs_pop(score_df,"relative_error","4 wk ahead cum death"),
                              median_abs_pop(score_df,"relative_error","4 wk ahead cum death"))
  
  case_score_statistics <- c(mean_abs_pop(score_df,"error",c("1 wk ahead cum case", "2 wk ahead cum case",
                                                         "3 wk ahead cum case","4 wk ahead cum dcase")),
                             median_abs_pop(score_df,"error",c("1 wk ahead cum case", "2 wk ahead cum case",
                                                           "3 wk ahead cum case","4 wk ahead cum dcase")),
                             mean_abs_pop(score_df,"relative_error",c("1 wk ahead cum case", "2 wk ahead cum case",
                                                                  "3 wk ahead cum case","4 wk ahead cum dcase")),
                             median_abs_pop(score_df,"relative_error",c("1 wk ahead cum case", "2 wk ahead cum case",
                                                                    "3 wk ahead cum case","4 wk ahead cum dcase")),
                             mean_abs_pop(score_df,"error","1 wk ahead cum case"),
                             median_abs_pop(score_df,"error","1 wk ahead cum case"),
                             mean_abs_pop(score_df,"error","2 wk ahead cum case"),
                             median_abs_pop(score_df,"error","2 wk ahead cum case"),
                             mean_abs_pop(score_df,"error","3 wk ahead cum case"),
                             median_abs_pop(score_df,"error","3 wk ahead cum case"),
                             mean_abs_pop(score_df,"error","4 wk ahead cum case"),
                             median_abs_pop(score_df,"error","4 wk ahead cum case"),
                             mean_abs_pop(score_df,"relative_error","1 wk ahead cum case"),
                             median_abs_pop(score_df,"relative_error","1 wk ahead cum case"),
                             mean_abs_pop(score_df,"relative_error","2 wk ahead cum case"),
                             median_abs_pop(score_df,"relative_error","2 wk ahead cum case"),
                             mean_abs_pop(score_df,"relative_error","3 wk ahead cum case"),
                             median_abs_pop(score_df,"relative_error","3 wk ahead cum case"),
                             mean_abs_pop(score_df,"relative_error","4 wk ahead cum case"),
                             median_abs_pop(score_df,"relative_error","4 wk ahead cum case"))
  
  return(list(death_stats = death_score_statistics, case_stats = case_score_statistics, scores = score_df))
}






calculatePerformanceStatistics <- function(score_df){
  
  # score_df = score_df[grepl(c("cum death",score_df$target),]
  score_df = subset(score_df,
                       (as.Date(forecast_date) >= as.Date('2020-05-01')) )
  score_df = subset(score_df,(location != "US") )
  
  score_df$abs_rel_error = abs(score_df$relative_error)
  
  score_df$forecast_date = as.Date(score_df$forecast_date)
  score_df$target_end_date = as.Date(score_df$target_end_date)
  
  score_df$abs_error = abs(score_df$error)
  
  death_score_statistics <- c(mean_abs(score_df,"error"),
                     median_abs(score_df,"error"),
                     mean_abs(score_df,"relative_error"),
                     median_abs(score_df,"relative_error"),
                     mean_abs(score_df,"error","1 wk ahead cum death"),
                     median_abs(score_df,"error","1 wk ahead cum death"),
                     mean_abs(score_df,"error","2 wk ahead cum death"),
                     median_abs(score_df,"error","2 wk ahead cum death"),
                     mean_abs(score_df,"error","3 wk ahead cum death"),
                     median_abs(score_df,"error","3 wk ahead cum death"),
                     mean_abs(score_df,"error","4 wk ahead cum death"),
                     median_abs(score_df,"error","4 wk ahead cum death"),
                     mean_abs(score_df,"relative_error","1 wk ahead cum death"),
                     median_abs(score_df,"relative_error","1 wk ahead cum death"),
                     mean_abs(score_df,"relative_error","2 wk ahead cum death"),
                     median_abs(score_df,"relative_error","2 wk ahead cum death"),
                     mean_abs(score_df,"relative_error","3 wk ahead cum death"),
                     median_abs(score_df,"relative_error","3 wk ahead cum death"),
                     mean_abs(score_df,"relative_error","4 wk ahead cum death"),
                     median_abs(score_df,"relative_error","4 wk ahead cum death"))
  
  case_score_statistics <- c(mean_abs(score_df,"error",c("1 wk ahead cum case", "2 wk ahead cum case",
                                                    "3 wk ahead cum case","4 wk ahead cum dcase")),
                        median_abs(score_df,"error",c("1 wk ahead cum case", "2 wk ahead cum case",
                                                      "3 wk ahead cum case","4 wk ahead cum dcase")),
                        mean_abs(score_df,"relative_error",c("1 wk ahead cum case", "2 wk ahead cum case",
                                                             "3 wk ahead cum case","4 wk ahead cum dcase")),
                        median_abs(score_df,"relative_error",c("1 wk ahead cum case", "2 wk ahead cum case",
                                                               "3 wk ahead cum case","4 wk ahead cum dcase")),
                        mean_abs(score_df,"error","1 wk ahead cum case"),
                        median_abs(score_df,"error","1 wk ahead cum case"),
                        mean_abs(score_df,"error","2 wk ahead cum case"),
                        median_abs(score_df,"error","2 wk ahead cum case"),
                        mean_abs(score_df,"error","3 wk ahead cum case"),
                        median_abs(score_df,"error","3 wk ahead cum case"),
                        mean_abs(score_df,"error","4 wk ahead cum case"),
                        median_abs(score_df,"error","4 wk ahead cum case"),
                        mean_abs(score_df,"relative_error","1 wk ahead cum case"),
                        median_abs(score_df,"relative_error","1 wk ahead cum case"),
                        mean_abs(score_df,"relative_error","2 wk ahead cum case"),
                        median_abs(score_df,"relative_error","2 wk ahead cum case"),
                        mean_abs(score_df,"relative_error","3 wk ahead cum case"),
                        median_abs(score_df,"relative_error","3 wk ahead cum case"),
                        mean_abs(score_df,"relative_error","4 wk ahead cum case"),
                        median_abs(score_df,"relative_error","4 wk ahead cum case"))
  
  return(list(death_stats = death_score_statistics, case_stats = case_score_statistics, scores = score_df))
}



plotVersionWkAheadPerformance <- function(df_A,
                                          tar = "1 wk ahead cum death",
                                          val = "abs_rel_error", 
                                          title = "1 wk ahead cum death"){
  require(ggplot2)
  require(scales)
  
  sub_df_A = subset(df_A,target == tar)
  lim_max = 1 #max(sub_df_A[,val])
  lim_min = 0 #min(sub_df_A[,val])
  low_col = "white"
  mid_col = "skyblue"
  high_col = "black"
  
  
  if (val == "relative_error"){
    lim_min = -1
    low_col = "blue"
    mid_col = "white"
    high_col = "forestgreen"
    }
  if ( val == "error" ){
    lim_max = mean(abs(sub_df_A[,val]))
    lim_min = -lim_max
    low_col = "blue"
    mid_col = "white"
    high_col = "forestgreen"
    
  }
  if ( val == "abs_error" ){
    lim_max = mean(abs(sub_df_A[,val]))
    lim_min = 0
    
  }
  
  
  
  ggplot()+
    geom_tile(data = sub_df_A,mapping = 
                aes(forecast_date,location,fill=sub_df_A[,val])) +
    scale_fill_gradient2(low=low_col,mid=mid_col,high=high_col,
                         limits=c(lim_min,lim_max),na.value="firebrick3",
                         midpoint=(lim_min+lim_max)/2)+
    theme_bw()+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    ggtitle(title)+theme(legend.title = element_blank()) 
  
}





mean_abs_pop <- function(df,val,tar = c("1 wk ahead cum death", "2 wk ahead cum death",
                                    "3 wk ahead cum death","4 wk ahead cum death")){
  return(mean(abs(df[df$target %in% tar,val])/df[df$target %in% tar,"population"]*10^5))
  
}


median_abs_pop <- function(df,val,tar = c("1 wk ahead cum death", "2 wk ahead cum death",
                                      "3 wk ahead cum death","4 wk ahead cum death")){
  
  
  return(median(abs(df[df$target %in% tar,val])/df[df$target %in% tar,"population"]*10^5))
  
}



mean_abs <- function(df,val,tar = c("1 wk ahead cum death", "2 wk ahead cum death",
                                    "3 wk ahead cum death","4 wk ahead cum death")){
  return(mean(abs(df[df$target %in% tar,val])))
  
}


median_abs <- function(df,val,tar = c("1 wk ahead cum death", "2 wk ahead cum death",
                                      "3 wk ahead cum death","4 wk ahead cum death")){
  return(median(abs(df[df$target %in% tar,val])))
  
}



plotVersionDifference <- function(df_A,val,tar = "1 wk ahead cum death",title){
  sub_df_A = subset(df_A,target == tar)
  
  
  require(ggplot2)
  require(scales)
  
  sub_df_A = subset(df_A,target == tar)
  lim_max = .75*max(sub_df_A[,val])
  lim_min = .75*min(sub_df_A[,val])
  # low_col = "white"
  # mid_col = "skyblue"
  # high_col = "black"
  
  low_col = "blue"
  mid_col = "white"
  high_col = "forestgreen"
  
  
  
  
  
  ggplot()+
    geom_tile(data = sub_df_A,mapping = 
                aes(forecast_date,location,fill=sub_df_A[,val])) +
    scale_fill_gradient2(low=low_col,mid=mid_col,high=high_col,
                         limits=c(lim_min,lim_max),na.value="firebrick3",
                         midpoint=0)+
    theme_bw()+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    ggtitle(title)+theme(legend.title = element_blank()) 
  
}
  
  


