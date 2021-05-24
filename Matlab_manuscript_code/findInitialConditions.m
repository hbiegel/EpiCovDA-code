function [X,Cstart] = findInitialConditions(state_id, forecast_date, num_days)
% This function finds the optimal initial condition (C(0)) given recent
% data before the forecast date.
% Created 7/23/20 by H. Biegel
% Adapted from J. Lega's COVID19_US_Local_Parameters, find_best_ICC_fit,
% and plot_ICC_curve
% Last updated 7/23/20 by H. Biegel


% Read data file
location_name= state_id; 

% % Replace with most updated data in folder state_hosp_data
% dataset_date='6-19';
% pathname=['../../covid_state_hosp_data_' dataset_date '/'];

pathname=['state_hosp_data/'];

% Define region of dataset to use
dt=forecast_date; n_pts=num_days;

[X,C_raw,I_raw,C,I] = ...
    find_best_ICC_fit_v2(dt,n_pts,location_name,pathname);



Cstart = X(4); 
N = X(3);


% if Cstart > C_raw(end)
%     Cstart = C_raw(1);
%     display('Cstart exceeded last observation of C,')
%     display('using first observation instead.')
% end


end



function [X,C_raw,I_raw,C,I] = ...
    find_best_ICC_fit_v2(dt,n_pts,location_name,pathname)
% Parameters
smth_factor=6; i_end=0; i_col=1;
% Smooth and interpolate the data from the beginning to the specified date
[~,C,I,C_raw,I_raw,~,~,~,~,~,~]=...
    plot_ICC_curve_v2(location_name,pathname,smth_factor,i_end,i_col,0,...
    datenum('01/01/2020'),datenum(dt));
X0=[1,1,2*C(end),C(end)];   % Initial condition
% Fit the smoothed datapoints between dt-n_pts and dt
R0_max=4; f=@(X) find_err_v2(X,I(end-n_pts:end),C(end-n_pts:end),R0_max);
options = optimset('MaxFunEvals',50000,'MaxIter',20000);
X=fminsearch(f,X0,options);


end






function [W,C,I,C_raw,I_raw,C_raw0,I_raw0,C_ref,In_ref,DC,tme]=...
    plot_ICC_curve_v2(location_name,pathname,smth_factor,i_end,i_col,...
    i_plot,start_date,end_date)
% This code reads cumulative counts in filename and define the corresponding
% ICC curve by smoothing and interpolating these data. It also plots the
% ICC curve if i_plot is set to 1.
%
% location_name: 2-letter state descriptor
% smth_factor: smoothing factor used in the call to find_IC
% i_end: number of data points to remove at the end of the record (used
%        when no ICC curve can be found given the current information)
% i_col: set to 1 for case counts and 2 for deaths records
% i_plot: set to 1 to plot the ICC curve
% end_date: last day to include in the data used to plot the ICC curve
% 
% Created 4/24/2020 by J. Lega
% Last modified: 7/22/2020 H. Biegel 
%                          Replace xlsread with alternative for MacBook
%   
%
%
fname=['state_' location_name '.csv'];
% fname=['JHU_state_' location_name '.csv'];
filename=char(strcat(pathname,fname)); 

%[A_raw,txt,~]=xlsread(filename); 
[A_raw,txt]= xlsreadCovidData(filename);

tme=datenum(txt(2:end,1)); C_raw=A_raw(1:end,i_col);
% Find beginning and end of data set
i_end_icc=find(tme==end_date,1); i_st_icc=find(tme==start_date,1);
if isempty(i_st_icc) || start_date >= end_date
    i_st_icc=find(C_raw>1,1,'first');
end
if isempty(i_end_icc)
    i_end_icc=size(C_raw,1);
end
% Data
C_raw0=A_raw(i_st_icc:i_end_icc,i_col);
I_raw0=[1; C_raw0(2:end)-C_raw0(1:end-1)];
% Data with i_end last points removed
C_raw=C_raw(i_st_icc:i_end_icc-i_end);
I_raw=[1; C_raw(2:end)-C_raw(1:end-1)];
tme=tme(i_st_icc:i_end_icc-i_end);
% Smooth and interpolate the cumulative data - reduce the smoothing factor
% (the last argument of find_IC) to make estimates closer to data
[W,DC,In_ref,C_ref]=find_IC_v2(C_raw,smth_factor);
DIn=DC; DIn(2:end)=DC(2:end)-DC(1:end-1); dt=tme(2)-tme(1);
C=(DC(2:end)+DC(1:end-1))/2; I=DIn(2:end)/dt; MI=max([max(I) max(I_raw)]);
% Plot ICC curve
if i_plot==1
    figure(); set(gcf,'Position',[50 50 800 200]);
    plot(C,I,'o',C_raw,I_raw,'*'); hold on;
    plot(C_ref,In_ref,'k-','LineWidth',1); hold off;
    ylim([0 1.1*MI]); ylabel('Incidence');
    if i_col == 1
        xlabel('Cumulative cases'); 
    elseif i_col == 2
        xlabel('Cumulative deaths'); 
    end
    title(['ICC curve - ' location_name]);
end
end


function [W,C,Growth,Cases]=find_IC_v2(A_raw,smth_factor)

% This function takes a time series of cumulative cases and interpolates it
% to remove the effect of reports when incidence was not updated or when
% negative incidence was reported.
% Created 5/24/2019 by J. Lega
% Modified on 9/19/2019 to include smoothing factor smth_factor
% Last modified 7/7/2020
%
C = A_raw;               % Number of reported cases
W = 1:1:length(C);            % Weeks with new data points
T_max=W(end);
% Define a more refined grid on which to interpolate the data
h=1/28;
Weeks=1:h:T_max;            % Time in TU
Cases=zeros(size(Weeks));   % Number of cases
Growth=zeros(size(Weeks));  % Growth rate
if sum(C) > 0
    % Remove repeated values except zeros and end values
    D=[1; C(2:end)-C(1:end-1)];
    W(D==0 & C~=0 & C~=C(end))=[];
    C(D==0 & C~=0 & C~=C(end))=[];
    % Smooth and then interporlate the data
    Cases=interp1(W,smooth(W,C,smth_factor),Weeks,'pchip');
    % Growth rate
    Growth=[(Cases(2)-Cases(1))/h ...
        (Cases(3:end)-Cases(1:end-2))/2/h ...
        (Cases(end)-Cases(end-1))/h];
    % Set to zero negative values in Cases vector (7/7/2020)
    Growth(Cases<0)=0;
    Cases(Cases<0)=0;
end
W = 1:1:T_max;            % Weeks with new data points
k=ismember(Weeks,W);
C=Cases(k); W=Weeks(k);
% Make sure C does not decrease as a function of time
DC=C(2:end)-C(1:end-1); k=find(DC<0)+1;
while ~isempty(k)
    for j=1:length(k)
        C(k(j))=C(k(j)-1);
    end
    DC=C(2:end)-C(1:end-1); k=find(DC<0)+1;
end
end


function RMSE=find_err_v2(X,I,C,R0_max)
% This function calculates the error between the ICC curve with parameters
% contained in X and the data points. It prevents R0 to go above the
% parameter n_min.
% Created 2/9/2020 by J. Lega
% Last modified 4/19/2020

% Remove data points corresponding to values of C that are bigger than or
% equal to N = X(3)
I(C>=X(3))=[]; C(C>=X(3))=[];

% Find ICC curve
Ic=ICC_v2(0,C,X(1)^2,X(2)^2,X(3),X(4));

% Return error
RMSE=sqrt(mean((I-Ic).^2))+100000*((X(1)/X(2))^2>R0_max)^2;


end

function dy=ICC_v2(~,x,bet,gam,N,C0)
% This function calculates the ICC curve for the SIR model, and includes
% the initial condition as C0 = C(0) = N (1 - kappa).
% The value of dy is set to 0 in regions where x >= N or if dy < 0.
% Created 5/24/2019 by J. Lega
% Last modified 4/22/2020

dy=(bet*x+N*gam*log(abs(N-x)/(N-C0))).*(1-x/N);
dy((N-x)<=0)=0;

end

