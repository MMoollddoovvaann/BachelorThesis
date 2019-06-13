close all; clear all; clc;
l = load('checkstuff.mat');
data = l.check;
t = data.time;
Te = t(2)-t(1);
uL = (t>=0)*0.25;
uR = (t>=0)*0.25;
n = length(t);
r = (t>=0).*t;

%% Plot date
theta = data.signals(1,1).values;
dataTH = iddata(theta,[uL, uR],Te);
figure;
plot(dataTH); title('THETA -  L05R05');

thetadot = data.signals(1, 2).values;
dataTHdot = iddata(thetadot,theta,Te);
figure;
plot (dataTHdot); title('THETADOT -  L05R05');

phi = data.signals(1, 5).values;
dataPhi = iddata(phi,[uL, uR],Te);
figure;
plot (dataPhi); title('PHI -  L05R05');

phidot = data.signals(1, 6).values;
dataPHId = iddata(phidot,phi,Te);
figure;
plot (dataPHId); title('PHIDOT -  L05R05');

psi = data.signals(1, 3).values;
dataPSI = iddata(psi,[uL, uR],Te);
figure;
plot (dataPSI); title('PSI -  L05R05');

psidot= data.signals(1, 4).values;
dataPSdot = iddata(psidot,psi,Te);
figure;
plot (dataPSdot); title('PSIDOT -  L05R05');

%% Extragere modele & Simulare
%THETA
Options = tfestOptions;                                      
Hth= tfest(dataTH, [4 4], [4 4], Options);
compare(dataTH, Hth);

%THETADOT
Hthdot = tfest(dataTHdot, 1, 2, 'Ts', Te);
compare(dataTHdot, Hthdot);

%PSI
Hps = tfest(dataPSI, [2 2], [1 1], 'Ts', Te);
compare(dataPSI, Hps);

%PSIDOT
Options = tfestOptions;                                   
Hpsdot = tfest(dataPSdot, 2, 3, Options, 'Ts', 0.01, 'Feedthrough', true);
compare(dataPSdot, Hpsdot);

%PHI
%var cu 2 intrari: 19%
Options = tfestOptions;                   
Options.InitialCondition = 'backcast';                                            
Hph = tfest(dataPhi, [4 4], [3 3], Options);
compare(dataPhi, Hph);

%PHIDOT
Options = tfestOptions;                                                                     
Hphdot = tfest(dataPHId, 2, 1, Options, 'Ts', 0.01, 'Feedthrough', true);
compare(dataPHId, Hphdot);

%% Minimase
% THETA
% Compute second-order approximation
Hth = tfest(dataTH, [2 2], [2 2], 'Ts', Te);
compare(dataTH, Hth);

% THETADOT
% Create balredOptions
opt = balredOptions('Offset',.001,'StateElimMethod','MatchDC');
% Compute second-order approximation
Hthdot = tf(Hthdot);
Hthdot = balred(Hthdot, 2, opt);
Hthdot = idtf(Hthdot);
compare(dataTHdot, Hthdot)

% PSI
% No minimisation needed since Hps is already of second order

% PSIDOT
% Hpsd45
% BalredOptions
opt = balredOptions('Offset',.0001,'StateElimMethod','MatchDC');
% Compute second-order approximation
Hpsdot = tf(Hpsdot);
Hpsdot = balred(Hpsdot, 2, opt);
Hpsdot = idtf(Hpsdot);
compare(dataPSdot, Hpsdot);

% PHI
% BalredOptions
% % Compute second-order approximation
Hph = tfest(dataPhi, [2 2], [2 2], 'Ts', Te);
compare(dataPhi, Hph);

% PHIDOT
% Hphd22-no minimisation necessary (already of secound order)

%% MIMO tf
Hf_MIMO = [Hth(1,1) Hth(1,2); Hps(1,1) Hps(1,2); ...
           Hph(1,1) Hph(1,2)];
Hfd_MIMO = [Hthdot 1 1; 1 Hpsdot 1; 1 1 Hphdot];

Hf_MIMO = ss(Hf_MIMO);
Hfd_MIMO = ss(Hfd_MIMO);

%% LQR MIMO Control
% MIMO: THETA, PSI, PHI
%compute balanced realisation
[Hf_MIMO, neg_state] = balreal(Hf_MIMO);
%choose the states that are keeped
elim_state = (neg_state<9*1e-4);
%remove negligible states
Hf_MIMO = modred(Hf_MIMO, elim_state);

Q = 100*eye(size(Hf_MIMO.a));
R = eye(2);
K = lqr(Hf_MIMO.a, Hf_MIMO.b, Q, R)

% MIMO: THETADOT, PSIDOT, PHIDOT
%compute balanced realisation
[Hfd_MIMO, neg_state_d] = balreal(Hfd_MIMO);
%Choose kept states
elim_states_d =(neg_state_d<0.0902*1e+4);
% remove negligible states
Hfd_MIMO=modred(Hfd_MIMO, elim_states_d);

Q_d = eye(size(Hfd_MIMO.a));
R_d = eye(3);
K_d = lqr(Hfd_MIMO.a, Hfd_MIMO.b, Q_d, R_d);

%% LQG MIMO Control
% THETA, PSI,PHI

