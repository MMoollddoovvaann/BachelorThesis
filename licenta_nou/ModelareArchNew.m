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

%% 
data6 = iddata([theta, thetadot, psi, psidot, phi, phidot],[uL uR], Te);

A = [];%zeros(6);
B = [];%zeros(6, 2);
% B = [0 0; 100 100; 0 0; -10 -10; 0 0; -0.1 0.1]; 
C = eye(6);
D = zeros(6, 2);
model = ss(A6, B6, C6, D);

Options = ssestOptions;
Options.Focus = 'stability';
Options.N4Weight = 'MOESP';
Hf_MIMO = ssest(data6, 6, 'Form', 'canonical', 'DisturbanceModel', 'none', 'Ts', 0.003, Options);

poles = eig(Hf_MIMO)


co = ctrb(Hf_MIMO);
controllability = rank(co)
Q = Hf_MIMO.c'*Hf_MIMO.c
R=1
%compute balanced realisation
[Hf_MIMO, neg_state] = balreal(Hf_MIMO)
%choose the states that are keeped
elim_state = (neg_state<268.2082)
%remove negligible states
Hf_MIMO = modred(Hf_MIMO, elim_state)
Hf_MIMO = minreal(Hf_MIMO, 1e-2)

Q=[0.5 0 0 0 0 0; 0 1.5 0 0 0 0; 0 0 2000 0 0 0;...
    0 0 0 0.1 0 0; 0 0 0 0 20 0; 0 0 0 0 0 750];
R = 1000*eye(2);
K = lqr(Hf_MIMO.a, Hf_MIMO.b, Q, R)

%% Estimation &Simulation
%THETA
Options = tfestOptions;
Options.InitMethod = 'all';               
Options.InitialCondition = 'backcast';
Hth = tfest(dataTH, [4 4], [2 2], Options);
compare(dataTH, Hth);

%THETADOT
Options = tfestOptions;
Options.InitMethod = 'gpmf';          
Options.InitialCondition = 'backcast';
Hthdot = tfest(dataTHdot, 1, 1, Options);
compare(dataTHdot, Hthdot);
HthdotV = Hth*D;%HthdotV = Hth*D;
compare(dataTHdotV, HthdotV);

%PSI
Options = tfestOptions;
Options.InitMethod = 'all';
Options.InitialCondition = 'backcast';
Hps = tfest(dataPSI, [3 3], [1 1], Options);
compare(dataPSI, Hps);

%PSIDOT
Options = tfestOptions;
Options.InitMethod = 'n4sid';
Options.InitialCondition = 'backcast';
Hpsdot = tfest(dataPSdot, 1, 1, Options);
compare(dataPSdot, Hpsdot);
HpsdotV = Hps*D;
compare(dataPSdotV, HpsdotV);

%PHI
Options = tfestOptions;
Options.InitMethod = 'all';
Options.InitialCondition = 'backcast';
Hph = tfest(dataPhi, [2 2], [0 0], Options);
compare(dataPhi, Hph);

%PHIDOT
Options = tfestOptions;                  
Hphdot = tfest(dataPHId, 1, 1, Options);
compare(dataPHId, Hphdot);
HphdotV = Hph*D;
compare(dataPHIdV, HphdotV);

Hf_MIMO = [Hth;...
           HthdotV;...
           Hps; ...
           HpsdotV;....
           Hph;...
           HphdotV];
Hf_MIMO = ss(Hf_MIMO);
Hf_MIMO = minreal(Hf_MIMO)
[Hf_MIMO, neg_state] = balreal(Hf_MIMO)
elim_state = (neg_state<8)
%remove negligible states
Hf_MIMO = modred(Hf_MIMO, elim_state)

Q=[0.5 0 0 0 0 0; 0 1.5 0 0 0 0; 0 0 2000 0 0 0;...
    0 0 0 0.1 0 0; 0 0 0 0 20 0; 0 0 0 0 0 750];
R = 1000*eye(2);
K = lqr(Hf_MIMO.a, Hf_MIMO.b, Q, R)

%% Minimisation
Options = tfestOptions;
Options.InitMethod = 'n4sid';             
Options.InitialCondition = 'backcast';
Hth = tfest(dataTH, [2 2], [1 1], Options);
