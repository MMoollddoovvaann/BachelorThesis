close all; clear all; clc;
l = load ('lst05.mat');
data = l.LeftSt05;
t = data.time;
u = (t>=0)*0.5;
u2 = (t>=0)*0;
n = length(t);
m=2;
na=3; nb=3;

%% Plot date
left = data.signals(1).values;
idLeft = iddata(left(1:900), u(1:900), 0.01);
valLeft = iddata(left(900+1:end), u(900+1:end), 0.01);
figure;
plot (idLeft); 
title('RightStep05 - Left ID')
figure; plot(valLeft); 
title('RightStep05 - Left VAL')

right = data.signals(1, 2).values;
idRight = iddata(right(1:800), u2(1:800), 0.01);
valRight = iddata(right(800+1:end-220), u2(800+1:end-220), 0.01);
figure;
plot (idRight);
title('RightStep05 - Right ID')
figure;
plot (valRight);
title('RightStep05 - Right VAL')

acceX = data.signals(1, 3).values;
idAcceX = iddata(acceX(1:900), u(1:900), 0.01);
valAcceX = iddata(acceX(900+1:end), u(900+1:end), 0.01);
figure;
plot (idAcceX);
title('RightStep05 - Right ID')
figure;
plot (valAcceX);
title('RightStep05 - Right VAL')

acceY = data.signals(1, 4).values;
idAcceY = iddata(acceY(1:900), u2(1:900), 0.01);
valAcceY = iddata(acceY(900+1:end), u2(900+1:end), 0.01);
figure;
plot (idAcceY);
title('RightStep05 - Right ID')
figure;
plot (valAcceY);
title('RightStep05 - Right VAL')

gyro = data.signals(1, 5).values;
idGyro = iddata(gyro(1:900), u(1:900), 0.01);
valGyro = iddata(gyro(900+1:end), u(900+1:end), 0.01);
figure;
plot (idGyro);
title('RightStep05 - Right ID')
figure;
plot (valGyro);
title('RightStep05 - Right VAL')

%% Citirea gradelor
m = input('m = ');
na = input('na = nb = ');
nb=na;
%plot(l.id)%reprezentarea datelor de identificare
% title('Date de ientificare');
% figure;plot(l.val);%reprezentarea datelor de validare
% title('Date de validare');
%Aproximarea
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

%Algoritm de aproximare folosind simularea
%Aproximarea pentru datele de identificare
%Folosim modelul obtinut din datele de identificare
u=[zeros(na+nb,1); u];%conditii initiale nule
y_sim_id=[];
y_sim_id=[y_sim_id; zeros(na+nb, 1)];%iseiri simulate, conditii initiale nule
Nu_id=length(idAcceX.u);
for i=na+nb+1:Nu_id
    %construirea vectorului de intrari si iesiri intariziate
    d1 = -y_sim_id(i-1:-1:i-na);
    d2=u(i-1:-1:i-nb);
    d=[d1; d2]; %vector coloana
    ln=[];
    %Simularea urmatoarei iesiri
    %Construirea polinomului de aproximare
    for j=1:size(W, 1)
        mm= prod(d'.^W(j, :));
         ln=[ln, mm];
    end
   y_sim_id=[y_sim_id; ln*theta];
end
figure;
plot([idAcceX.y, y_sim_id]);
legend('y', 'y.sim');
%Eroarea medie patratica
MSE_S_id=sum((y_sim_id-idAcceX.y).^2)/length(idAcceX.y);
title(['Date identificare.Algoritm de aproximare folosind simularea. MSE = ', num2str(MSE_S_id)]);

%Aproximarea pentru datele de validare
%Folosim modelul obtinut din datele de identificare
u1=l.val.u;
u1=[zeros(na+nb,1); u1];%conditii initiale nule
y_sim=[];
y_sim=[y_sim; zeros(na+nb, 1)];%iseiri simulate, conditii initiale nule
Nu=length(l.val.u);
for i=na+nb+1:Nu
    %construirea vectorului de intrari si iesiri intariziate
    d1 = -y_sim(i-1:-1:i-na);
    d2=u1(i-1:-1:i-nb);
    d=[d1; d2]; %vector coloana
    ln=[];
    %Simularea urmatoarei iesiri
    %Construirea polinomului de aproximare
    for j=1:size(W, 1)
        mm= prod(d'.^W(j, :));
         ln=[ln, mm];
    end
   y_sim=[y_sim; ln*theta];
end
figure;
plot([l.val.y, y_sim]);
legend('y', 'y.sim');
%Eroarea medie patratica
MSE_S=sum((y_sim-l.val.y).^2)/length(l.val.y);
title(['Date validare.Algoritm de aproximare folosind simularea. MSE = ', num2str(MSE_S)]);

%compararea simularii si a predictiei
figure;
plot([l.val.y, yhat, y_sim]);
legend('y', 'yhat', 'y.sim');
title('Compararea modelelor obtinute');

%Modele de aproximare optime pentru predictie si simulare
MSE_P=[]; minim_p=1e89; 
MSE_sim=[]; minim_s=1e89;
%Valoarea maxima admisa pentru m este 3
for i=1:3 
    L=[];
    S=[];
    %Valoarea maxima admisa pentru na=nb este 3
    for j=1:3
        W1=[]; Wo=[];
        %construirea unei noi matrice de puteri
        Wo=matr_regr(j, j, i);
        W1=prelW(Wo, 2*j);
        %Calculul matrice de aproximari
        ph=phi_calc(j, j, l.id.u, l.id.y, W1);
        %Calculul coficientilor de aproximare
        th=ph\l.id.y;
        %Validarea modelui obtinut anterior
        ph_p=phi_calc(j, j, l.val.u, l.val.y, W1);
        yhat_p=ph_p*th;
        %Eroarea medie patratica obtinuta din aproximare
        MSE_=sum((yhat_p-l.val.y).^2)/length(l.val.y);
        %Folosind modelul anterior, se face aproximarea prin simulare
        %Se calculeaza, in aceeasi functie si Eroarea medie patratica
        MSE_ss=mse_simulare(l.val.u, l.val.y, j, j, th, W1);
        L=[L, MSE_];
        S=[S, MSE_ss];
    end
    %Se ia valoarea minima a Eriorii medie patratica pentru gradul m curent
    %si na=nb=1, 2, 3, aflata din simularile antrioare
    if (minim_p>min(L)) %minimiul in aproximarea prin predictie
        minim_p=min(L);
        yy = find(L==min(L));
        xx=i;
    end
    if (minim_s>min(S)) %minimul in aproximarea prin simulare
        minim_s=min(S);
        ys = find(S==min(S));
        xs=i;
    end
    MSE_P=[MSE_P; L];
    MSE_sim=[MSE_sim; S];
end
%Reprezentarea rezultatelor obtinute
%Predictie
figure;
plot(1:3, MSE_P(1, :), '*b');hold on;
plot(1:3, MSE_P(2, :), '*r'); hold on;
plot(1:3, MSE_P(3, :), '*g');
legend('m=1', 'm=2', 'm=3')
xlabel('na=nb'); ylabel('MSE')
title(['Predictie. Ordin optim de aproximare: m=', num2str(xx), ' na=nb=', num2str(yy), ' MSE= ' num2str(MSE_P(xx, yy))]);

%Simulare
figure;
plot(1:3, MSE_sim(1, :), '*b');hold on;
plot(1:3, MSE_sim(2, :), '*r'); hold on;
plot(1:3, MSE_sim(3, :), '*g');
legend('m=1', 'm=2', 'm=3')
title(['Simulare. Ordin optim de aproximare: m=', num2str(xs), ' na=nb=', num2str(ys), ' MSE= ' num2str(MSE_sim(xs, ys))]);
xlabel('na=nb'); ylabel('MSE');
%ProiectIS_2
%Moldovan Maria si Lupo Madalina