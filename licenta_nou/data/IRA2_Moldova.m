close all; clear all; clc;
l = load ('lst05.mat');
data = l.LeftSt05;

t = data.time;
left = data.signals(1).values(1:611);
plot (t(1:611), left); grid

right = data.signals(1, 2).values;
figure;
plot (t, right); grid

acceX = data.signals(1, 3).values;
figure;
plot (t, acceX); grid

acceY = data.signals(1, 4).values;
figure;
plot (t, acceY); grid

gyro = data.signals(1, 5).values;
figure;
plot (t, gyro); grid
%% Right Step 0.5
close all; clear all; clc;
l = load ('rst0.5.mat');
dataR = l.RSt05;

t = dataR.time;
right = dataR.signals(1).values();
plot (t, right); grid

%% Both Step 0.5
close all; clear all; clc;
l = load ('bst05.mat');
dataB5 = l.BothSt05;

t = dataB5.time;
right = dataB5.signals(1).values();
plot (t, right); grid