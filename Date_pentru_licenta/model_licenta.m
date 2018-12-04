close all; clear all; clc;
l = load ('finStepB05.mat');
data = l.finStepB05;
t = data.time;
u = (t>=0)*0.5;
n = length(t);
r = (t>=0).*t;

%% Plot date
theta = data.signals(1,1).values;
figure;
plot (t, theta); 
title('THETA -  L05R05')

thetadot = data.signals(1, 2).values;
figure;
plot (t, thetadot);
title('THETADOT -  L05R05')

psi = data.signals(1, 3).values;
figure;
plot (t, psi);
title('PSI -  L05R05')

psidot= data.signals(1, 4).values;
figure;
plot (t, psidot);
title('PSIDOT -  L05R05')


phi = data.signals(1, 5).values;
figure;
plot (t, phi);
title('PHI -  L05R05')

phidot = data.signals(1, 6).values;
figure;
plot (t, phidot);
title('PHIDOT -  L05R05')

%% model extraction
%THETA
th = load('theta_model.mat');
[At, Bt, Ct, Dt, Ft] = polydata(th.oe441);
Hth = tf(Bt, Ft, 1, 'variable', 'z^-1');
Hth = zpk(minreal(Hth));
figure;
ysim = lsim(Hth, u);
plot(t, ysim, 'r')
hold on
plot (t, theta, 'b');

%THETADOT
thdot = load('thetadot_model.mat');
[Atd, Btd, Ctd, Dtd, Ftd] = polydata(thdot.oe441);

%PSI
ps = load('psi_model.mat');
[Aps, Bps, Cps, Dps, Fps] = polydata(ps.oe221);

%PSIDOT
psdot = load('psidot_model.mat');
[Apsd, Bpsd, Cpsd, Dpsd, Fpsd] = polydata(psdot.arx881);

%PHI
ph = load('phi_model.mat');
[Aph, Bph, Cph, Dph, Fph] = polydata(ph.oe881);

%PHIDOT
phdot = load('phidot_model.mat');
[Aphd, Bphd, Cphd, Dphd, Fphd] = polydata(phdot.oe10101);