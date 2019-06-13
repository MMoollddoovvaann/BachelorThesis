close all; clear all; clc;
l = load('checkstuff.mat');
data = l.check;
t = data.time;
Te = 0.003;
uL = (t>=0)*0.25;
uR = (t>=0)*0.25;
n = length(t);
r = (t>=0).*t;

%% Plot date
theta = data.signals(1,1).values;
dataTH = iddata(theta,[uL, uR],Te);
figure;
plot(dataTH); title('THETA');

thetadot = data.signals(1, 2).values;
dataTHdot = iddata(thetadot,[uL uR],Te);
figure;
plot (dataTHdot); title('THETADOT');

phi = data.signals(1, 5).values;
dataPhi = iddata(phi,[uL, uR],Te);
figure;
plot (dataPhi); title('PHI');

phidot = data.signals(1, 6).values;
dataPHId = iddata(phidot,[uL uR],Te);
figure;
plot (dataPHId); title('PHIDOT');

psi = data.signals(1, 3).values;
dataPSI = iddata(psi,[uL, uR],Te);
figure;
plot (dataPSI); title('PSI');

psidot= data.signals(1, 4).values;
dataPSdot = iddata(psidot,[uL uR],Te);
figure;
plot (dataPSdot); title('PSIDOT');


data6 = iddata([theta, thetadot, psi, psidot, phi, phidot],[uL uR], Te);
figure;
plot (data6); title('Date achizi?ionate');

%% Extragere modele & Simulare
 Options = ssestOptions;                            
 Options.N4Weight = 'CVA';                           
 Options.Regularization.Lambda = 0.25796;            
 Options.SearchMethod = 'gn';                        
                                                     
 Hf_MIMO = ssest(data6, 6, 'Form', 'canonical', Options);

 %Model 2
 Options = ssestOptions;                                                        
 Options.N4Weight = 'CVA';                                                      
 Options.Regularization.Lambda = 0.25796;                                       
                                                                                
 Hf_MIMO1 = ssest(data6, 6, 'Form', 'canonical', 'Feedthrough', [true true], Options);
 
 %Model 3
 Options = ssestOptions;                             
 Options.Regularization.Lambda = 0.2;                
                                 
 Hf_MIMO2 = ssest(data6, 6, 'Form', 'canonical', Options);
%% LQR MIMO Control
% Q=[0.5 0 0 0 0 0; 0 1.5 0 0 0 0; 0 0 2000 0 0 0;...
%     0 0 0 0.1 0 0; 0 0 0 0 20 0; 0 0 0 0 0 750];
Q=[0.4 0 0 0 0 0; 0 1.4 0 0 0 0; 0 0 1800 0 0 0;...
    0 0 0 0.095 0 0; 0 0 0 0 18 0; 0 0 0 0 0 690];
R = 1000*eye(2);
K = lqr(Hf_MIMO.a, Hf_MIMO.b, Q, R);
K = K/10;
K(:, 4:6) = K(:, 4:6)/10;

% LQR - 2
K1 = lqr(Hf_MIMO1.a, Hf_MIMO1.b, Q, R);
K1(:, 4:6) = K1(:, 4:6)/10;

%LQR - 3
K2 = lqr(Hf_MIMO2.a, Hf_MIMO2.b, Q, R);
K2 = K2/10;
K2(:, 4:6) = K2(:, 4:6)/10;
%% LQG MIMO Control
% MIMO: THETA, PSI, PHI
Q_g=eye(8);
R_g=1000*eye(12);
Hf_MIMO_SS = ss(Hf_MIMO);
K_g = lqg(model, Q_g, R_g)

%% Kalman
Q_k=eye(2);
R_k=1000*eye(6);
[kest,L,P] = kalman(Hf_MIMO_SS,Q_k,R_k,ones(2,6))

