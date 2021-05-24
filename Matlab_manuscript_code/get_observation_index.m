function [ss, last_ob, date_array] = get_observation_index(state_id,...
                                forecast_date,K)

filename = [ 'state_hosp_data_2020-11-16/state_' state_id '.csv'];

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

ss = max(last_ob - K + 1,1);

date_array = dataArray{1:end-1};

% plot(datetime(dataArray{1:end-1}),1:size(temp,1))