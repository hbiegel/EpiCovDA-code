function [t, Ct, Gt] = forwardSIRICCmodel_v3(beta,gamma,N,Cstart,C0,Tfinal)

% Approximate C(t) and G(t)
tspan = [0,Tfinal];
options = odeset('RelTol',1e-8,'AbsTol',1e-9,'MaxStep',1e-1);
[t, Ct] = ode45(@(t,x)SIRICC_model(t,x,beta,gamma,N,Cstart),tspan,C0,options);

Gt = SIRICC_model(0,Ct,beta,gamma,N,Cstart);
end


function dy=SIRICC_model(~,x,beta,gamma,N,C0)
% This function calculates the ICC curve for the SIR model, and includes
% the initial condition as C0 = C(0) = N (1 - kappa).
% The value of dy is set to 0 in regions where x >= N or if dy < 0.
% Created 5/24/2019 by J. Lega
% Last modified 4/22/2020 by J. Lega
% Modified (minorly) 5/2/2020 by H. Biegel 

dy=(beta*x+N*gamma*log(abs(N-x)/(N-C0))).*(1-x/N);
dy((N-x)<=0)=0;

end

