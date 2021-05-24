function [X,C_raw,I_raw,C,I] = ...
    find_best_ICC_fit(dt,n_pts,location_name,pathname)
% Parameters
smth_factor=6; i_end=0; i_col=1;
% Smooth and interpolate the data from the beginning to the specified date
[~,C,I,C_raw,I_raw,~,~,~,~,~,~]=...
    plot_ICC_curve(location_name,pathname,smth_factor,i_end,i_col,0,...
    datenum('01/01/2020'),datenum(dt));
X0=[1,1,2*C(end),C(end)];   % Initial condition
% Fit the smoothed datapoints between dt-n_pts and dt
if n_pts > length(C)-1
    n_pts=length(C)-1;
end
R0_max=4; f=@(X) find_err(X,I(end-n_pts:end),C(end-n_pts:end),R0_max);
options = optimset('MaxFunEvals',50000,'MaxIter',20000);
X=fminsearch(f,X0,options);
