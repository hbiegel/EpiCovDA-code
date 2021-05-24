function var_inf = forecastVarianceInflation(state_id,forecast_date,data_choice)

[C,G,state_pop,HC,HG,DC,DG] = loadStateCases_noscale_v2(state_id, forecast_date);

[rawC,rawG,~,rawHC,rawHG,rawDC,rawDG] = loadStateCases_noscale_nosmooth(state_id);

[~, last_ob, date_array] = get_observation_index(state_id,...
                                forecast_date,5);


maxWindow = 10;
if strcmp(data_choice,'DG') || strcmp(data_choice,'DC') 
    data = [DG, rawDG];
else
    data = [G, rawG];
end

diff = data(last_ob - maxWindow: last_ob, 1) - data(last_ob - maxWindow: last_ob, 2);

var_inf = (std(diff))^2;                            
                            


end
