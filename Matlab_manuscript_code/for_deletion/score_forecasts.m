function daily_errors = score_forecasts(forecast_date,state_id,data_choice)

% Updated 6/25/20       HRB
%                       Load quantile forecasts and calculate error,
%                           absolute error, and relative error

% 
% forecast_date = '2020-04-26';
% state_id = 'NY';
% data_choice = 'DC';


[C,G,~,HC,HG,DC,DG] = loadStateCases_noscale_nosmooth(state_id);
[~, last_day, date_array] = get_observation_index(state_id,...
                                forecast_date,1);
                            
quants_list = ([1,2.5,5:5:95,97.5,99]/100);

forecast_file = ['quantile_forecasts/' data_choice '_' state_id '_' ...
                forecast_date '.csv'];
state_forecast = csvread(forecast_file);
ndp = length(state_forecast(1,:));

truth = eval(data_choice);

if strcmp(data_choice,'C') || strcmp(data_choice,'DC') || ...
        strcmp(data_choice,'HC')
    truth_0 = truth(last_day);
else 
    truth_0 = 0;
end

num_truth = min(length(truth) - last_day,ndp);

daily_errors = zeros(num_truth,3);


for ii = 1:num_truth
    ct = truth(last_day+ii)-truth_0;
    cf_median = state_forecast(12,ii); %quants_list(12) = 0.5
    err = ct - cf_median;
    abs_err = abs(err);
    rel_err = abs_err/ct;
    
    daily_errors(ii,:) = [err, abs_err, rel_err];
    
    
end


figure(); 
set(gcf,'paperunits','inches')
set(gcf,'position',[156,367,1200,438])




p1 = subplot(1,2,1);
hold on; box on;
set(gca,'FontSize',16)
plot(truth(last_day+1:last_day+1)-truth_0,'LineWidth',3,...
    'Color',[21,168,206]/255)

plot(1:ndp,state_forecast,'Color',0.7*[1,1,1],'LineWidth',2,...
    'HandleVisibility','off')
plot(1:ndp,state_forecast(12,:),'Color',0*[1,1,1],...
    'LineWidth',3)
plot(1,state_forecast(1,1),'Color',0.7*[1,1,1],'LineWidth',2)
plot(truth(last_day+1:end)-truth_0,'LineWidth',3,...
    'HandleVisibility','off','Color',[21,168,206]/255)
legend('Reported values','Forecast median','Forecast quantiles')
legend('Location','Northwest')
title('Quantiles vs Truth')
xlabel('Days since forecast')
ylabel([data_choice ' over forecast period'])



p2 = subplot(1,2,2);
hold on; box on;
set(gca,'FontSize',16)
plot(daily_errors(:,3),'o')
xlabel('Days since forecast')
ylabel('Relative absolute error')
title('Relative error over forecast period')



set(p1,'Position', [0.08 0.12 0.55 .82]);
set(p2,'Position', [0.75 0.12 0.2 .82]);
% ax = gca;
% ax.Position = [156         367        900         438];

% figure(); hold on;
% plot(G(1:end),'LineWidth',2)
% plot(last_day,G(last_day),'o')

% figure(); hold on;
% plot(daily_errors(:,2),'o')


% set(gcf,'paperunits','inches')
% set(gcf,'position',[156         367        1113         438])


