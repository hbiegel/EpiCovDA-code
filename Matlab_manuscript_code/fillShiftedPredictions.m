function newEns = fillShiftedPredictions(state_id,last_day,rsc,shift,targetEns,forecast_date,var_inf_factor)


[~,G]  = loadStateCases_noscale_v2(state_id,forecast_date);


newCenter = max(G(last_day - shift+1:last_day)/rsc,0);
% newCenter(end) = (newCenter(end)+newCenter(end-1))/2;


newEns0 = targetEns(:,1) - mean(targetEns(:,1));


newEns = zeros(length(newEns0),shift);

for i = 1:shift
%     newEns(:,i) = newEns0 + newCenter(i);
%         newEns(:,i) = poissrnd(newCenter(i),length(newEns(:,1)),1);
       newEns(:,i) = max(newCenter(i) +...
           normrnd(0,sqrt(var_inf_factor)*sqrt(newCenter(i)),length(newEns(:,1)),1),0);

% % updated 11/8/20
%        newEns(:,i) = abs(newCenter(i) +...
%            normrnd(0,var_inf_factor,length(newEns(:,1)),1));   

% % updated 3/18/21
%        newEns(:,i) = max(newCenter(i) +...
%            normrnd(0,var_inf_factor,length(newEns(:,1)),1),0);   
end


newEns = [newEns, targetEns];