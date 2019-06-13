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

%% Plot date
thetadot = dataOut.signals(1, 2).values;
%dataTHdot = iddata(thetadot,[uL uR],Te);
dataTHdotV = iddata(thetadot,[uL, uR],Te);
figure;
plot (dataTHdotV); title('THETADOT');

theta = dataOut.signals(1,1).values;
dataTH = iddata(theta,thetadot,Te);
dataTH2 = iddata(theta,[uL uR],Te);
figure;
plot(dataTH); title('THETA');

phidot = dataOut.signals(1, 6).values;
%dataPHId = iddata(phidot, phi,Te);
dataPHIdV = iddata(phidot,[uL, uR],Te);
figure;
plot (dataPHIdV); title('PHIDOT');

phi = dataOut.signals(1, 5).values;
dataPhi = iddata(phi,phidot,Te);
figure;
plot (dataPhi); title('PHI');

psidot= dataOut.signals(1, 4).values;
%dataPSdot = iddata(psidot, psi,Te);
dataPSdotV = iddata(psidot,[uL, uR],Te);
figure;
plot (dataPSdotV); title('PSIDOT');

psi = dataOut.signals(1, 3).values;
dataPSI = iddata(psi,psidot,Te);
figure;
plot (dataPSI); title('PSI');

%% data
dataTH = iddata([theta thetadot], [uL uR], Te);

%% Modelare
Options = n4sidOptions;                                                                 
Hthdot = n4sid(dataTHdotV, 3, 'Form', 'canonical', 'Ts', 0, Options);
 
Hth = tf(1, [1 0]);
Hth = ss(Hth);

Hpsdot = n4sid(dataPSdotV, 3, 'Form', 'canonical', 'Ts', 0, Options);
Hps = Hth;

Hphdot = ssest(dataPHIdV, 1, 'Form', 'canonical', Options);
Hph = Hth;

Hf_MIMO = [Hth Hth; Hthdot(1,1) Hthdot(1,2);...
           Hps Hps; Hpsdot(1,1) Hpsdot(1,2);...
           Hph Hph; Hphdot(1,1) Hphdot(1,2)];














