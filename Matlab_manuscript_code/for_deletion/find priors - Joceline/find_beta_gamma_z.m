function [bet,gam,RMSE,z]=find_beta_gamma_z(C,I,N)
% This function returns estimates of beta, gamma, and z=log(kappa) for
% the SIR model, given ICC data points. It also calculates the RMSE
% between the data points and the ICC curve obtained from the estimated
% parameters.
% C: cumulative cases
% I: corresponding incidence
% N: size of population
% z: log(kappa), where kappa = 1-C(0)/N
% C(0): initial number of cases
%
% Note that small denominator values are likely to lead to numerical
% errors (see Num_error_example.mlx for an example). It is therefore
% recommended to run a search procedure for the minimizer using the values
% calculated here as initial conditions, to increase accuracy.
%
% Created 3/7/2020 by J. Lega
% Last modified 4/19/2020

% Remove data points corresponding to values of C that are bigger than or
% equal to N
I(C>=N)=[]; C(C>=N)=[];

P=1-C./N; U=C/N.*(1-C/N); V=-(1-C/N).*log(1-C/N);
A=sum(U.*P); B=sum(P.^2); D=-sum(V.*P); F=sum(P.*I/N); L=sum(U.^2);
NN=-sum(U.*V); O=sum(U.*I/N); PP=sum(V.^2); Q=-sum(I.*V/N);

z=((-NN*Q+O*PP)*A+(L*Q-NN*O)*D+(-L*PP+NN^2)*F)/...
    ((A*O-F*L)*D-(A^2-B*L)*Q-NN*(B*O-F*A));
bet=((-B*O+F*A)*z^2+(2*O*D-F*NN-A*Q)*z+NN*Q-O*PP)/...
    ((A^2-B*L)*z^2+2*(-A*NN+D*L)*z-L*PP+NN^2);
gam=((-A*O+F*L)*z-L*Q+NN*O)/...
    ((A^2-B*L)*z^2+2*(-A*NN+D*L)*z-L*PP+NN^2);

RMSE=sqrt(mean((ICC(0,C,bet,gam,N,N*(1-exp(z)))-I).^2));

