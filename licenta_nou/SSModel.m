close all; clear all; clc;
l = load('datatry1.mat');
dataIn = l.ScopeData025in1;
dataOut = l.ScopeData025out1;
t = dataOut.time;
Te = l.T0;
uL = dataIn.signals(1).values;
uR = dataIn.signals(2).values;
n = length(t);
D = tf([1, 0], 1);
D = c2d(D, Te, 'tustin');
D = ss(D);

%% Plot date
theta = dataOut.signals(1,1).values;
dataTH = iddata(theta,[uL, uR],Te);
figure;
plot(dataTH); title('THETA');

thetadot = dataOut.signals(1, 2).values;
dataTHdot = iddata(thetadot,theta,Te);
dataTHdotV = iddata(thetadot,[uL, uR],Te);
figure;
plot (dataTHdot); title('THETADOT');

phi = dataOut.signals(1, 5).values;
dataPhi = iddata(phi,[uL, uR],Te);
figure;
plot (dataPhi); title('PHI');

phidot = dataOut.signals(1, 6).values;
dataPHId = iddata(phidot, phi,Te);
dataPHIdV = iddata(phidot,[uL, uR],Te);
figure;
plot (dataPHId); title('PHIDOT');

psi = dataOut.signals(1, 3).values;
dataPSI = iddata(psi,[uL, uR],Te);
figure;
plot (dataPSI); title('PSI');

psidot= dataOut.signals(1, 4).values;
dataPSdot = iddata(psidot, psi,Te);
dataPSdotV = iddata(psidot,[uL, uR],Te);
figure;
plot (dataPSdot); title('PSIDOT');

data6 = iddata([theta, thetadot, psi, psidot, phi, phidot],[uL uR], Te);


%% Modelare
Options = ssestOptions;                            
 Options.N4Weight = 'CVA';                           
 Options.Regularization.Lambda = 0.25796;            
 Options.SearchMethod = 'gn';                        
                                                     
 Hf_MIMO = ssest(data6, 6, 'Form', 'canonical', Options);

 Options = ssestOptions;                                                        
 Options.N4Weight = 'CVA';                                                      
 Options.Regularization.Lambda = 0.25796;                                       
                                                                                
 Hf_MIMO1 = ssest(data6, 6, 'Form', 'canonical', 'Feedthrough', [true true], Options);
 
 
Q=[0.5 0 0 0 0 0; 0 1.5 0 0 0 0; 0 0 2000 0 0 0;...
    0 0 0 0.1 0 0; 0 0 0 0 20 0; 0 0 0 0 0 750];
% Q=[0.4 0 0 0 0 0; 0 1.4 0 0 0 0; 0 0 1800 0 0 0;...
%     0 0 0 0.095 0 0; 0 0 0 0 18 0; 0 0 0 0 0 690];
R = 1000*eye(2);
K = lqr(Hf_MIMO1.a, Hf_MIMO1.b, Q, R)







%THETA
Options = n4sidOptions;
Options.Focus = 'stability';            
Hth = n4sid(dataTH, 1, 'Ts', 0, Options);

%THETADOT
Options = ssestOptions;
Options.Focus = 'stability';
Options.InitialState = 'backcast';
Options.N4Weight = 'SSARX';
Hthdot = ssest(dataTHdotV, 1, Options);
Hthdot = Hth*D

%PSI
Options = n4sidOptions;
Options.Focus = 'stability';
Hpsi = n4sid(dataPSI, 1, 'Ts', 0, Options);

%PSIDOT
Options = ssestOptions;
Options.Focus = 'stability';
Hpsidot = ssest(dataPSdotV, 1, Options);
Hpsidot = Hpsi*D


%PHI
Options = ssestOptions;
Options.Focus = 'stability';
Options.InitialState = 'estimate';
Options.N4Weight = 'SSARX';
Hphi = ssest(dataPhi, 1, Options) ;

%PHIDOT
Options = Hphi.Report.OptionsUsed;
Options.InitialState = 'auto';
Hphidot = pem(dataPHIdV, Hphi, Options);
Hphidot = Hphi*D

Hf_MIMO = [Hth;...
           Hthdot;...
           Hpsi; ...
           Hpsidot;....
           Hphi;...
           Hphidot];
Hf_MIMO = minreal(Hf_MIMO)
[Hf_MIMO, neg_state] = balreal(Hf_MIMO)

poles = eig(Hf_MIMO)
co = ctrb(Hf_MIMO);
controllability = rank(co)
Q = Hf_MIMO.c'*Hf_MIMO.c
Q=[0.5 0 0 0 0 0; 0 1.5 0 0 0 0; 0 0 2000 0 0 0;...
    0 0 0 0.1 0 0; 0 0 0 0 20 0; 0 0 0 0 0 750];
R = eye(2);
K = lqr(Hf_MIMO.a, Hf_MIMO.b, Q, R)
D6=zeros(6, 2)
h=ss(A6, B6, C6, D6)
H=tf(h)



