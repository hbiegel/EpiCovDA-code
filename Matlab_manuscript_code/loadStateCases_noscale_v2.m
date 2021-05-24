function [C,G,state_pop,HC,HG,DC,DG] = loadStateCases_noscale_v2(state_id, forecast_date)

% Updated 7/14/20       HRB
%                       Fix smoothing window so that smoothing only occurs
%                           on data preceding the forecast date


[~, last_ob, ~] = get_observation_index(state_id,...
                                forecast_date,1);
                            

                            
filename = [ 'state_hosp_data_2020-11-16/state_' state_id '.csv'];
popname =  [ 'state_hosp_data_2020-11-16/state_pop' state_id '.csv'];


state_data = csvread(filename,1,1);
if strcmp(state_id,'US')
    state_pop = 328200000;
else
    state_pop = csvread(popname,1,0);
end



sm_period = 7;


casesC = state_data(:,1);
casesG = state_data(:,3);

hopsC = state_data(:,5);
hospG = state_data(:,6);
deathC = state_data(:,2);
deathG = state_data(:,4);



% Intialize smoothed data
G = casesG;
HG = hospG;
DG = deathG;

% Smooth over sm_period
G(1:end) = smooth(smooth(casesG(1:end),sm_period),sm_period);
HG(1:end) = smooth(smooth(hospG(1:end),sm_period),sm_period);
DG(1:end) = smooth(smooth(deathG(1:end),sm_period),sm_period);

% Make sure the data before the forecast_date does not use data after
%   forecast_date
G(1:last_ob) = smooth(smooth(casesG(1:last_ob),sm_period),sm_period);
HG(1:last_ob) = smooth(smooth(hospG(1:last_ob),sm_period),sm_period);
DG(1:last_ob) = smooth(smooth(deathG(1:last_ob),sm_period),sm_period);


% M = 2;ceil(sm_period/3);
% % Fix the right edge of the observed data before forecast_date
% for j = 0:ceil(sm_period/3)
%     G(last_ob - j) = mean(G(last_ob - j - M: last_ob));
%     HG(last_ob - j) = mean(HG(last_ob - j - M: last_ob));
%     DG(last_ob - j) = mean(DG(last_ob - j - M: last_ob));
% end


% linear interpolation for last few days before forecast_date
% N = 3;
% coefsG = polyfit((last_ob-N-1:last_ob-2)',G(last_ob-N-1:last_ob-2),1);
% G(last_ob-1:last_ob) = polyval(coefsG,last_ob-1:last_ob);
% coefsHG = polyfit((last_ob-N-1:last_ob-2)',hospG(last_ob-N-1:last_ob-2),1);
% HG(last_ob-1:last_ob) = polyval(coefsHG,last_ob-1:last_ob);
% coefsDG = polyfit((last_ob-N-1:last_ob-2)',deathG(last_ob-N-1:last_ob-2),1);
% DG(last_ob-1:last_ob) = polyval(coefsDG,last_ob-1:last_ob);
% 

% G(last_ob-1:last_ob) = G(last_ob-3:last_ob-2);
% DG(last_ob-1:last_ob) = DG(last_ob-3:last_ob-2);
% HG(last_ob-1:last_ob) = HG(last_ob-3:last_ob-2);

G(last_ob-1:last_ob) = G(last_ob-2)*[1;1];
DG(last_ob-1:last_ob) = DG(last_ob-2)*[1;1];
HG(last_ob-1:last_ob) = HG(last_ob-2)*[1;1];

% Save cumulative values as sum of smoothed incidence
C = cumsum(G);
HC = cumsum(HG);
DC = cumsum(DG);


% fake_G = smooth(smooth(casesG,sm_period),sm_period); 
% 
% figure();
% hold on;
% plot(casesG)
% plot(G)
% plot(fake_G)
% plot([last_ob,last_ob],[0,1.1*max(casesG)])













                            