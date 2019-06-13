function [ W ] = matr_regr( na, nb, m )
%Functia matr_regr returneaza o matrice de puteri, contruita in functide de
%conditiile m, na si nb impuse in programul principal.
%m reprzinta numarul maxim pe care il poate avea un element din matrice
%na+nb= numarul de coloane a matricei W
%Matrice finala va contine pe fiecare linie o serie cifre care reprezinta puterile 
%la care  care va fi ridicat fiecare element al vectorului de intrari si iesiri intarziate.

m1=[];%matricea de puteri pentru vectorul de iesire intarziate (y)
m2=[];%matricea de puteri pentru vectorul de intrare intarziate (u)
it=m*(m+1);%numarul maxim care trebuie scris in baza m+1 pentru obtinerea puterii maxime m
for i=0:it
    nr=str2num(dec2base(i, m+1));%scrierea numarului i in baza m+1
    n1=round(nr/10);
    n2=rem(nr, 10);
    %pentru termenul liber
    if (n1==0&&n2==0)
        w1=zeros(na, na);
        w2=zeros(nb, nb);
        %se adauga in matrice finala na+nb linii si coloane, cate o linie pentru fiecare
        %termen liber (fiecare element din vectorul de intrari si iesiri intarziate)
    end
    %pentru vectorul de intrari intarziate
    if (n1==0&&n2~=0)
        w1=zeros(na, na);%toate iesirile intarziate sunt ridicate la puterea 0
        w2=zeros(nb, nb);
        for j=1:nb
            w2(j, j)=n2;%toate intrarile intarziate sunt ridicate la puterea curenta
        end
    end
    %pentru vectorul de iesiri intarziate
    if (n2==0&&n1~=0)
        w1=zeros(na, na);%toate intarrile intarziate sunt ridicate la puterea zero
        w2=zeros(nb, nb);
            for j=1:na
                w1(j, j)=n1;%toate iesirile intarziate sunt riicate la puterea curenta
            end
    end
    %pentru combinatiile de termeni
    if(n1>0&&n2>0)
        w1=[]; w2=[];
        for k=1:na
            b1=zeros(na, na);
            b2=zeros(nb, nb);
            b1(:, k)=n1;%iesire curenta se ridica la puterea n1 pentru fiecare intrare intarziata in parte
            for j=1:nb
                b2(j, j)=n2;
            end
            w1=[w1; b1];
            w2=[w2; b2];
        end
    end
    m1=[m1; w1];
    m2=[m2; w2];
      
end
    
W=[m1, m2];
%eliminarea liniilor care au suma cifrelor mai mare decat 'm'
del=find(sum(W, 2)>m);
W(del, :)=[];

end

