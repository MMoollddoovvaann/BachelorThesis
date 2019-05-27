close all; clear all; clc;
l = load('checkstuff.mat');
data = l.check;
t = data.time;
Te = 0.003;
uL = (t>=0)*0.25;
uR = (t>=0)*0.25;
n = length(t);
r = (t>=0).*t;

%% Plot date - micsorare per de esantionare
theta = data.signals(1,1).values;
dataTH = iddata(theta,[uL, uR],Te);
% figure;
% plot(dataTH); title('THETA');

thetadot = data.signals(1, 2).values;
dataTHdot = iddata(thetadot,theta,Te);
dataTHdotV = iddata(thetadot,[uL, uR],Te);
% figure;
% plot (dataTHdot); title('THETADOT');

phi = data.signals(1, 5).values;
dataPhi = iddata(phi,[uL, uR],Te);
%figure;
%plot (dataPhi); title('PHI');

phidot = data.signals(1, 6).values;
dataPHId = iddata(phidot,phi,Te);
dataPHIdV = iddata(phidot,[uL, uR],Te);
% figure;
% plot (dataPHId); title('PHIDOT');

psi = data.signals(1, 3).values;
dataPSI = iddata(psi,[uL, uR],Te);
% figure;
% plot (dataPSI); title('PSI');

psidot= data.signals(1, 4).values;
dataPSdot = iddata(psidot,psi,Te);
dataPSdotV = iddata(psidot,[uL, uR],Te);
% figure;
% plot (dataPSdot); title('PSIDOT');

%% Extragere modele & Simulare
%THETA
Options = tfestOptions;                                      
Hth= tfest(dataTH, [4 4], [4 4], Options);
% compare(dataTH, Hth);

%THETADOT
Options = tfestOptions;
Options.InitialCondition = 'estimate';
Hthdot= tfest(dataTHdot, 1, 1, Options);
compare(dataTHdot, Hthdot);
HthdotV = Hth*Hthdot;
compare(dataTHdotV, HthdotV);

%PSI
Options = tfestOptions;                                      
Hps = tfest(dataPSI, [7 7], [1 1], Options);
compare(dataPSI, Hps);

%PSIDOT
Options = tfestOptions;
Options.InitMethod = 'n4sid';
Options.InitialCondition = 'backcast';
Hpsdot = tfest(dataPSdot, 1, 1, Options);
compare(dataPSdot, Hpsdot);
HpsdotV = Hps*Hpsdot;
compare(dataPSdotV, HpsdotV);

%PHI
Options = tfestOptions;                   
np = [4 4];
nz = [2 2];
num = arrayfun(@(x)NaN(1,x), nz+1,'UniformOutput',false);
den = arrayfun(@(x)[1, NaN(1,x)],np,'UniformOutput',false);
% Prepare input/output delay                               
iodValue = [1 1];                                          
iodFree = [false false];                                   
iodMin = [0 0];                                            
iodMax = [0.09 0.09];                                      
sysinit = idtf(num, den, 0);                               
 for j = 1:2                                                
    iod_j = sysinit.Structure(j).ioDelay;                   
    iod_j.Value = iodValue(j);                              
    iod_j.Free = iodFree(j);                                
    iod_j.Maximum = iodMax(j);                              
    iod_j.Minimum = iodMin(j);                              
    sysinit.Structure(j).ioDelay = iod_j;                   
 end                                                        
                                                            
% Perform estimation using "sysinit" as template           
Hph = tfest(dataPhi, sysinit, Options); 
compare(dataPhi, Hph);

%PHIDOT
Options = tfestOptions;                  
Hphdot = tfest(dataPHId, 1, 1, Options);
compare(dataPHId, Hphdot);
HphdotV = Hph*Hphdot;
compare(dataPHIdV, HphdotV);

%% Minimase
% THETA
% Compute second-order approximation
Options = tfestOptions;
Options.InitMethod = 'svf';
Options.InitialCondition = 'backcast';
Hth = tfest(dataTH, [2 2], [2 2], Options);
compare(dataTH, Hth);

% THETADOT
opt = balredOptions('Offset',.00001,'StateElimMethod','MatchDC');
% Compute second-order approximation
HthdotV = tf(HthdotV);
HthdotV = balred(HthdotV, 2, opt);
compare(dataTHdotV, HthdotV);
HthdotV = idtf(HthdotV);

% PSI
Options = tfestOptions;
Options.InitMethod = 'all';
Hps = tfest(dataPSI, [2 2], [1 1], Options);
compare(dataPSI, Hps);

% PSIDOT-no minimisation necessary (already of secound order)
Options = tfestOptions;
Options.InitMethod = 'all';
Options.InitialCondition = 'estimate';
HpsdotV = tfest(dataPSdotV, [2 2], [1 1], Options);
compare(dataPSdotV, HpsdotV);

% PHI
Options = tfestOptions;
Options.InitialCondition = 'backcast';
Hph = tfest(dataPhi, [2 2], [2 2], Options);
compare(dataPhi, Hph);

% PHIDOT-no minimisation necessary (already of secound order)
HphdotV = tf(HphdotV);
HphdotV = balred(HphdotV, 2);
compare(dataPHIdV, HphdotV);
HphdotV = idtf(HphdotV);

%% MIMO tf
Hf_MIMO = [Hth(1,1) Hth(1,2);...
           HthdotV(1,1) HthdotV(1,2);...
           Hps(1,1) Hps(1,2); ...
           HpsdotV(1,1) HpsdotV(1,2);....
           Hph(1,1) Hph(1,2);...
           HphdotV(1,1) HphdotV(1,2)];
Hf_MIMO = ss(Hf_MIMO);
% Hfd_MIMO = ss(Hfd_MIMO);
%calcul lqr individual pentru fiecare sistem descentralizat ]n parte


%% LQR MIMO Control
% MIMO: THETA, PSI, PHI
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

Q=0.1*eye(size(Hf_MIMO.a));
R = eye(2);
K = lqr(Hf_MIMO.a, Hf_MIMO.b, Q, R)

%% LQG MIMO Control
% MIMO: THETA, PSI, PHI
Q=eye(8);
R=eye(9);
K_g = lqg(Hf_MIMO, Q, R)


