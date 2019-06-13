function [ MSE ] = mse_simulare( u, y, na, nb, th, W )
%Aceasta functie calculeaza si returneaza valoare Erorii medie patratica in
%urma aproximarii prin simulare.
%  Pentru aproximarea prin simulare se vafolosi acelasi algoritm ca cel
%  descris in proiectul principal: construirea vectorului de intrari di
%  iesiri intarziate 'd', determinarea polinomului de aproximare prin
%  ridecare lui d la puterile fiecarei linii din matrice W, determinarea
%  unei iesiri simulate.

Nu=length(u);
u=[zeros(na+nb,1); u];%conditii initiale nule
y_sim=[];
y_sim=[y_sim; zeros(na+nb, 1)];%conditii initiale nule
for i=na+nb+1:Nu
    d1 = -y_sim(i-1:-1:i-na);
    d2=u(i-1:-1:i-nb);
    d=[d1; d2]; %vector de iesiri si intrari intarziate
    ln=[];
    for j=1:size(W, 1)
        %determinarea polinomului de aproximare
        mm= prod(d'.^W(j, :));
         ln=[ln, mm];
    end
    %iesirea simulata
   y_sim=[y_sim; ln*th];
end
%Eroarea medie patratica
MSE=sum((y_sim-y).^2)/length(y);

end

