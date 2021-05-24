function [shift,scl,allScls_out] = getOptimalShift_v2(caseData,compData,maxCompDays)

% Updated 8/27/20       HRB
%                       Use linear regression to find optimal shift and
%                           scale
% Updated 12/30/20      Increase maximum delay to 31 days
%                       
% Inputs:
%   caseData :          Location specific (case) data that is available by
%                           forecast_date
%   compData :          Location specific (hospitalization or death) data
%                           that is available by forecast_date
%   maxCompDays :       Integer>0
%                       Maximum number of recent days to use when
%                           calculating optimal shift

% Output:
%   shift :             integer >= 0 
%                       Number of days to delay caseData to optimally
%                           scale to compData
%                       e.g. shift = 0 corresponds to not shifting before
%                               scaling
%                            shift = 7 corresponds to shifting case 
%                               forecasts a week before scaling 




% nn = min(length(caseData),31);
nn = min(length(caseData),21);
testShifts = 0:nn;

allDist = zeros(length(testShifts),1);
allScls = zeros(length(testShifts),1);

for j = 1:length(testShifts)
    
    cs = testShifts(j); 
   
    currCase = caseData(1:end-cs);
    currComp = compData(1+cs:end);
    
    N = min(length(currCase),maxCompDays);
    
    currCase = cumsum(currCase(end-N+1:end));
    currComp = cumsum(currComp(end-N+1:end));
   
    
    nonZeroIndex = (currComp > 0);
    
%     currScale = mean(currCase(nonZeroIndex)./currComp(nonZeroIndex));
    
    currScale = currComp(nonZeroIndex)\currCase(nonZeroIndex);

    allDist(j) = sum((currCase(nonZeroIndex)/currScale - currComp(nonZeroIndex)).^2)/length(currCase(nonZeroIndex));
    allScls(j) = currScale;

end

% shift = allDist

% default to smaller shift
best_ind = find(allDist == min(allDist),1);

shift = testShifts(best_ind);
scl = allScls(best_ind);


[~,kbest] = mink(allDist,5);
allScls_out = allScls(kbest);










if scl < 3
    scl = mean(allScls);
    shift = 7;
end


if isempty(scl)
    scl = 60;
    shift = 7;
end



% figure();hold on;
% plot(caseData(1:end-shift)/scl)
% plot(compData(1+shift:end))

% shift = allDist


end
