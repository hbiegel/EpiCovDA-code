%% mainEpiCovDA

% Created 5/26/20       HRB      
%                       Main control for EpiCovDA model
%                       Run and save COVID-19 daily forecasts for US states 
%                           and US national
% Updated 5/28/20       Replace "last_day" with "forecast_date" when saving
% Updated 6/7/20        For quantiles, cumulative forecast ensemble is 
%                           cumulative sum of incidence ensemble after 
%                           augmenting with samples from normal distribution
% Updated 7/14/20       Updated smoothing when loading data so that data
%                           isn't smoothed using data beyond "forecast_date"
% Updated 8/4/20        Added Cstart to be fit with other parameters,
%                           all_params is now n x 4 (instead of n x 3)


tic

%% Define general setting for forecasting
K_choices = [3,5,14]; % number of observations to fit forecasts
n_samps = 50; % ensemble members per choice of K
save_raw = false; % save day ahead forecast ensemble?
t_G_fig = false; % plot forecast ensemble against data in time incidence plane
fc_fig = false; % compare cumulative forecast to truth 
save_quants = true; % save quantiles to csv in "quantile_forecasts" folder
save_params = true; % save parameter values to csv in "forecast_parameters"


%% Choose state
state_list = load_state_list(); % cell array of US state abbreviations
state_numS = 1;



for state_num = state_numS  %19,25

state_id = state_list{state_num};


% all_forecast_dates = {'2020-05-03','2020-05-10','2020-05-17',...
%                       '2020-05-24','2020-05-31','2020-06-07',...
%                       '2020-06-14','2020-06-21','2020-06-28',...
%                       '2020-07-05','2020-07-12','2020-07-19',...
%                       '2020-07-26','2020-08-02','2020-08-09',...
%                       '2020-08-16','2020-08-23','2020-08-30',...
%                       '2020-09-06','2020-09-13'};

 all_forecast_dates = {'2020-05-03'};                 
                  
num_weeks = length(all_forecast_dates);

for wk_ind = 1:num_weeks



% Last day of data (inclusive)
forecast_date = all_forecast_dates{wk_ind};


%% Get parameters for forecast ensemble
all_params = get_parameters_for_forecast(K_choices,n_samps,state_id,...
                    forecast_date,0);

if save_params
    p_filename = ['forecast_parameters/params_' state_id '_'...
                    forecast_date '.csv'];
    
    dlmwrite(p_filename, all_params, 'delimiter', ',', 'precision', 10);
end

                                                
%% Save and plot forecast ensemble
[ss,last_day] = get_observation_index(state_id,forecast_date,K_choices(end));

[day_ahead, all_errors] = run_plot_forecasts_v3(all_params,K_choices,ss,...
                                    state_id,n_samps,...
                                    forecast_date,...
                                    t_G_fig,fc_fig);
%              
%% Save forecasts for cases              
if save_raw
     saveRawCaseForecasts(state_id,forecast_date,day_ahead)
end


%% Save quantile forecasts for target of choice
% Options:  
%           "DG" - incidence, deaths
%           "HG" - incidence, hospitalizations
%           "G" - incidence, cases


targetsToSave = {'G','DG'};

% Quants is a 23 x ndp matrix, where each column corresponds all the 
% quantiles for a single day predicted
[quants,shift,quantsC] = saveStateQuantileForecasts(state_id,forecast_date,last_day,...
                targetsToSave,day_ahead,save_quants);




%% Optional: Plot quantiles against any available data


plotQuantilesWithTruth(state_id,last_day,forecast_date,shift,'G')
plotQuantilesWithTruth(state_id,last_day,forecast_date,shift,'DG')
% plotQuantilesWithTruth(state_id,last_day,forecast_date,shift,'C')
% plotQuantilesWithTruth(state_id,last_day,forecast_date,shift,'DC')


%% Optional: Plot quantiles in ICC plane
% plotICCpresentation_v2(state_id, last_day, K_choices, forecast_date, 'G')
end

end
toc