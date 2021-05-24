function aY = SIRICC_paramVDA_v3(x0,yT,cT,s,mu,B0,noise,N_scale)
% Updated 6/11/20   HRB
%                   Scale N variable 
x0;
B = B0(1:2,1:2);
state_pop = x0(3)*3;
% B = diag([1,1,1/N_scale])*B0*diag([1,1,1/N_scale]); % adjust N
% trace(noise)
Binv = inv(B);
func = @(x0)costFxn(x0,yT,cT,s,mu,Binv,noise,N_scale,state_pop);

options = optimset('MaxIter',10^5,'MaxFunEvals',10^5,'TolFun',10^(-7));


% costFxn(x0,yT,cT,s,mu,Binv,noise,N_scale,state_pop)

xstar = fminsearch(func,x0,options);
% xstar = lsqnonlin(func,x0,[0.000001; 0.000001; 1000],[4;4;10^10],options);

aY = xstar;

end


function out = costFxn(x0,yT,cT,s,mu,B0,noise,N_scale,state_pop)

B = B0;
R = noise;
H = 1;


beta = x0(1); 
gamma = x0(2);
N = x0(3); 
Cstart = x0(4);
% x0(3) = x0(3)/N_scale;
mu0 = mu;
% mu0(3) = mu0(3)/N_scale;


x0 = x0(:,1);
    


% Jx = 1/2*(x0 - mu0)'* B^(-1)*(x0 - mu0)
% see line 3 -- B was pre-inverted
Jx = 1/2*(x0(1:2) - mu0(1:2))'* B*(x0(1:2) - mu0(1:2));


%  Jx = Jx + 1/2*(N - state_pop)^2/(state_pop)^2;


new_G = SIRICC_model2(0,cT,beta,gamma,N,Cstart);
% [t, Ct, Gt] = forwardSIRICCmodel(beta,gamma,N,cT(1),length(cT));
% new_G = interp1(t,Gt,1:(length(cT)))';
% new_C = interp1(t,Ct,1:(length(cT)))';


diff = sum((1./diag(R).*(new_G - yT).^2));
Jx = Jx + 1/2*diff;
% diff = (1./diag(R).*(new_G - yT).^2);
% Jx =  1/2*diff;


if N < cT(end) %min(cT)
    Jx = 2*Jx;
end

if beta <= 0 || gamma <= 0 || beta/gamma > 20
    Jx  = 2*Jx;
end

if N > state_pop
    Jx = 2*Jx;
end

if Cstart > N
    Jx = 2*Jx;
end


out = Jx;

end



function dy=SIRICC_model2(~,x,beta,gamma,N,C0)
% This function calculates the ICC curve for the SIR model, and includes
% the initial condition as C0 = C(0) = N (1 - kappa).
% The value of dy is set to 0 in regions where x >= N or if dy < 0.
% Created 5/24/2019 by J. Lega
% Last modified 4/22/2020 by J. Lega
% Modified (minorly) 5/2/2020 by H. Biegel 

dy=(beta*x+N*gamma*log(abs(N-x)/(N-C0))).*(1-x/N);
dy((N-x)<=0)=0;

end


