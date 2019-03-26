close all; clear all; clc;
l = load ('finStepB05.mat');
data = l.finStepB05;
t = data.time;
Ts = t(2)-t(1);
n = length(t);
uL = (t>=0)*0.5;
uR = (t>=0)*0.5;
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
%data6 = iddata([theta, thetadot, psi, psidot, phi, phidot],[uL, uR], Ts);
data33 = iddata([thetadot, psidot, phidot],[theta, psi, phi],Ts);

figure;
plot(data32);
%figure;
% plot(data6);
figure;
plot(data33);

%% State space model estimation  
 Options = n4sidOptions;             
 Options.Focus = 'simulation';  
                                
 ssTHPS = n4sid(data32, 4, 'DisturbanceModel', 'none', Options);
 compare(data32, ssTHPS)
 
 ssDot = n4sid(data33, 4, 'DisturbanceModel', 'none', Options);
 compare(data33, ssDot) 
