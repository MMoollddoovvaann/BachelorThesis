close all; clear all; clc;
l = load ('bst05.mat');
data = l.BothSt05;
t = data.time;
n = length(t);
uL = (t>=0)*0.5;
uR = (t>=0)*0.5;
Te = 0.003;

%% Plot Date
left = data.signals(1).values;
dataLeft = iddata(left,[uL, uR], Te);
figure;
plot(dataLeft); title('LEFT');

right = data.signals(2).values;
dataRight = iddata(right,[uL, uR], Te);
figure;
plot(dataRight); title('RIGHT');

acceX = data.signals(3).values;
dataAcceXval = iddata(acceX,[uL uR], Te);
dataAcceXid = iddata(acceX,left, Te);
figure;
plot(dataAcceXid); title('AcceX');

acceY = data.signals(4).values;
dataAcceY = iddata(acceY,[uL, uR], Te);
figure;
plot(dataAcceY); title('AcceY');

gyro = data.signals(5).values;
dataGyro = iddata(gyro,[uL, uR], Te);
figure;
plot(dataGyro); title('GYRO');
%%
data6 = iddata([left, right, acceX, acceY, gyro],[uL uR], Te);

%% Extragere modele & Simulare
%Left
Options = tfestOptions;
Options.InitialCondition = 'backcast';
Hleft = tfest(dataLeft, [1 1], [0 0], Options, 'Ts', Te);
compare(dataLeft, Hleft);

%Right
%Hright = tfest(dataRight, [1 1], [0 0], Options, 'Ts', 0.003);
Hright = Hleft;
compare(dataRight, Hright);

%AcceX
Options = tfestOptions;
Options.InitialCondition = 'backcast';                                
HacceXid = tfest(dataAcceXid, 3, 3, Options, 'Ts', 0.003, 'Feedthrough', true);
HacceXval = Hleft*HacceXid;
compare(dataAcceXval, HacceXval);

%PSI
Options = tfestOptions;                                      
Hps = tfest(dataPSI, [7 7], [1 1], Options);
% compare(dataPSI, Hps);

%PSIDOT
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
