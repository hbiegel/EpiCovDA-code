function plot_time_course(X,C,I,tme,C_raw,I_raw,d0,time_unit,...
    location_name,i_start,i_plot)
% This function plots the time course of an outbreak based on the
% parameters provided in X and the data in C and I.
% Author: Joceline Lega - Last modified: 7/7/2020

% ICC curve
dt=tme(2)-tme(1);
icc=@(x) ICC(0,x,X(1)^2,X(2)^2,X(3),X(4)); tme=1:dt:200;
% Parameters
i_align=find(C>C(end)/2,1);
% Integrate ICC curve
[t,y] = ode45(@(t,y) icc(y), tme(i_start):0.1:tme(end), ...
    mean(I(i_start-1:i_start+1)));
% Find integration constant by shifting time
t_sw=tme(i_align);
i_shft=find(y>C(i_align),1,'first'); t=t-t(i_shft)+t_sw+1/2;
if i_plot==1
    figure(); set(gcf,'Position',[50 50 800 400]);
    subplot(1,2,1)
    plot(1:dt:length(I_raw),C_raw,'o',t,y,'-','LineWidth',2);
    xlabel(['Time (' time_unit 's) since ' datestr(d0)]);
    ylabel('Cumulative deaths');
    legend('Reported data','ICC curve prediction','Location','southeast')
    title(['COVID-19 ICC curve - ' location_name])
    subplot(1,2,2)
    yy=icc(y); plot(1:dt:length(I_raw),I_raw,'o-',t,yy,'-','LineWidth',2);
    xlabel(['Time (' time_unit 's) since ' datestr(d0)]);
    ylim([0 1.2*max([max(I_raw) max(yy)])]); ylabel('Incidence');
    legend('Reported data','ICC curve prediction','Location','northeast')
    title(['COVID-19 ICC curve - ' location_name])
end