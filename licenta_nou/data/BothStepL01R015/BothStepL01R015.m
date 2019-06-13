close all; clear all; clc;
l = load ('BL01R015.mat');
data = l.BothL01R015;
t = data.time;
n = length(t);
u = (t>=0)*0.5;
m=2; na=3;
nb=3;

%% Plot Date
left = data.signals(1).values;
idLeft = iddata(left(1:n/2), u(1:n/2), 0.01);
valLeft = iddata(left(n/2+1:end), u(n/2+1:end), 0.01);
figure;
plot (t, left); grid
title('BothStepL01R015 - Left')

right = data.signals(1, 2).values;
idRight = iddata(right(1:n/2), u(1:n/2), 0.01);
valRight = iddata(right(n/2+1:end), u(n/2+1:end), 0.01);
figure;
plot (t, right); grid
title('BothStepL01R015 - Right')

acceX = data.signals(1, 3).values;
idAcceX = iddata(acceX(1:n/2), u(1:n/2), 0.01);
valAcceX = iddata(acceX(n/2+1:end), u(n/2+1:end), 0.01);
figure;
plot (t, acceX); grid
title('BothStepL01R015 - AcceX')

acceY = data.signals(1, 4).values;
idAcceY = iddata(acceY(1:n/2), u(1:n/2), 0.01);
valAcceY = iddata(acceY(n/2+1:end), u(n/2+1:end), 0.01);
figure;
plot (t, acceY); grid
title('BothStepL01R015 - AcceY')

gyro = data.signals(1, 5).values;
idGyro = iddata(gyro(1:n/2), u(1:n/2), 0.01);
valGyro = iddata(gyro(n/2+1:end), u(n/2+1:end), 0.01);
figure;
plot (t, gyro); grid
title('BothStepL01R015 - Gyro')

%% Identificare
%Left
modelLeft=arx(idLeft, [3, 1, 1]);
figure;
compare (modelLeft, valLeft)
HL=tf(modelLeft.B, modelLeft.A, 1, 'variable', 'z^-1');%functia de transfer pentru aproximare

%Right
modelRight=arx(idRight, [7, 1, 1]);
figure;
compare (modelRight, valRight)
HR=tf(modelRight.B, modelRight.A, 1, 'variable', 'z^-1');%functia de transfer pentru aproximare

%AcceX
W0=matr_regr(na, nb, m);%matricea de puteri
W=prelW(W0, na+nb);%matrice de puteri prelucrata

%Algoritm de aproximare folosind predictia
%construirea matricei de polinoame de aproximare
FI=phi_calc(na, nb, u, idAcceX.y, W);%construirea se faceconform gradelor de aproximare date
theta=FI\idAcceX.y; %vectorul de coeficienti de aproximare
yhat_id=FI*theta;
figure;
plot([idAcceX.y, yhat_id])
legend('y', 'yhat');
%Eroarea medie patratica
MSE_id=sum((yhat_id-idAcceX.y).^2)/length(idAcceX.y);
title(['Date identificare. Algoritm de aproximare folosind predictia. MSE = ', num2str(MSE_id)]);

%Verificarea modelului obtinut folosind datele de validare 
phi=phi_calc(na, nb, valAcceX.u, valAcceX.y, W);
yhat=phi*theta;%iesirea aproximata
figure;
plot([valAcceX.y, yhat])
legend('y', 'yhat');
%Eroarea medie patratica
MSE=sum((yhat-valAcceX.y).^2)/length(valAcceX.y);
title(['Date validare. Algoritm de aproximare folosind predictia. MSE = ', num2str(MSE)]);



%AcceY
% W0Y=matr_regr(na, nb, m);%matricea de puteri
% WY=prelW(W0, na+nb);%matrice de puteri prelucrata

%Algoritm de aproximare folosind predictia
%construirea matricei de polinoame de aproximare
FIY=phi_calc(na, nb, u, idAcceY.y, W);%construirea se faceconform gradelor de aproximare date
thetaY=FIY\idAcceY.y; %vectorul de coeficienti de aproximare
yhat_idY=FIY*thetaY;
figure;
plot([idAcceY.y, yhat_idY])
legend('y', 'yhat');
%Eroarea medie patratica
MSE_idY=sum((yhat_idY-idAcceY.y).^2)/length(idAcceY.y);
title(['Date identificare. Algoritm de aproximare folosind predictia. MSE = ', num2str(MSE_idY)]);

%Verificarea modelului obtinut folosind datele de validare 
phiY=phi_calc(na, nb, valAcceY.u, valAcceY.y, W);
yhatY=phiY*thetaY;%iesirea aproximata
figure;
plot([valAcceY.y, yhatY])
legend('y', 'yhat');
%Eroarea medie patratica
MSEY=sum((yhatY-valAcceY.y).^2)/length(valAcceY.y);
title(['Date validare. Algoritm de aproximare folosind predictia. MSE = ', num2str(MSEY)]);

%Gyro
%Algoritm de aproximare folosind predictia
%construirea matricei de polinoame de aproximare
FIG=phi_calc(na, nb, u, idGyro.y, W);%construirea se faceconform gradelor de aproximare date
thetaG=FIG\idGyro.y; %vectorul de coeficienti de aproximare
yhat_idG=FIG*thetaG;
figure;
plot([idGyro.y, yhat_idG])
legend('y', 'yhat');
%Eroarea medie patratica
MSE_idG=sum((yhat_idG-idGyro.y).^2)/length(idGyro.y);
title(['Date identificare. Algoritm de aproximare folosind predictia. MSE = ', num2str(MSE_idG)]);

%Verificarea modelului obtinut folosind datele de validare 
phiG=phi_calc(na, nb, valGyro.u, valGyro.y, W);
yhatG=phiG*thetaG;%iesirea aproximata
figure;
plot([valGyro.y, yhatG])
legend('y', 'yhat');
%Eroarea medie patratica
MSEG=sum((yhatG-valGyro.y).^2)/length(valGyro.y);
title(['Date validare. Algoritm de aproximare folosind predictia. MSE = ', num2str(MSEG)]);

