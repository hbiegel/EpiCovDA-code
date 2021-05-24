% function [ssQ,shift,ssQC] = saveUSQuantileForecasts(state_id,forecast_date,...
%                             all_targets,day_ahead,save_quants)
                        
% Updated 6/19/20       HRB
%                       Replaces "get_US_quantiles_v2"
%                       Cumulative predictions are cumulative only over
%                           forecast period


% % 
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


all_targets ={'DG','G'};

all_states = 1:52;

fig_choices = []; %no figures

quants_wanted = ([1,2.5,5:5:95,97.5,99]/100);

nTar = length(all_targets);
nStates = length(all_states);
state_list = load_state_list();

ndp = 31;

us_quants_C = zeros(length(quants_wanted),ndp);
us_quants_G = zeros(length(quants_wanted),ndp);
us_quants_Gwk = zeros(length(quants_wanted),ndp);


for i = 1:nTar
    
    data_choice = all_targets{i};
    
    for j = 1:nStates
        state_id = state_list{j};
        
        G_quant_name = ['quantile_forecasts/' data_choice '_' state_id ...
        '_' forecast_date '.csv'];
        Gwk_quant_name = ['quantile_forecasts/' data_choice '_wk_' state_id ...
        '_' forecast_date '.csv'];
    
        if strcmp(data_choice,'G')
                   C_quant_name = ['quantile_forecasts/C_' state_id ...
            '_' forecast_date '.csv'] ;
        else
            
        C_quant_name = ['quantile_forecasts/' data_choice(1) 'C_' state_id ...
            '_' forecast_date '.csv'];
        end
        
        Gquants = csvread(G_quant_name);
        Gwkquants = csvread(Gwk_quant_name);
        Cquants = csvread(C_quant_name);
        
        us_quants_C = us_quants_C + Cquants(:,1:ndp);
        us_quants_G = us_quants_G + Gquants(:,1:ndp);
        us_quants_Gwk = us_quants_Gwk + Gwkquants(:,1:ndp);
    end
    
    

         
     G_quant_name_us = ['quantile_forecasts/' data_choice '_US' ...
        '_' forecast_date '.csv'];
     Gwk_quant_name_us = ['quantile_forecasts/' data_choice '_wk_US' ...
        '_' forecast_date '.csv'];
    
    if strcmp(data_choice,'G')
       C_quant_name_us = ['quantile_forecasts/C_US' ...
            '_' forecast_date '.csv'];
    else
        
     C_quant_name_us = ['quantile_forecasts/' data_choice(1) 'C_US' ...
            '_' forecast_date '.csv'];
    end

     csvwrite(G_quant_name_us,us_quants_G);
     csvwrite(C_quant_name_us,us_quants_C);
     csvwrite(Gwk_quant_name_us,us_quants_Gwk);
     

end

end
