function plotICCpresentation_v2(state_id,last_day,K_choices,forecast_date,target)

% 
% quant_filename = ['quantile_forecasts/' target '_' state_id '_' ...
%                     forecast_date '.csv'];
%                 
% quants = csvread(quant_filename);       
% Raw (un-smoothed) version of data
[C,G,~,HC,HG,DC,DG]  = loadStateCases_noscale_nosmooth(state_id);
% Smooth version of case count data
[currCsm,currGsm,~,currHCsm,currHGsm,currDCsm,currDGsm] = ...
                                loadStateCases_noscale_v2(state_id,forecast_date);

forecast_parameters = csvread(['forecast_parameters/params_' state_id '_' ...
                    forecast_date '.csv']);

                            
K = max(K_choices);
M = length(forecast_parameters(:,1));
S  = min(K,last_day-1); %1;%max(last_day-K,1);%K;
K = min(K,last_day);

 [~, ~, date_array] = get_observation_index(state_id,...
                                forecast_date,K);


tlast = 60;%14+max(last_day-K,1);
all_fitsG = zeros(M,S+1+tlast);
all_fitsC = zeros(M,S+1+tlast);


for kk = 1:M
    curr_beta = forecast_parameters(kk,1);
    curr_gamma = forecast_parameters(kk,2);
    curr_N = forecast_parameters(kk,3);
    curr_Cstart = forecast_parameters(kk,4);
    C0 = currCsm(last_day);
    Tfinal = S+tlast;
% 
%     Gfit = SIRICC_model2(0,C(last_day-K+1:end),curr_beta,curr_gamma,curr_N,Cstart);%currCsm(last_day-K+1));
    
    [t, Ct, Gt] = ...
        forwardSIRICCmodel_v3(curr_beta,curr_gamma,curr_N,curr_Cstart,C0,Tfinal);
    
    

    all_fitsC(kk,:) = interp1(t,Ct,0:(S+tlast));
    all_fitsG(kk,:) = interp1(t,Gt,0:(S+tlast));
end



%% WARNING: not ready to plot anything except G,C for cases 

allTruth = G;
smTruth = currGsm;
if strcmp(target,'HC')
    allTruth = HC;
    smTruth = currHCsm;
%     quants = quants + allTruth(last_day);
elseif strcmp(target,'HG')
    allTruth = HG;
    smTruth = currHGsm;
elseif strcmp(target,'DC')
    allTruth = DC;
    smTruth = currDCsm;
%     quants = quants + allTruth(last_day);
elseif strcmp(target,'DG')
    allTruth = DG;
    smTruth = currDGsm;
elseif strcmp(target,'C') || strcmp(target,'G')
    allTruthC = C;
    allTruthG = G;
    smTruthC = currCsm;
    smTruthG = currGsm;
%     quantsC = allTruthC(last_day) + ...
%                     csvread(['quantile_forecasts/C_' state_id '_' ...
%                         forecast_date '.csv']);
%     quantsG = csvread(['quantile_forecasts/G_' state_id '_' ...
%                     forecast_date '.csv']);  
    
end

 
% 
% figure(); hold on; box on;
%     set(gca,'FontSize',16)
%     plot(quantsC',quantsG','Color',0.7*[1,1,1],...
%         'LineWidth',1.5,'HandleVisibility','off')
%     plot(allTruthC,allTruthG,'DisplayName','Reported Values')
%     plot(smTruthC,smTruthG, 'DisplayName','Time Averaged Values')
% 
%     plot(all_fitsC',all_fitsG','Color',0.2*[1,1,1],...
%         'DisplayName','Model fit')
%     plot(smTruthC(last_day-K+1:last_day),...
%         smTruthG(last_day-K+1:last_day),'o','Color',[3, 127, 252]/255,...
%         'DisplayName','Observed for fitting')
% %     legend()
%     xlabel('Cumulative Cases')
%     ylabel('Incident Cases')
    

figure(); hold on; box on;
    set(gca,'FontSize',20)
%     plot(quantsC',quantsG','Color',0.7*[1,1,1],...
%         'LineWidth',1.5,'HandleVisibility','off')

    plot(allTruthC,allTruthG,'-','DisplayName','Reported Values',...
        'Color',[3, 175, 252]/255,'LineWidth',1.5)    
    plot(allTruthC(last_day-K+1:last_day),...
        allTruthG(last_day-K+1:last_day),'o','Color',[219, 71, 48]/255,...
        'DisplayName','Used for fitting','LineWidth',2)
    plot(smTruthC,smTruthG, 'DisplayName','Time Averaged Values',...
        'Color',[3, 127, 252]/255,'LineWidth',3)
    plot(all_fitsC(2:end,:)',all_fitsG(2:end,:)','Color',0.5*[1,1,1],...
        'DisplayName','EpiCovDA','LineWidth',1,'HandleVisibility','off')
        plot(all_fitsC(1,:)',all_fitsG(1,:)','Color',0.5*[1,1,1],...
        'DisplayName','Ensemble Members','LineWidth',1)
     legend('Location','northwest')
     title([state_id ' forecast on ' forecast_date])
     xlim([0,8*10^4])
     ylim([0,4000])
    xlabel('Cumulative Cases')
    ylabel('Incident Cases')
    
    
figure(); hold on; box on;
    set(gca,'FontSize',20)
%     plot(quantsC',quantsG','Color',0.7*[1,1,1],...
%         'LineWidth',1.5,'HandleVisibility','off')

    plot(date_array,allTruthG,'-','DisplayName','Reported Values',...
        'Color',[3, 175, 252]/255,'LineWidth',1.5)    
    plot(date_array(last_day-K+1:last_day),...
        allTruthG(last_day-K+1:last_day),'o','Color',[219, 71, 48]/255,...
        'DisplayName','Used for fitting','LineWidth',2)
    plot(date_array,smTruthG, 'DisplayName','Time Averaged Values',...
        'Color',[3, 127, 252]/255,'LineWidth',3)
    plot(date_array(last_day:S+last_day+tlast),all_fitsG(2:end,:)','Color',0.5*[1,1,1],...
        'DisplayName','EpiCovDA','LineWidth',1,'HandleVisibility','off')
    plot(date_array(last_day:S+last_day+tlast),all_fitsG(1,:)','Color',0.5*[1,1,1],...
        'DisplayName','Ensemble Members','LineWidth',1)
     legend('Location','northwest')
     title([state_id ' forecast on ' forecast_date])
     xlim([date_array(20),date_array(last_day+21)])
     ylim([0,4000])
    xlabel('Date')
    ylabel('Incident Cases')
        
% prior_parameters = load_EpiGro_params();
% 
% figure();
% subplot(2,2,1)
%     hold on; box on;
%     set(gca,'FontSize',16)
%     histogram(prior_parameters(:,1),10,'Normalization','probability')
%     histogram(forecast_parameters(:,1),10,'Normalization','probability')
%     xlabel('beta')
%     ylabel('probability')
%     
% subplot(2,2,2)
% hold on; box on;
%     set(gca,'FontSize',16)    
%     histogram(prior_parameters(:,2),10,'Normalization','probability')
%     histogram(forecast_parameters(:,2),10,'Normalization','probability')
%     xlabel('gamma')
%     ylabel('probability')
%     
% subplot(2,2,3)
% hold on; box on;
%     set(gca,'FontSize',16)    
%     histogram(prior_parameters(:,1)./prior_parameters(:,2),10,'Normalization','probability')
%     histogram(forecast_parameters(:,1)./forecast_parameters(:,2),10,'Normalization','probability')
%     xlabel('R0')
%     ylabel('probability')
%     
% subplot(2,2,4)
% hold on; box on;
%     set(gca,'FontSize',16)    
%     histogram(prior_parameters(:,3),'Normalization','probability')
%     histogram(forecast_parameters(:,3),'Normalization','probability')
%     xlabel('N')
%     ylabel('probability')    

end 

function dy=SIRICC_model2(~,x,beta,gamma,N,C0)
% This function calculates the ICC curve for the SIR model, and includes
% the initial condition as C0 = C(0) = N (1 - kappa).
% The value of dy is set to 0 in regions where x >= N or if dy < 0.
% Created 5/24/2019 by J. Lega
% Last modified 4/22/2020 by J. Lega
% Modified (minorly) 5/2/2020 by H. Biegel 

dy=(beta*x+N*gamma*log(abs(N-x)/(N-C0))).*(1-x/N);
dy((N-x)<=0)=0;

end


