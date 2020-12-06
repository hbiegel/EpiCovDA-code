# Authors H. Biegel
# Email: hbiegel@math.arizona.edu
# Updated 12/6/2020

# In collaboration with J. Lega

import numpy as np
import pandas as pd 
import matplotlib.pyplot as plt
import scipy.optimize as optimize

# my moving average, returns vector same length as original
# averages over available data at either end
def moving_average(a, n=7) :
    half_window = int(np.floor(n/2))
    ret = np.cumsum(a, dtype=float)
    ret[n:] = ret[n:] - ret[:-n]
    
    NN =len(a)-1 # want NN >= 7
    
    adj_ret = np.zeros(NN+1)
    for k in range(half_window):
        adj_ret[k] = np.mean(a[:(k+half_window+1)])
        adj_ret[NN-k] = np.mean(a[NN-k-half_window:])
    
    adj_ret[half_window:NN-half_window+1] = ret[n-1:]/n
    
    return adj_ret


def ICC_curve(t,x,bet,gam,N,C0):
    dy = (bet*x+N*gam*np.log(abs(N-x)/abs(N-C0)))*(1-x/N)
    dy[(N-x)<=0]=0
    return dy


def cobwebICC(days_to_forecast,initC,bet,gam,N,C0):
    forecast_C = np.zeros((days_to_forecast,1))
    forecast_I = np.zeros((days_to_forecast,1))
    
    curr_C = np.reshape(initC,(1,1))

    for d in range(0,days_to_forecast):
        nextI = ICC_curve(0,curr_C,bet,gam,N,C0)
        forecast_I[d] = nextI
        forecast_C[d] = curr_C + nextI
        curr_C += nextI
        
    return np.reshape(forecast_I,(days_to_forecast)), np.reshape(forecast_C,(days_to_forecast))
    
    



# loss function 
# pi(theta|G) propto exp(-Lk)

def Lk(x0,iT,cT,mu,Binv,noise):
    B = Binv
    R = noise
    [beta,gamma,N,Cstart] = x0
    
    x0 = np.reshape(x0,(4,1))
    #B was pre-inverted
    Jx = 0.5 * np.transpose((x0[0:2] - mu)) @ B @ (x0[0:2] - mu)
    
    fitG = ICC_curve(0,cT,beta,gamma,N,Cstart)
    diff = np.transpose(fitG - iT) @ np.linalg.inv(R) @ (fitG - iT)
    
    Jx = Jx + 1/2*diff

    if N <= cT[-1]:
        Jx = 2*Jx
    if beta <= 0 or gamma <= 0 or beta/gamma > 20:
        Jx = 2*Jx
    if beta/gamma <= 0:
        Jx = 2*Jx
    if N > state_pop:
        Jx = 2*Jx  
    if Cstart > N:
        Jx = 2*Jx   
    
    Jx = np.reshape(Jx,1)
    
    return Jx




def EpiCovDA(Inc_data,state_pop,days_to_forecast=7):
    # Inc_data Nx1 or Nx0 vector 
    # state_pop is an integer of the locations population
    
    NN = len(Inc_data)
    K = 7 # number of recent observations to use
    ens_N = 50 # number of ensemble members to use for distribution
    C_data = np.cumsum(Inc_data)
    mu0 = [[0.2374],[0.1330]]
    B0 = [[0.00168475449133263, 0.000750429184089423], [0.000750429184089423,0.000418404484824481]]
    Binv = np.linalg.inv(B0)
    params0 = np.zeros([4,1])
    params0[0:2] = mu0[0:2] # beta0,gamma0
    params0[2] = state_pop/3 # N0
    params0[3] = -100 # C0
    
    sm_Inc = moving_average(moving_average(Inc_data,n=7),n=7) # smooth twice
    ## uncomment to adjust the end points -- this is important when last day is on a weekend
    sm_Inc[-2:] = sm_Inc[-3] 
    sm_C = np.append(0,np.cumsum(sm_Inc[0:-1]))
    
    noisy_sampsInc = np.zeros((ens_N,K)) # each row will be a pseudo-sample
    
    poiss_lam = sm_Inc[NN-K:]
    noise_mat = np.diag(poiss_lam)
    noisy_sampsInc = np.reshape(np.random.multivariate_normal(poiss_lam,noise_mat,(ens_N,1)),(ens_N,K))
    noisy_sampsInc[noisy_sampsInc<0] = 0   

    noisy_sampsC = np.zeros((ens_N,K))
    noisy_sampsC[:,0] = C_data[NN-K-1]
    noisy_sampsC[:,1:] = C_data[NN-K-1] + np.cumsum(noisy_sampsInc,axis=1)[:,0:-1]
    

    x0 = np.reshape(params0,(4))
    
    post_params = np.zeros((ens_N,4))
    forecast_I = np.zeros((ens_N,days_to_forecast))
    forecast_C = np.zeros((ens_N,days_to_forecast))
    
    for j in range(0,ens_N):
        curr_out = optimize.minimize(Lk,x0, args=(noisy_sampsInc[j,:],noisy_sampsC[j,:],mu0,Binv,noise_mat),method='Nelder-Mead')
        post_params[j,:] = curr_out.x
        [bet,gam,N,C0] = curr_out.x
        forecast_I[j,:], forecast_C[j,:] = cobwebICC(days_to_forecast,sm_C[-1],bet,gam,N,C0)
    
    
    # optional output
    
    median_forecast_I = np.median(forecast_I,axis=0)
    median_forecast_C = np.median(forecast_C,axis=0)
    
    return noisy_sampsC, noisy_sampsInc, post_params, forecast_I, forecast_C, median_forecast_I, median_forecast_C