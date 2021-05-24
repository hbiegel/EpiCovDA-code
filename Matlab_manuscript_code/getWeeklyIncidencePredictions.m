function wkEnsG = getWeeklyIncidencePredictions(Ens,state_id,data_choice,last_day)

[~,G,~,~,HG,~,DG]  = loadStateCases_noscale_nosmooth(state_id);

if strcmp(data_choice,'HG')
    fillData = HG(1:last_day);
elseif strcmp(data_choice,'DG')
    fillData = DG(1:last_day);
else
    fillData = G(1:last_day);
end

N = length(Ens(:,1));

fillMat = repmat(fillData(end-5:end)',N,1);
fillMat = max(fillMat,0);

Ens = [fillMat, Ens];

wkEnsG = cumsum(Ens,2);

wkEnsG(:,8:end) = wkEnsG(:,8:end) - wkEnsG(:,1:end-7);

wkEnsG = wkEnsG(:,7:end);






end
