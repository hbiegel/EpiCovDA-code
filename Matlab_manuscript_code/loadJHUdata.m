function [C,G,HC,HG,DC,DG,last_ob] = loadJHUdata(state_id,forecast_date)

% Created 6/4/20    Import JHU data file


filename = [ 'state_hosp_data/JHU_state_' state_id '.csv'];

%% load state data
state_data = csvread(filename,1,1);

casesC = state_data(:,1);
casesG = state_data(:,3);

C = casesC;
G = casesG;

HC = state_data(:,5);
HG = state_data(:,6);

DC = state_data(:,2);
DG = state_data(:,4);

%% get last observation index
delimiter = ',';
startRow = 2;

formatSpec = '%{yyyy-MM-dd}D%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';


fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, ...
    'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError',...
    false, 'EndOfLine', '\r\n');

fclose(fileID);

temp = table(dataArray{1:end-1}, 'VariableNames', {'date'});

last_ob = find(temp.date == forecast_date);

end