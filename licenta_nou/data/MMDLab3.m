hf=tf(2, [10, 11, 1], 'IODelay', 1);
w=0.2968;
ti=4/w;
mod=2/sqrt((w^2+1)*(100*w^2+1));
kp=1/mod;
hc=tf(kp*[ti, 1], [ti, 0]);
hd=series(hc, hf);

hdz=c2d(hd, 0.1, 'tustin');
hoz=feedback(hdz, 1);
[num, den]=tfdata(hoz, 'v');

u(1)=1.64;
e(1)=1;
y=dstep(num, den);
r=ones(length(y), 1);

for k=2:length(y)
    
    e(k)=r(k)-y(k);
    u(k)=u(k-1)+1.64*e(k)-1.627*e(k-1);

end
figure;
plot(u)
hold on
plot(y, 'r')