close all; clear all; clc;
l = load ('finStepB05.mat');
data = l.finStepB05;
t = 1:length(data.time);
u = (t>=0).*0.5;
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
th = load('tf4.mat');
[num,den] = tfdata(th.tf4);
Hth = tf(num, den);
Hth = zpk(minreal(Hth));

yTh = lsim(Hth, u, t);
figure;
plot (t, [theta yTh]);
axis([0 80 0.057 0.065]);
legend('theta', 'yTh'); title('Model THETA');

%THETADOT
Hthdot = series(Hth,tf([1 0], 1));

yThdot = lsim(Hthdot, u, t);
figure;
plot (t, [thetadot yThdot]);
axis([0 80 0.057 0.065]);
legend('thetadot', 'yThdot'); title('Model THETADOT');

%PSI
ps = load('psi_tf3.mat');
[numPs,denPs] = tfdata(ps.tf4);
Hps = tf(numPs, denPs);
Hps = zpk(minreal(Hps));
yPs = lsim(Hps, u, t);

figure;
plot (t, [psi yPs]);
%axis([0 80 0.057 0.065]);
legend('theta', 'yTh'); title('Model PSI');

%PSIDOT
HpsDot = series(Hps,tf([1 0], 1));

yPsdot = lsim(HpsDot, u, t);
figure;
plot (t, [psidot yPsdot]);
axis([0 80 0.057 0.065]);
legend('PSI', 'yPs'); title('Model PSIDOT');

%PHI
ph1 = load('phi_oe8.mat');
ph2 = load('phi_oe10.mat');
[Aph1, Bph1, Cph1, Dph1, Fph1] = polydata(ph1.oe881);
[Aph2, Bph2, Cph2, Dph2, Fph2] = polydata(ph2.oe10101);
Hph1 = tf(Bph1, Fph1, 1, 'variable', 'z^-1');
Hph1 = zpk(minreal(Hph1));
Hph2 = tf(Bph2, Fph2, 1, 'variable', 'z^-1');
Hph2 = zpk(minreal(Hph2));
yPh1 = lsim(Hph1, u);
yPh2 = lsim(Hph2, u);

figure;
plot ([phi yPh1]);
axis([0 80 -10e-5 10e-5]);
legend('theta', 'yTh'); title('Model PHI1');
figure;
plot ([phi yPh2]);
axis([0 80 -10e-5 10e-5]);
legend('theta', 'yTh'); title('Model PHI2');

%PHIDOT
phdot = load('phidot_model.mat');
[Aphd, Bphd, Cphd, Dphd, Fphd] = polydata(phdot.oe10101);