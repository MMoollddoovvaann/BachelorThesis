close all; clear all; clc;
l = load ('finStepB05.mat');
data = l.finStepB05;
t = data.time;
Te = t(2)-t(1);
uL = (t>=0)*0.5;
uR = (t>=0)*0.5;
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
dataPSI = iddata(psi,theta,Te);
figure;
plot (dataPSI); title('PSI -  L05R05');

psidot= data.signals(1, 4).values;
dataPSdot = iddata(psidot,psi,Te);
figure;
plot (dataPSdot); title('PSIDOT -  L05R05');

%% Extragere modele & Simulare
%THETA
Hth = tfest(dataTH, [4 4], [2 2], 'Ts', Te);
compare(dataTH, Hth);

%THETADOT
Hthdot = tfest(dataTHdot, 4, 3, 'Ts', Te);
compare(dataTHdot, Hthdot);

%PSI
Hps = tfest(dataPSI, 2, 1, 'Ts', Te);
compare(dataPSI, Hps);

%PSIDOT
Hpsd45 = tfest(dataPSdot, 4, 5, 'Ts', Te);
compare(dataPSdot, Hpsd45);

%PHI
%var cu 2 intrari: 19%
Hph = tfest(dataPhi, [3 3], [1 1], 'Ts', Te);
compare(dataPhi, Hph);

%PHIDOT
Hphd22 = tfest(dataPHId, 2, 2, 'Ts', Te);
compare(dataPHId, Hphd22);

%% Minimase
% THETA
% Compute second-order approximation
Hth = tfest(dataTH, [2 2], [1 1], 'Ts', Te);
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
Hpsd45 = tf(Hpsd45);
Hpsd45 = balred(Hpsd45, 2, opt);
Hpsd45 = idtf(Hpsd45);
compare(dataPSdot, Hpsd45);

% PHI
% BalredOptions
% % Compute second-order approximation
Hph = tfest(dataPhi, [2 2], [2 2], 'Ts', Te);
compare(dataPhi, Hph);

% PHIDOT
% Hphd22-no minimisation necessary (already of secound order)

%% Control
%tf2ss

%THETA
[Ath, Bth, Cth, Dth] = tf2ss([Hth(1,1).num, Hth(1,2).num],...
    [Hth(1,1).den, Hth(1,2).den]);
THsys = ss(Ath, Bth, Cth, Dth, Te);

%PHI
[Aph, Bph, Cph, Dph] = tf2ss([Hph(1,1).num, Hph(1,2).num],...
    [Hph(1,1).den, Hph(1,2).den]);
PHsys = ss(Aph, Bph, Cph, Dph, Te);

%PSI
[Aps, Bps, Cps, Dps] = tf2ss(Hps.num, Hps.den);
PSsys = ss(Aps, Bps, Cps, Dps, Te);

%THETADOT
[Athd, Bthd, Cthd, Dthd]=tf2ss(Hthdot.num, Hthdot.den);
THDsys = ss(Athd, Bthd, Cthd, Dthd, Te);

%PSIDOT - 45
[Apsd, Bpsd, Cpsd, Dpsd]=tf2ss(Hpsd45.num, Hpsd45.den);
PSDsys = ss(Apsd, Bpsd, Cpsd, Dpsd, Te);

%PHIDOT
[Aphd, Bphd, Cphd, Dphd] = tf2ss(Hphd22.num, Hphd22.den);
PHDsys = ss(Aphd, Bphd, Cphd, Dphd, Te);

% Controlabillity
%THETA
COth = ctrb(THsys);
ctrbTH = rank(COth);
%PSI
COps = ctrb(PSsys);
ctrbPS = rank(COps);
%PHI
COph = ctrb(PHsys);
ctrbPH = rank(COph);
%THETADOT
COthd = ctrb(THDsys);
ctrbTHD = rank(COthd);
%PSIDOT
COpsd = ctrb(PSDsys);
ctrbPSD = rank(COpsd);
%PHIDOT
COphd = ctrb(PHDsys);
ctrbPHD = rank(COphd);

%Q, R
Qth = COth'*COth;
Qph = COph'*COph;
Qps = COps'*COps;
Qthd = COthd'*COthd;
Qphd = COphd'*COphd;
Qpsd = COpsd'*COpsd;
R = 1;

% K = lqr(A, B, Q, R)
Kth = lqr(Ath, Bth, Qth, R)
Kph = lqr(Aph, Bph, Qph, R)
Kps = lqr(Aps, Bps, Qps, R)
Kthd = lqr(Athd, Bthd, Qthd, R)
Kphd = lqr(Aphd, Bphd, Qphd, R)
Kpsd = lqr(Apsd, Bpsd, Qpsd, R)





