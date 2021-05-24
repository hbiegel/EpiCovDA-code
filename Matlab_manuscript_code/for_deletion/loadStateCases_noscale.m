function [C,G,state_pop,HC,HG,DC,DG] = loadStateCases_noscale(state_id)

display('deprecated: replace with loadStateCases_noscale_v2')


filename = [ 'state_hosp_data/state_' state_id '.csv'];
popname =  [ 'state_hosp_data/state_pop' state_id '.csv'];

state_data = csvread(filename,1,1);
state_pop = csvread(popname,1,0);
% state_pop = 1;


sm_period = 10;


casesC = state_data(:,1);
casesG = state_data(:,3);
T = (1:length(casesC));


T_int = 1:.5:T(end);
casesC_int = smooth(smooth(interp1(T,casesC,T_int),sm_period),sm_period)';
casesG_int = getGfromC(casesC_int,T_int);

C = casesC;
G = casesG;



C = interp1(T_int,casesC_int,T)';
G = interp1(T_int,casesG_int',T)';
HC = state_data(:,5);
HG = state_data(:,6);

DC = state_data(:,2);
DG = state_data(:,4);

DC_int = smooth(smooth(interp1(T,DC,T_int),sm_period),sm_period)';

DG_int = getGfromC(DC_int,T_int); 


DC = interp1(T_int,DC_int,T)';
DG = interp1(T_int,DG_int,T)';


HC_int = smooth(smooth(interp1(T,HC,T_int),sm_period),sm_period)';
HG_int = getGfromC(HC_int,T_int); 



HC = interp1(T_int,HC_int,T)';
HG = interp1(T_int,HG_int,T)';
 



HG(end) = mean(HG(end-7:end));
G(end) = mean(G(end-7:end));
DG(end) = mean(DG(end-7:end));

HG(end-1) = mean(HG(end-8:end-1));
G(end-1) = mean(G(end-8:end-1));
DG(end-1) = mean(DG(end-8:end-1));


end