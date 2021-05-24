function plotQuantilesWithTruth(state_id,last_day,forecast_date,shift,target)

quant_filename = ['quantile_forecasts/' target '_' state_id '_' ...
                    forecast_date '.csv'];
                
quants = csvread(quant_filename);       
% Raw (un-smoothed) version of data
[C,G,~,HC,HG,DC,DG]  = loadStateCases_noscale_nosmooth(state_id);
% Smooth version of case count data
[currCsm,currGsm,~,currHCsm,currHGsm,currDCsm,currDGsm] = ...
                                loadStateCases_noscale_v2(state_id,forecast_date);

allTruth = G;
smTruth = currGsm;
if strcmp(target,'HC')
    allTruth = HC;
    smTruth = currHCsm;
    quants = quants + allTruth(last_day);
elseif strcmp(target,'HG')
    allTruth = HG;
    smTruth = currHGsm;
elseif strcmp(target,'DC')
    allTruth = DC;
    smTruth = currDCsm;
    quants = quants + allTruth(last_day);
elseif strcmp(target,'DG')
    allTruth = DG;
    smTruth = currDGsm;
elseif strcmp(target,'C')
    allTruth = C;
    smTruth = currCsm;
    quants = quants + allTruth(last_day);
end

ndp = length(quants(1,:));

N = min(last_day+ndp,length(allTruth));


median_forecast = quants(12,:);



[~, ~,date_array] = get_observation_index(state_id,...
                                forecast_date,5);




forecast_period = datetime({forecast_date})+1;


for j = 2:ndp
    forecast_period = [forecast_period; datetime({forecast_date})+j];

end

maxY = 1.05*max([allTruth(1:N); smTruth(1:N); quants(end,:)']); 
    



figure(); hold on; box on;
    set(gca,'FontSize',16)
    plot(forecast_period,quants,'Color',0.7*[1,1,1],...
        'LineWidth',1.5,'HandleVisibility','off')
    plot(forecast_period,median_forecast,'Color',0*[1,1,1],...
        'LineWidth',3,'DisplayName','Forecast Median')    
    plot(datetime(date_array(1:last_day)),allTruth(1:last_day),'o-','LineWidth',1,...
        'DisplayName','Reported Cases',...
        'Color',[3, 175, 252]/255)
    plot(datetime(date_array(last_day+1:N)),allTruth(last_day+1:N),'*','LineWidth',1,...
        'DisplayName','Reported Cases',...
        'Color',[3, 175, 252]/255)
    plot(datetime(date_array(1:last_day)),smTruth(1:last_day),'LineWidth',3,...
        'Color',[3, 127, 252]/255,...
        'DisplayName','Time Averaged Cases')
    plot(datetime(date_array(last_day+1:N)),smTruth(last_day+1:N),':',...
        'LineWidth',3,...
        'Color',[3, 127, 252]/255,...
        'DisplayName','Time Averaged Cases')
    plot([datetime({forecast_date}), datetime({forecast_date})],[0,maxY],'--r',...
        'DisplayName','Forecast Date',...
        'LineWidth',1.5)
    plot(forecast_period(1),quants(1,1),'Color',0.7*[1,1,1],...
        'LineWidth',1.5,'DisplayName','Forecast Quantiles')
    legend('Location','Northwest')
    datetick('x','mmm-dd')
    tstart = datetime(date_array(1));
    tend = forecast_period(end)+1; 
%     xlim([tstart tend]);
    xlim([tstart tend]);
    ylim([0,maxY]);
    ylabel(target)
    xlabel('Date')
    title([state_id newline ' Forecast Date: ' forecast_date])







