function [targetEnsemble,rsc,shift] = adjustTargetDistribution(state_id,last_day,...
                                forecast_date,data_choice,day_ahead)

% Updated 6/4/20        HRB
%                       Modular piece to adjust forecast distribution for
%                           each target independently 
%                       Allows for variable delays between case forecasts 
%                           and target forecasts, i.e., 6 day lag between
%                           case and death incidence
%                       Rescales and shifts case forecasts to fit specified
%                           target


[rsc,shift,all_rsc] = findTargetScaleAndShift(state_id,last_day,forecast_date,data_choice);

% all_rsc

% all_rsc = rsc*[0.85;1;1.15];
all_rsc = rsc; %rsc*[0.5;1;1.5];

data = [];
if strcmp(data_choice,"G")
    data = day_ahead;
    
else
    
    for j = 1:length(all_rsc)
        data = [data; day_ahead/all_rsc(j)];
        
%         data = [day_ahead/(0.9*rsc); ...
%                 day_ahead/(rsc);...
%                 day_ahead/(1.1*rsc)];
    end
    
 
    
end
   



targetEnsemble = data;



