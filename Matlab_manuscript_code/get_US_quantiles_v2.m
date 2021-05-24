%% get_US_quantiles_v2
% updated 5/22/20   Set current cumulative value to 0

state_last_day = csvread("state_hosp_data/list_of_num_days.csv",1,0);
state_last_day=state_last_day;
all_targets = {'DG','HG'};
% all_targets = {'C','G','HC','HG','DC','DG'};
all_states = 1:52;
% fd = 40;
fig_choices = []; %no figures

quants_wanted = ([1,2.5,5:5:95,97.5,99]/100);

nTar = length(all_targets);
nStates = length(all_states);
us_data = csvread('state_hosp_data/state_US.csv',1,1);
N = length(us_data(:,1));



for i = 1:nTar
    all_lasts = zeros(53,1);
[~,~,testData,~,~] = plotSIRICC_forecast_distributions_v2(1,state_last_day(1),...
            all_targets{i},fig_choices);

nr = length(testData(:,1)); %original ensemble size        
ndp = length(testData(1,:)); %number of days predicted

us_total = zeros(2*nr,ndp);

data_choice = all_targets{i};

if strcmp(data_choice,'HG')
    quot = 1.5;
    col = 5;
    col2 = 6;
else
    quot = 1;
    col = 2;
    col2 = 4;
end



    for j = 1:nStates
        

        state_num = all_states(j);
        fd = state_last_day(state_num);

        [~,~,cD,~,~,cLast] = plotSIRICC_forecast_distributions(state_num,fd,...
            data_choice,fig_choices);
        
        sD = [cD;cD]/quot;
        all_lasts(j) = cLast;
        

        for k = 1:ndp
            sD(1:nr,k) = max(mean(cD(:,k)) + 1*std(cD(:,k))*randn(nr,1),0);
            sD(:,k) = smooth(smooth(sort(sD(:,k)),10),10);
        end

        us_total = us_total + sD;

    end
        all_lasts(53) = us_data(N,col);
           
        us_total_C = cumsum(us_total,2); %+us_data(N,col);
        sQ = quantile(us_total,quants_wanted,1);  
        sQC = quantile(us_total_C,quants_wanted,1);  
        ssQ = sQ; 
        

    for p = 1:length(quants_wanted)
        tssq = smooth(smooth(sQ(p,:),5));
        tssq = round(tssq,0);
        ssQ(p,:) = tssq;

    end

    ssQ = round(ssQ,0);
        
         
    csave_name1 = ['quantile_forecasts_v2/' data_choice '_US' ...
        '_lastday_' num2str(N) '.csv'];
    csvwrite(csave_name1,ssQ);

    csave_name2 = ['quantile_forecasts_v2/' data_choice(1) 'C' '_US' ...
        '_lastday_' num2str(N) '.csv'];
    csvwrite(csave_name2,sQC);
%     
%     
%     lasts_name = ['quantile_forecasts/' data_choice(1) 'C' '_allLasts.csv'];
%     csvwrite(lasts_name,all_lasts)
    
%     figure(); hold on;
%         plot(N+(1:ndp),sQC,'Color','r')
%         plot(us_data(:,col))
%         
%         
%     
%     figure(); hold on;
%         plot(N+(1:ndp),ssQ,'Color','r')
%         plot(us_data(:,col2))
%         

end



% figure(); hold on;
% % plot(edges,cbf)
% plot(quants_wanted,sQ,'*')
% 
% figure(); hold on;
% % plot(1:ndp,sQ,'Color','k')
% plot(N+(1:ndp),ssQ,'Color','r')
% plot(us_data(:,col+1))


