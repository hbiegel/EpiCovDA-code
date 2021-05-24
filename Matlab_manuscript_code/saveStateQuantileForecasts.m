function [ssQ,shift,ssQC] = saveStateQuantileForecasts(state_id,forecast_date,last_day,...
                            all_targets,day_ahead,save_quants)

% Updated 6/6/20        HRB
%                       Replaces "save_scaled_forecasts_v2"
%                       Saves forecast distribution in terms of quantiles
%                       Cumulative forecasts are given as cumulative values
%                           over forecast period (not entire pandemic)
%                       Saves quantile forecasts to "quantile_forecasts"
%                           folder
% Updated 6/7/20        For quantiles, cumulative forecast ensemble is 
%                           cumulative sum of incidence ensemble after 
%                           augmenting with samples for normal distribution
%                       Automatically save cumulative forecasts when
%                           running incidence forecasts
% Output:
% ssQ :                 23 x ndp matrix
%                       Incidence forecast quantiles
%                       One column for each day ahead prediction 
% shift :               Integer >= 0
%                       Number of days shifted when calculating ratio
%                           between cases and forecasted target
% ssQC :                23 x ndp matrix
%                       Cumulative forecast quantiles
% 
% Inputs:
% state_id :            string, state abbreviation, e.g. 'NY'
% forecast_date :       string in form 'YYYY-mm-dd', e.g. '2020-05-10'
% last_day :            Integer > 0
%                       Index of state data where the last observation used
%                       for forecasting occurs occurs
% all_targets :         cell array containing any of 'G', 'DG', and 'HG'
% day_ahead :           N x ndp matrix
%                       Each column corresponds to the forecast ensemble
%                           for a single day
%                       Forecasts for CASE counts
% save_quants           boolean or value 0,1



quants_wanted = ([1,2.5,5:5:95,97.5,99]/100);

nTar = length(all_targets);


for i = 1:nTar
        
    data_choice = all_targets{i};

    
    
    [targetEns,rsc,shift] = adjustTargetDistribution(state_id,last_day,...
                    forecast_date,data_choice,day_ahead);

    % Double the ensemble, then replace the first half of the members by
    % sampling from a normal distribution with mean and standard deviation 
    % specified by the original ensemble; this is done for each day
    extEns = [targetEns;targetEns];  
    
    
    ndp = length(targetEns(1,:)); %number of days predicted
    nr = length(targetEns(:,1)); %original ensemble size
    var_inf = forecastVarianceInflation(state_id,forecast_date,data_choice);
    
    
    % Updated for submissions on 3/8/21
    % Old: var_inf_factor = max(var_inf/std(targetEns(:,1))^2,1);
%     var_inf_factor = 0.25*max(var_inf/std(targetEns(:,1))^2,1);

var_inf_factor = max(var_inf/std(targetEns(:,1))^2,1);
    

    for k = 1:ndp
        
%         var_use = max(var_inf,max(mean(targetEns(:,k)),std(targetEns(:,k))^2));
        var_use = var_inf_factor*max(mean(targetEns(:,k)),std(targetEns(:,k))^2);
        
%         extEns(1:nr,k) = poissrnd(mean(targetEns(:,k)),nr,1);

        extEns(1:nr,k) = max(mean(targetEns(:,k)) + ...
            1*sqrt(var_use)*randn(nr,1),0);

        
        

    end
    
    
    var_inf_case = forecastVarianceInflation(state_id,forecast_date,'G')/rsc^2;
    
    %%% use variance of case data to compute variance of "tube"
    var_use0 = max(var_inf_case,max(mean(targetEns(:,1)),std(targetEns(:,1))^2));
    % fill in shifted predictions with a distribution around rescaled
    % shifted case data
    if shift > 0 
        
        % submitted forecasts use factor = 25 instead of 1
        extEns = fillShiftedPredictions(state_id,last_day,rsc,shift,extEns,forecast_date,1);
%         extEns = fillShiftedPredictions(state_id,last_day,rsc,shift,extEns,forecast_date,var_inf_case);
%     extEns = fillShiftedPredictions(state_id,last_day,rsc,shift,extEns,forecast_date,var_use0);
    end
    
    
    
    
    % Cumulative data with same sample of normal random variables as
    % incidence forecasts
    extEnsC = cumsum(extEns,2);
    extEnsWkG = getWeeklyIncidencePredictions(extEns,state_id,data_choice,last_day);
    
    % Calculated quantiles
    sQ = quantile(extEns,quants_wanted,1);  
    sQC = quantile(extEnsC,quants_wanted,1); 
    sQwk = quantile(extEnsWkG,quants_wanted,1); 
    % Smooth quantiles and enforce monotonicity of quantiles in...
    %   cumulative forecasts
    ssQ = sQ;
    ssQC = sQC;
    ssQwk = sQwk;
    
    
    for p = 1:length(quants_wanted)
        tssq = smooth(smooth(sQ(p,:),5));
        tssqC = smooth(smooth(sQC(p,:),5));
        tssqWk = smooth(smooth(sQwk(p,:),5));
        
        
        tssq = round(tssq,0); 
        tssqC = round(tssqC,0); 
        tssqWk = round(tssqWk,0); 
        
        
        % Monotonicity is now acheived by cumulative sums over non-negative
        % incidence forecasts
        
        % enforce monotonicity in cumulative forecasts
%         if strcmp(data_choice,'DC') || strcmp(data_choice,'HC') ...
%                 || strcmp(data_choice,'C')

%             diff1 = [tssqC(1);tssqC(2:end) - tssqC(1:end-1)];
%             diff1 = diff1.*(diff1>=0) + 0* diff1.*(diff1<0);
% 
%             tssqC = cumsum(diff1);
%         end

        ssQ(p,:) = tssq;
        ssQC(p,:) = tssqC;
        ssQwk(p,:) = tssqWk;
    end

    
    for mm = 1:length(ssQ(1,:))
        
        ssQ(:,mm) = sort(ssQ(:,mm));
        ssQC(:,mm) = sort(ssQC(:,mm));
        ssQwk(:,mm) = sort(ssQwk(:,mm));
        
        
        
        
    end
    
    
    
 if save_quants    
    % Save forecasts in csv file
    csave_name = ['quantile_forecasts/' data_choice '_' state_id ...
        '_' forecast_date '.csv'];

    csvwrite(csave_name,ssQ);
    
    
    wkGsave_name =  ['quantile_forecasts/' data_choice '_wk_' state_id ...
        '_' forecast_date '.csv'];
    
    
    csvwrite(wkGsave_name,ssQwk);
    
    if strcmp(data_choice,'G')
        cCsave_name = ['quantile_forecasts/C_' state_id ...
        '_' forecast_date '.csv'];
    else
        cCsave_name = ['quantile_forecasts/' data_choice(1) 'C_' state_id ...
            '_' forecast_date '.csv'];

    end
    csvwrite(cCsave_name,ssQC);
    
    

    
    
 end
 
%     % plot quantiles across time
%     figure(); hold on;
%     plot(1:ndp,ssQ,'Color','k')
end



