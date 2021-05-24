function [A_num,txt] = xlsreadCovidData(filename)
% This code splits the COVID-19 state data into the columns containing data
% and the column containing text (1st column, dates)

% Created 7/22/2020 by H. Biegel 


A_num = csvread(filename,1,1);


all_file = readtable(filename);

txt = string(all_file.date);

txt = [" "; txt];

