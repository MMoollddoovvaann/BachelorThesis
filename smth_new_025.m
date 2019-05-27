close all; clear all; clc;
l = load('allData025.mat');
dataOut = l.ScopeDatadataOut025;
t = dataOut.time;
Te = t(2)-t(1);
n = length(t);
dataIn = l.ScopeDataIn025;
uL = dataIn.signals(1,1).values;
uR = dataIn.signals(1,2).values;
%% Plot date
theta = dataOut.signals(1,1).values;
dataTH = iddata(theta,[uL, uR],Te);
figure;
plot(dataTH); title('THETA');

thetadot = dataOut.signals(1, 2).values;
dataTHdot = iddata(thetadot,theta,Te);
figure;
plot (dataTHdot); title('THETADOT');

phi = dataOut.signals(1, 5).values;
dataPhi = iddata(phi,[uL, uR],Te);
figure;
plot (dataPhi); title('PHI');

phidot = dataOut.signals(1, 6).values;
dataPHId = iddata(phidot,phi,Te);
figure;
plot (dataPHId); title('PHIDOT');

psi = dataOut.signals(1, 3).values;
dataPSI = iddata(psi,[uL, uR],Te);
figure;
plot (dataPSI); title('PSI');

psidot= dataOut.signals(1, 4).values;
dataPSdot = iddata(psidot,psi,Te);
figure;
plot (dataPSdot); title('PSIDOT');

%% Extragere modele & Simulare
%THETA
Options = tfestOptions;                                      
Hth= tfest(dataTH, [4 4], [4 4], Options);
% compare(dataTH, Hth);

%THETADOT
Hthdot = tfest(dataTHdot, 2, 2, 'Ts', Te);
% compare(dataTHdot, Hthdot);

%PSI
Options = tfestOptions;                                      
Hps = tfest(dataPSI, [7 7], [1 1], Options);
% compare(dataPSI, Hps);

%PSIDOT -- 21 iunie articol 4/6 pagini - 28 iuie sustinere lucrari
Options = tfestOptions;                                   
Hpsdot = tfest(dataPSdot, 2, 2, Options, 'Ts', Te, 'Feedthrough', true);
% compare(dataPSdot, Hpsdot);

%PHI
Options = tfestOptions;                   
Options.InitialCondition = 'backcast';                                            
Hph = tfest(dataPhi, [6 6], [1 1], Options);
% compare(dataPhi, Hph);

%PHIDOT
Options = tfestOptions;                                                                     
Hphdot = tfest(dataPHId, 2, 1, Options, 'Ts', Te, 'Feedthrough', true);
% compare(dataPHId, Hphdot);