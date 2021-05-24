function [X,bds]=find_priors(C,I,C_raw,I_raw,C_ref,DC,location_name,...
    i_plot)
% This code finds the values of beta, gamma, and z for the ICC curve that
% best fits the data in C and I, for a range of values of N.
% If possible, it returns
%    - the optimal set of parameters: X = [sqrt(beta) sqrt(gamma) N C0]
%    - bounds on beta, gamma, R0, N, as well as the optimal value of C_inf
% If not, X and bds are returned empty
% Created 4/24/2020 by J. Lega
% Last modified: 6/1/2020

% Define a range of values of N (in nc) and finds the optimal parameters
% for each value 
N_0 = C(end); nc=round(linspace(N_0+1,20*N_0,10000)); 
nc=unique(nc); nval=length(nc);
RM=zeros(1,nval); bt=RM; gm=RM; ce=RM; z=RM;
for j=1:nval
    [bt(j),gm(j),RM(j),z(j)]=find_beta_gamma_z(C,I,nc(j));
    % Find final number of cases
    C_vals=linspace(0,1.5*nc(j),500);
    I_vals=ICC(0,C_vals,bt(j),gm(j),nc(j),nc(j)*(1-exp(z(j))));
    I_vals(I_vals<=0)=0; ik=find(I_vals(10:end)==0,1,'first')+9;
    if isempty(ik)
        ik=length(C_vals);
    end
    ce(j)=C_vals(ik);
end
% Find optimal value of N
i_p=find(gm>0,1,'first')+1;
i_M=find(RM(i_p:end)==max(RM(i_p:end)),1,'first')+i_p-1;
i_m=find(RM(i_M:end)==min(RM(i_M:end)),1,'first')+i_M-1; N_m = nc(i_m);
if ~isempty(i_m)
    % Confirm with fminseach
    X0=[sqrt(bt(i_m)),sqrt(gm(i_m)),nc(i_m),nc(i_m)*(1-exp(z(i_m)))];
    R0_max=4; f=@(X) find_err(X,I,C,R0_max);
    options = optimset('MaxFunEvals',50000,'MaxIter',20000);
    X=fminsearch(f,X0,options); %X=abs(X);
    if abs(N_m-X(3))>2*(nc(2)-nc(1))
        disp(['N_m = ' num2str(round(N_m)) ' - RMSE: ' num2str(RM(i_m))]);
    end
    if X(1)^2 > 2 || ~isreal(X) || (X(1)/X(2))^2 > R0_max || ~isreal(f(X))
        disp('Cannot fit the data')
        bds=[]; X=[];
    else
        C_vals=linspace(0,1.5*X(3),1500);
        I_opt=ICC(0,C_vals,X(1)^2,X(2)^2,X(3),X(4)); I_opt(I_opt<=0)=0;
        i1=find(I_opt(1:round(length(I_opt)/2))<=0,1,'last');
        if isempty(i1)
            i1=1;
        end
        i_opt_end=find(I_opt(i1+1:end)<=0,1,'first')+i1;
        C_opt_end=round(C_vals(i_opt_end));
        % Repeat in case there is not enough resolution
        C_vals=linspace(0,1.5*C_opt_end,500);
        I_opt=ICC(0,C_vals,X(1)^2,X(2)^2,X(3),X(4)); I_opt(I_opt<=0)=0;
        i1=find(I_opt(1:round(length(I_opt)/2))<=0,1,'last');
        if isempty(i1)
            i1=1;
        end
        i_opt_end=find(I_opt(i1+1:end)<=0,1,'first')+i1;
        C_opt_end=round(C_vals(i_opt_end));
        % Display optimal values
        disp(['Optimal ICC curve: N = ' num2str(round(X(3))) ...
            ' - RMSE: ' num2str(f(X)) ' - C_inf: ' num2str(C_opt_end) ...
            ' - C_0 = ' num2str(X(4))])
        disp(['Optimal ICC curve: beta = ' num2str(X(1)^2) ...
            ' - gamma = ' num2str(X(2)^2) ' - R_0 = ' ...
            num2str(X(1)^2/X(2)^2)])
        % Find possible range of values of N - 2%
%         k=find(RM<=1.005*f(X) & bt>0 & bt./gm > 1 & bt./gm<R0_max);
        k=find(RM<=1.02*f(X) & bt>0 & bt./gm > 1 & bt./gm<R0_max);
        n_min=min(nc(k)); n_max=max(nc(k));
        disp(['Bounds for N: [' num2str(round(n_min)) ', ' ...
            num2str(round(n_max)) ']'])
        R0r=bt(k)./gm(k); R0_min=min(R0r); R0_max=max(R0r);
        disp(['Bounds for R0: [' num2str(R0_min) ', ' ...
            num2str(R0_max) ']'])
        % Ranges for beta, gamma, and R_0
        nc=n_min:1:n_max; bet=nc; gam=nc; zn=nc;
        for j=1:length(nc)
            [bet(j),gam(j),~,zn(j)]=find_beta_gamma_z(C,I,nc(j));
        end
        disp(['Bounds for beta: [' num2str(min(bet)) ', ' ...
            num2str(max(bet)) ']'])
        disp(['Bounds for gamma: [' num2str(min(gam)) ', ' ...
            num2str(max(gam)) ']'])
        disp(['Bounds for beta N: [' num2str(min(bet.*nc)) ', ' ...
            num2str(max(bet.*nc)) ']'])
        if isempty(k)
            disp('Cannot fit the data')
            bds=[]; X=[];
            i_plot=0;
        else
            bds=[min(bet) max(bet) X(1)^2 min(gam) max(gam) X(2)^2 ...
                R0_min R0_max X(1)^2/X(2)^2 round(n_min) round(n_max) ...
                round(X(3)) C_opt_end];
        end
        % Combined figure showing the ICC curve and the range of R0 values
        if i_plot==1
            figure(); set(gcf,'Position',[0 0 1200 400]);
            subplot(1,2,1)
            histogram(bet.*nc,30,'Normalization','pdf');
            xlabel('\beta N'); ylabel('Probability')
            subplot(1,2,2)
            histogram(gam,30,'Normalization','pdf');
            xlabel('\gamma'); ylabel('Probability')
            figure(); set(gcf,'Position',[0 0 1200 400]);
            sc=X(3)/DC(end);
            subplot(3,3,[1,2,4,5])
            plot(C_raw,I_raw,'*'); hold on; plot(C,I,'o');
            xlabel('Cumulative counts');
            yy=ICC(0,C_ref*sc,X(1)^2,X(2)^2,X(3),X(4));
            plot(C_ref*sc,yy,'k-','LineWidth',1);
            hold off; xlim([0 C_opt_end]);
            MI=round(1.05*max([max(I) max(I_raw) max(yy)]));
            ylim([0 1.1*MI]);
            ylabel('Incidence'); title(['COVID-19 ICC curve - ' ...
                location_name ])
            legend('Reported data','Interpolated data',...
                ['ICC curve - R_0 = ' num2str(X(1)^2/X(2)^2)],...
                'Location','northeast')
            subplot(3,3,[3,6])
            histogram(bet./gam,30,'Normalization','pdf');
            xlabel('R_0'); ylabel('Probability');
        end
    end
else
    disp('Cannot fit the data')
    bds=[]; X=[];
end
