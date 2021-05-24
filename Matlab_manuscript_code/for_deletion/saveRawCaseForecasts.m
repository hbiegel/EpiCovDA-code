function saveRawCaseForecasts(state_id,forecast_date,day_ahead_forecasts)
% Updated 6/3/2020       Save case count forecasts to forecast_raw file


file_save_as = ['forecast_raw/SIRICC_' state_id '_' ...
                forecast_date '.mat'];

data = day_ahead_forecasts;

save(file_save_as,'data')
