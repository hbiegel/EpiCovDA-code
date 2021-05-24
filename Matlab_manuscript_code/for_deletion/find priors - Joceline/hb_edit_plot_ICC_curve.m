function [W,C,I,C_raw,I_raw,C_raw0,I_raw0,C_ref,In_ref,DC,tme]=...
    hb_edit_plot_ICC_curve(location_name,pathname,smth_factor,i_end,i_col,...
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
[W,DC,In_ref,C_ref]=find_IC(C_raw,smth_factor);
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