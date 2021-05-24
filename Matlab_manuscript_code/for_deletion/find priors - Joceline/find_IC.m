function [W,C,Growth,Cases]=find_IC(A_raw,smth_factor)

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