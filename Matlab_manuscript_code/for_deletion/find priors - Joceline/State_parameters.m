% For each of the US states listed in list_of_states.csv, this code
% reads COVID-19 data in pathname/['state_' state_name '.csv']
% and finds a range of parameters values that provide good fits for the
% associated ICC curve. It then creates and populates an excel file, with
% optimal parameter values and associated ranges, which may be used as
% priors for future analyses.
% The data is retrieved from the directory called
% ['../../covid_state_hosp_data_' dataset_date '/'] where dataset_date
% needs to be updated by the user.
% For JHU data, edit plot_ICC_curve.m
% Author: Joceline Lega - Last modified: 7/23/2020

clear variables;
min_length=15;          % Minimum number of datapoints for ICC curve
i_col=1;                % 1 for case count; 2 for deaths
% Directory
dataset_date='6-19';    % dataset_date='4-27';
pathname=['../../covid_state_hosp_data_' dataset_date '/'];
% Read file with list of states
fname='list_of_states.csv'; filename=char(strcat(pathname,fname));
[~,txt,~]=xlsread(filename); txt=sort(txt);
% Prepare output file
if i_col==1
    outfile=['state_parameters_case_counts_' dataset_date '.xlsx'];
else
    outfile=['state_parameters_deaths.xlsx_' dataset_date '.xlsx'];
end
xlswrite(outfile,{'State'},1,'A1');
xlswrite(outfile,{'beta_min','beta_max','beta_opt',...
    'gamma_min','gamma_max','gamma_opt','R0_min','R0_max','R0_opt',...
    'N_min','N_max','N_opt','C_inf','T_start','T_end',...
    'data points dropped','population'},1,'B1');
% The last data point used in estimating the parameters is C_raw(end-i_end)
i_end=zeros(1,length(txt)-1);
% Smoothing factor
smth_factor=6;
for j=1:length(txt)-1
    disp(' '); disp(['State: ' txt{j,1}]); location_name=txt{j};
    % Find ICC curve
    [~,C,I,C_raw,I_raw,~,~,C_ref,In_ref,DC,tme]=...
        plot_ICC_curve(location_name,pathname,smth_factor,i_end(j),...
        i_col,0,datenum('01/01/2020'),datenum('04/01/2020'));
    d0=tme(1); disp(['First day of outbreak: ' datestr(d0)])
    disp(['Cumulative number of cases on ' datestr(tme(end)) ': ' ...
        num2str(C_raw(end))])
    i_state=find(strcmp(txt(:,1),location_name));
    lc=length(C_raw);
    if C_raw(end) <= 1000
        X=[]; bds=[];
        disp('Less than 1000 cases on 4/1/2020')
    else
        % Parameter values for different sizes of N
        [X,bds]=find_priors(C,I,C_raw,I_raw,C_ref,DC,location_name,1);
        while isempty(X)
            i_end(j)=i_end(j)+1;
            if lc-i_end(j) < min_length
                X=1; bds=[];
            else
                [~,C,I,C_raw,I_raw,~,~,C_ref,In_ref,DC,tme]=...
                    plot_ICC_curve(location_name,pathname,smth_factor,i_end(j),...
                    i_col,0,datenum('01/01/2020'),datenum('04/01/2020'));
                [X,bds]=find_priors(C,I,C_raw,I_raw,C_ref,DC,location_name,1);
            end
        end
        if length(X)==1
            X=[]; bds=[];
        end
        % Read population of each state
        fname=['state_pop' txt{j,1} '.csv']; filename=char(strcat(pathname,fname));
        [pop,~,~]=xlsread(filename); txt=sort(txt);
    end
    % Write output file
    xlswrite(outfile,{location_name},1,['A' num2str(i_state+1)])
    if ~isempty(bds)
        bds_w=[bds tme(1) tme(end) i_end(j) pop];
        xlswrite(outfile,bds_w,1,['B' num2str(i_state+1)])
    end
end