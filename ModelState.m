D6= zeros(6,2);
load('ABC_buildin.mat');

Hf_MIMO = ss(A6, B6, C6, D6)