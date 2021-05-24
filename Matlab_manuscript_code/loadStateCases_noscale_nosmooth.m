function [C,G,state_pop,HC,HG,DC,DG] = loadStateCases_noscale_nosmooth(state_id)


filename = [ 'state_hosp_data_2020-11-16/state_' state_id '.csv'];
popname =  [ 'state_hosp_data_2020-11-16/state_pop' state_id '.csv'];


state_data = csvread(filename,1,1);
state_pop = csvread(popname,1,0);
% state_pop = 1;

state_data = state_data;



casesC = state_data(:,1);
casesG = state_data(:,3);
T = 1:length(casesC);
T_int = 1:.5:T(end);


C = casesC;
G = casesG;

HC = state_data(:,5);
HG = state_data(:,6);

DC = state_data(:,2);
DG = state_data(:,4);


end