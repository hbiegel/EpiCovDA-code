function [rsc,shift,rsc_all] = findTargetScaleAndShift(state_id,last_ob,...
                            forecast_date,data_choice)

% Updated 6/4/20        HRB
%                       Modular piece to calculate state specific shift and
%                           scaling factor for specified target
%                       Currently set to rescale according to JHU data,
%                           could be switched to rescale according to
%                           covidtracking data
% Updated 7/12/20       If any of the last five days were 0 deaths, use a
%                           larger window to calculate scaling

[~,G,~,~,HG,~,DG]  = loadStateCases_noscale_v2(state_id,forecast_date);


% Compare up to most recent maxCompDays days -- after adjusting for shift
maxCompDays = 10;
% 
% if strcmp(state_id,'HI') || strcmp(state_id,'AK') || ...
%         strcmp(state_id,'VT') 
%     % Hawaii and Alaska have too many days with 0 deaths for only a 5 day window
%     maxCompDays = 120; 
% elseif strcmp(state_id,'WY') 
%     maxCompDays = 60; 
% elseif strcmp(state_id,'MT') 
%     maxCompDays = 30; 
% end

DG_recent = DG(last_ob - maxCompDays:last_ob);


if  strcmp(state_id,'AK') %|| strcmp(state_id,'WY') % commented out WY of 3/1/21
    % Hawaii and Alaska have too many days with 0 deaths for only a 5 day window
    
    % Updated 3/1/21
    maxCompDays = 20;
    
    % old value: maxCompDays = 60; 
    display('Used 20 days to calculate shift and scale')
elseif strcmp(state_id,'HI')
    % Updated 2/15/21
    maxCompDays = 20;
    
    % old value: maxCompDays = 60;
    display('Used 10 days to calculate shift and scale')
elseif strcmp(state_id,'VT')
    % Updated again 3/1/21
    maxCompDays = 50;
    
    % %Updated 01/24/21 
    %maxCompDays = 10; 
    
    % old value: maxCompDays = 50;
    display('Used 50 days to calculate shift and scale')
elseif length(DG_recent(DG_recent>0)) < 5
    maxCompDays = 20;
    display('Used 20 days to calculate shift and scale')
end


compCases = G;


if strcmp(data_choice,"DG") 

    compTarget = DG;
    
    if sum(compTarget(1:last_ob)) < 10
        shift = 0;
        rsc = 40;
        rsc_all = 40;
        display('Not enough >0 death days, default being used')
    else
    
    [shift,rsc,rsc_all] = getOptimalShift_v2(G(1:last_ob),compTarget(1:last_ob),maxCompDays);
    end
    
elseif strcmp(data_choice,"HG")

    compTarget = HG;
    [shift,rsc,rsc_all] = getOptimalShift_v2(G(1:last_ob),compTarget(1:last_ob),maxCompDays);
else
    compTarget = compCases;
    
    shift = 0;
    rsc = 1;
    rsc_all = 1;
end




% [shift,rsc] = getOptimalShift(G(1:last_ob),compTarget(1:last_ob),maxCompDays);













