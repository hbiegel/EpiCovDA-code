function all_params = get_parameters_for_forecast(K_choices,...
                                            n_samps,state_id,...
                                            forecast_date,fig_on)

% Created 5/27/2020     HRB
%                       Replaces "SIRICC_getForecastParameters"
%                           
%                       Runs VDA with user defined setting and outputs
%                       parameter values for forecast ensemble
%                       
%
%
%
% Input variables:
% K_choices :       vector of integers
%                   each entry in K_choices denotes a number of data points 
%                       ("observations") to be used to fit parameters
% n_samps  :        integer > 0     
%                   number of samples to be used per entry in K_choices
% state_id :        abbreviation of state currently being forecasted
% focecast_date :   string in form 'YYYY-mm-dd' 
%                   date of last observation used for forecasts
% fig_on :          (optional) boolean or value 0,1
%                   if fig_on == 1 (or true), forecasts are plotted in ICC plane (C,G)
%                   if fig_on == 0 (or false), ICC plane figure not plotted
%                   Note: Displaying this figure is currently very slow




if nargin < 5
    fig_on = 0;
end

all_params = [];
num_days = 14;
% init_search = findInitialConditions(state_id, forecast_date, num_days)';
% P0 = init_search(1:4); 

P0 = 0;

for k = K_choices
    [ss, last_ob] = get_observation_index(state_id,forecast_date,k);
    K = min(k,last_ob); % max number of observations is number of data points

    curr_k_params = zeros(n_samps,4); % by column: beta, gamma, N 
    
    % get n_samps forecast parameters for each choice of K
    for i = 1:n_samps

        curr_k_params(i,:) = setup_run_VDA_v3(K,ss,state_id,fig_on,forecast_date,P0);
    end

    all_params = [all_params;curr_k_params];
end



