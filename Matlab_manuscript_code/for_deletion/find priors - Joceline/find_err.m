function RMSE=find_err(X,I,C,R0_max)
% This function calculates the error between the ICC curve with parameters
% contained in X and the data points. It prevents R0 to go above the
% parameter n_min.
% Created 2/9/2020 by J. Lega
% Last modified 4/19/2020

% Remove data points corresponding to values of C that are bigger than or
% equal to N = X(3)
I(C>=X(3))=[]; C(C>=X(3))=[];

% Find ICC curve
Ic=ICC(0,C,X(1)^2,X(2)^2,X(3),X(4));

% Return error
RMSE=sqrt(mean((I-Ic).^2))+100000*((X(1)/X(2))^2>R0_max)^2;
