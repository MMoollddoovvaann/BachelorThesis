function [ W ] = prelW( W0, nr )
%Functia prelW determina si returneaza forma finala a matricei de puteri,
%in cadrul careia sunt incluse puterile polinomului final de aproximare,
%dupa inmultirea cu intrarile si iesirile intarizate.
%  Pentru aflarea formei finale a acestei matrice, se aduna, pe rand,
%  fiecare coloana cu 1; matrice obtinuta se concateneaza cu
%  celelalte matrici obtinute prin acelasi procedeu.

W=[];
 for r=1:nr
        W1=W0;
        W1(:, r)=W1(:, r)+ones(size(W0, 1), 1); %se aduna cifra 1 la fiecare linie din coloaba curenta
        W=[W; W1];%concatenarea
 end
 W=unique(W, 'rows'); %eliminare linii duplicate
 W=fliplr(W);
 %Se inverseaza matricea de la stanga la dreapta pentru ca polinomul final
 %sa aiba o forma apropriata, din punct de vedere a ordinii termenilor, de
 %cea a polinomului de aproximare descris in proiect.
 
end

