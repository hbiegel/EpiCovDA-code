% Created 5/2/20        HRB
%                       Read in optimal parameters for each state
%                           from JL's code
%                       Currently set to use "optimal" and does 
%                           not incorporate the given range
% Updated 6/21/20       Early states now includes all states that had at
%                           least 1000 cases before April 1st 2020
%                       Previously was approximately subset of first 20
%                           states to have at least 1000 cases
%                       Resolved issues with different orders of states in
%                           the state_parameters file than the 
%                           list_of_states file


function params_out = load_EpiGro_params()


data = csvread('state_parameters_case_counts_4-27.csv',1,1);

% cols:   1,  beta_min	
%         2,  beta_max	
%         3,  beta_opt	
%         4,  gamma_min
%         5,  gamma_max	
%         6,  gamma_opt	
%         7,  R0_min	
%         8,  R0_max	
%         9,  R0_opt	
%         10, N_min	
%         11, N_max	
%         12, N_opt	
%         13, C_inf	
%         14, T_start	
%         15, T_end	

                

% 6/21/20 states with at least 1000 cases before April 1st
%       **verified state numbers against the state_parameters file
% MI,WA,NY,CA,NJ,PA,CT,FL,IL,GA,LA,OH,NC,MA,TN,CO,TX,WI,KY,MD,IN,SC,AZ
early_state_rows = [23,49,35,5,32,10,15,11,...%19,
                    20,44,6,39,7,36,28,...
                    45,50,18,21,16,42,4];
                
rows = early_state_rows;                

betas = data(rows,3);
gammas = data(rows,6);
Ns = data(rows,12);


params_out = [betas, gammas, Ns];



end
