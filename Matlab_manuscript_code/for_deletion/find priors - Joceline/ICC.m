function dy=ICC(~,x,bet,gam,N,C0)
% This function calculates the ICC curve for the SIR model, and includes
% the initial condition as C0 = C(0) = N (1 - kappa).
% The value of dy is set to 0 in regions where x >= N or if dy < 0.
% Created 5/24/2019 by J. Lega
% Last modified 4/22/2020

dy=(bet*x+N*gam*log(abs(N-x)/(N-C0))).*(1-x/N);
dy((N-x)<=0)=0;

