close all; clear all; clc;
l = load('checkstuff.mat');
data = l.check;
t = data.time;
Ts = t(2)-t(1);
n = length(t);
uL = (t>=0)*0.25;
uR = (t>=0)*0.25;
r = (t>=0).*t;

%% Plot date
theta = data.signals(1,1).values;
thetadot = data.signals(1, 2).values;

psi = data.signals(1, 3).values;
psidot= data.signals(1, 4).values;

phi = data.signals(1, 5).values;
phidot = data.signals(1, 6).values;

%% Extragere modele & Simulare
%data22 = iddata([theta, psi],[uL, uR],Ts);
data32 = iddata([theta, psi, phi],[uL, uR],Ts);
%data6 = iddata([theta, thetadot, psi, psidot, phi, phidot],[uL uR], Ts);
% data33 = iddata([thetadot, psidot, phidot],[theta, psi, phi],Ts);

% dataTH = iddata(theta,[uL, uR],Te);
% dataTHdot = iddata(thetadot,theta,Te);
% dataPhi = iddata(phi,[uL, uR],Te);
% dataPHId = iddata(phidot,phi,Te);
% dataPSI = iddata(psi,[uL, uR],Te);
% dataPSdot = iddata(psidot,psi,Te);

% figure;
% plot(data32);
% %figure;
% % plot(data6);
% figure;
% plot(data33);

%% State space model estimation  
 Options = n4sidOptions;             
 Options.Focus = 'simulation';  
                                
 ssTHPS = n4sid(data32, 3, 'DisturbanceModel', 'none', Options);
 compare(data32, ssTHPS)
 ssTHPS = ss(ssTHPS);
 
 ssDot = n4sid(data33, 3, 'DisturbanceModel', 'none', Options);
 compare(data33, ssDot) 

 
 %2I1O
 ssTh = n4sid(dataTH, 1, 'DisturbanceModel', 'none', Options);
 compare(dataTH, ssTh)
 ssTps = n4sid(dataPSI, 1, 'DisturbanceModel', 'none', Options);
 compare(dataPSI, ssTps)
 ssTph = n4sid(dataPhi, 1, 'DisturbanceModel', 'none', Options);
 compare(dataPhi, ssTph)
 
 ssThd = n4sid(dataTHdot, 1, 'DisturbanceModel', 'none', Options);
 compare(dataTHdot, ssThd)
 ssTpsd = n4sid(dataPSdot, 1, 'DisturbanceModel', 'none', Options);
 compare(dataPSI, ssTpsd)
 ssTphd = n4sid(dataPHId, 1, 'DisturbanceModel', 'none', Options);
 compare(dataPhi, ssTphd)
 
 %% Control
Q = eye(4);
R = 0.01;

% K = lqr(A, B, Q, R)
KthL = lqr(ssTHPS(1,1).a, ssTHPS(1,1).b, Q, R)
KthR = lqr(ssTHPS(1,2).a, ssTHPS(1,2).b, Q, R)
KpsL = lqr(ssTHPS(2,1).a, ssTHPS(2,1).b, Q, R)
KpsR = lqr(ssTHPS(2,2).a, ssTHPS(2,2).b, Q, R)


