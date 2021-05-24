function final_params = setup_run_VDA_v3(K,s,state_id,fig_on,forecast_date,P0)


% Updated 5/27/20       HRB
%                       Use VDA technique over multiple observations
%                           on SIR ICC model
%                       Replaces US_SIR_ICC_VDAmain_covid
%                       Uses state_id (aka state abbreviation) instead of
%                           state_num and state_list


% K :                   integer >0
%                       number of observations used to fit model parameters
% s :                   integer >0
%                       index for first observation used
% state_id :            abbreviation of state currently being forecasted
% fig_on :              boolean or value 0,1
%                       if fig_on == 1 (or true), forecasts are plotted in ICC plane (C,G)
%                       if fig_on == 0 (or false), ICC plane figure not plotted
%                  

%% Example of inputs
% K =30; % number of observations
% s = 5; % where to start data observations
% state_id = 'NY';
% fig_on = 1;



%% Load data
[currC,currG,state_pop,~,~,~,~] = loadStateCases_noscale_v2(state_id,forecast_date);

% Add noise to the K observations
noise = abs(diag(currG(s:K+s-1)));

if currG(K+s-1) <= 0
    noise(end,end) = mean([noise(end-1,end-1),noise(end-2,end-2)]);
    currG(K+s-1) = noise(end,end);
end


nG = [currG(1:s-1); max(currG(s:K+s-1) + mvnrnd(zeros(K,1),noise)',0); currG(K+s:end)];

% [~,currG,state_pop,~,~,~,~] = loadStateCases_noscale_nosmooth(state_id);
% noise = diag(currG(s:K+s-1));%std(currG(s:K+s-1))^2*eye(K);
% nG = currG;

% If instead you wish to sample poisson distributed random variables
% uncomment the next line
% nG = poissrnd(currG);

% Define the noisy cumulative values as the sum of the noisy indicence
% nC = cumsum(nG);
nC = [0; cumsum(nG)];

%% Load prior information

p_params = load_EpiGro_params();

N_scale = mean(p_params(:,3));
B0 = 1*cov(p_params);

trace(B0);
trace(noise);


% collect observations to feed into VDA
y2 = nG(s:K+s-1);
c2 = nC(s:K+s-1);

%% Assimilate real data using K observations

colors = parula(4);


% Average season parameters
mu_beta = 1*mean(p_params(:,1));
mu_gamma = 1*mean(p_params(:,2));
mu_N = mean(p_params(:,3)); %7.8120e+06; %7*10^5;%7.4272e+05; 



mu = [mu_beta; mu_gamma; mu_N];
P0 = mu; %initiate parameter search at average parameters
P0(3) = state_pop/3;
P0 = [P0; -100]; % Initial guess for Cstart is Cstart = -100

% randomly perturb prior as well 
mutilde = mvnrnd(mu,B0)';



tobs = [s:K+s-1];
aY = SIRICC_paramVDA_v3(P0,y2,c2,s,mutilde,B0,noise,N_scale);
aY;



C0 = c2(1);


params = [C0;aY];
final_params = aY';

    
%% optional ICC figure (i.e. (C,G) plot) 

if fig_on 
    Tfinal  = 200;
    
    
    [t, Ct,Gt] = forwardSIRICCmodel_v3(params(1),params(2),params(3),params(4),0,Tfinal);
    aTp = [0:Tfinal];
    
    aCplot = interp1(t,Ct,aTp)';
    aGplot = interp1(t,Gt,aTp)';

    obsY = nG(s:K+s-1);
    currC = cumsum(currG);
    assimColor = [0.7,0.7,0.7];
%     fig1 = figure();
    hold on; box on;
    set(gca,'FontSize',22)
    plot(currC,currG,'LineWidth',4,'Color',colors(1,:))
    plot(currC(s:K+s-1),obsY,'.-','MarkerSize',35,'LineWidth',3,'Color',colors(2,:))

    plot(aCplot,aGplot,'-','LineWidth',2,'Color',assimColor)
    xlabel('C(t)')
    ylabel('G(t)')
    legend('Truth (smoothed)','Psuedo-Observations','Assimilation/Forecast',...
        'Location','northeast')
    hold off
    
    
end

end


