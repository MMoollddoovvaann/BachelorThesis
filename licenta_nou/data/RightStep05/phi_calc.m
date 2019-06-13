function [ FI ] = phi_calc( na, nb, u, y, W )
%phi_calc realizeaza construirea matricei de aproximari 
%construirea acestei matrice consta in concatenarea 
%a N polinoame de aproximare
%Vectrorul de intrari si iesiri intarziate depinde de na si nb alese.
%Construirea unui polinom de aproximare consta in inmultirea vectorului d,
%pe rand, cu fiecare linie a matricei W.
%Pentru determinarea unui polinom din aceasta matrice se foloseste 
%matrice W de puteri determinata anterior.

FI=[];
%Conditii initiale nule
y=[zeros(na+nb, 1); y];
u=[zeros(na+nb, 1); u];
N=length(y);
for i=na+nb+1:N
    %vectorul de intrari si iesiri intarziate
    d1 = -y(i-1:-1:i-na);
    d2=u(i-1:-1:i-nb);
    d=[d1; d2]; 
    ln=[];
    %Construirea polinomului de aproximare
    for j=1:size(W, 1)
        mm= prod(d'.^W(j, :));
         ln=[ln, mm];
    end
    %concatenarea in matricea de aproximare
    FI=[FI; ln];
end

end

