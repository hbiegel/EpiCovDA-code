function [day_ahead, error] =  run_plot_forecasts_v3(all_params,K_choices,...
                            s,state_id,n_samps,forecast_date,t_G_fig,...
                            fc_comp_fig)
% Created 5/28/20    HRB
%                    Plot and optionally save forecasts for 
%                       SIR ICC curve


% all_params :      N x 3 matrix
%                   each column contains values of beta, gamma, N 
%                       respectively [SIRICC model parameters]
% K_choices :       vector of integers
%                   each entry in K_choices denotes a number of data points 
%                       ("observations") what were used to fit parameters
% s :               integer
%                   index of data to start the observations used to fit
%                       parameters
% state_id :        abbreviation of state currently being forecasted
% n_samps  :        integer > 0     
%                   number of samples to be used per entry in K_choices
% focecast_date :   string in form 'YYYY-mm-dd' 
%                   date of last observation used for forecasts
% t_G_fig :         boolean or value 0,1
%                   if t_G_fig == 1 (or true), plot forecasts against
%                   smoothed data 
% fc_comp_fig :     boolean or value 0,1
%                   if fc_comp_fig == 1 (or true), day ahead cumulative
%                   forecasts are compared to the truth (if truth
%                   available)

%% Load data

% [currC,currG,pop,currHC,currHG,currDC,currDG] = loadStateCases_noscale(state_id);

% Smooth version of case count data
[currC,currG,~,~,~,~,~] = loadStateCases_noscale_v2(state_id,forecast_date);

% Raw (un-smoothed) version of case count date
[~,currG2,~,~,~,~,~] = loadStateCases_noscale_nosmooth(state_id);


% Use the most number of observations to in plot
K = max(K_choices);

NN = length(K_choices);


% Select the K observed data points
obsC = currC(s:s+K-1);
obsG = currG(s:s+K-1);

% Select the timing of the observed points
tobs = s:s+K-1;


% Number of Days to Predict --- could be changed to an input
ndp = 31;

% Initiate matrix to be filled with day ahead predictions
%   each row corresponds to one ensemble member
%   each column corresponds to the all predictions for a single day
day_ahead = zeros(n_samps,ndp);

% t_preds = 1:ndp;
t_preds = 0:ndp-1;
t_last = s+K-1; % time (in days) of last data point before forecast

C0 = obsC(end); % initiate ode solver at last observation




% get ndp day ahead predictions for each parameter set in all_params
for i = 1:n_samps*NN
        currBeta = all_params(i,1);
        currGamma = all_params(i,2);
        currN = all_params(i,3);
        currCstart = all_params(i,4);
  
        [t, Ct, Gt] = ...
            forwardSIRICCmodel_v3(currBeta,currGamma,currN,currCstart,C0,ndp);
        Gpreds = interp1(t,Gt,t_preds); % select whole day ahead values
        day_ahead(i,:) = Gpreds;
end


% average of ensemble day ahead forecast
ave_ahead = mean(day_ahead,1);



% choice of shade of grey for forecast ensemble in plot
ens_col = [0.7,0.7,0.7];


% plot of forecasts in time vs incidence plane
if t_G_fig
figure(); hold on; box on;
    
    % plot day ahead forecast ensemble in gray 
    plot(t_preds+t_last,day_ahead,'Color',ens_col,'HandleVisibility','off')
    
    % plot smoothed case incidence in blue
    plot(currG,'LineWidth',3,'DisplayName','Smoothed cases',...
        'Color',[3, 127, 252]/255)
    
    
    % plot markers over observations used in forecasts in red
    plot(tobs,obsG,'.-','LineWidth',2,...
        'DisplayName','Obs for preds','Color',[204, 12, 25]/255,...
        'MarkerSize',20)
    
    % plot average day ahead forecast in black
    plot(t_preds+t_last,ave_ahead,'LineWidth',3,'Color','black',...
        'DisplayName','Ensemble average');
    
    ylabel('Number of cases')
    xlabel('Time (days)')
    legend('Location','Northeast')
    set(gca,'FontSize',16)
    title([state_id ', ' forecast_date])
hold off;
end 
    
    
% cumulative predictions
total_day_ahead = cumsum(day_ahead,2);

% average cumulative prediction 
mean_total = mean(total_day_ahead,1);

% truth - cumulative over forecast period
%   **not smoothed**
wk_truth = cumsum(currG2(s+K:end));

% average prediction - cumulative over forecast period
wk_pred = cumsum(ave_ahead);


% comparison of daily prediction distribution to truth
if fc_comp_fig
    figure();
    hold on; box on; set(gca,'FontSize',16);
    
    % plot cumulative day ahead ensemble (in grey)
    plot(1:ndp,total_day_ahead(:,1:ndp),'o','Color',ens_col,...
        'MarkerFaceColor',ens_col,...
        'HandleVisibility','off')
    
    % plot cumulative day ahead ensemble average (in black)
    plot(1:ndp,mean_total(1:ndp),'o-','Color','k','LineWidth',2,...
        'MarkerFaceColor','k',...
        'DisplayName','Forecast Ensemble Average')
    
    % plot truth for cumulative over forecast periods
    plot(1:length(wk_truth),wk_truth,'o-','LineWidth',2,...
        'MarkerFaceColor',[3, 127, 252]/255,...
        'Color',[3, 127, 252]/255,'DisplayName','Truth')
    
    xlabel('Days ahead')
    ylabel('Cumulative cases during forecast period')
    legend('Location','Northwest')
    hold off
    title([state_id ', ' forecast_date])
end



% Calculate 1-wk and 2-wk ahead relative errors if data is available
%   these are errors on the cumulative values over the forecast period
%   if errors on the 1-wk and 2-wk ahead incident values are desired 
%   instead, uncomment the line indicated below

if length(wk_truth) < 7
    re1 = nan;
else 
    re1 = (wk_pred(7)-wk_truth(7))/wk_truth(7);
end

if length(wk_truth) < 14
    re2 = nan;
else
    re2 = (wk_pred(14) - wk_truth(14))/wk_truth(14);
    % uncomment the following line for wk 2 incident error 
    % re2 = (wk_pred(14) -wk_pred(7) - wk_truth(14) + wk_truth(7))/(wk_truth(14)-wk_truth(7));

end

display(['State: ' state_id])
display(['Forecast Date: ' forecast_date])
display(['1 wk ahead error: ' num2str(re1)])
display(['2 wk ahead error: ' num2str(re2)])

error = [re1,re2];






