function [estmean,estvar] = inventory(s,S,num)
pmm = zeros(1,num);

for t=1:num
    I=zeros(1,n);
    I(1)=S;
    J=zeros(1,n);
    J(1)=S;
    D=random('Poisson',lambda,1,n);
    
    HC=zeros(1,n);
    SC=zeros(1,n);
    OC=zeros(1,n);
    
    if J(1)-D(1) >=0
        HC(1) = J(1) - D(1);
    else
        SC(1) = 5*(D(1)-J(1));
    end
    
    for i=2:n
        I(i)= J(i-1) - D(i-1);
        if I(i) < s
            OC(i) = 32 + 3*(S - I(i));
            J(i) = S;
        else
            J(i) = I(i);
        end
        if J(i)-D(i) >=0
            HC(i) = J(i) - D(i);
        else
            SC(i) = 5*(D(i)-J(i));
        end
    end
    TC = sum(HC) + sum(SC) + sum(OC);
    pmm(t) = TC/n;
end
estmean = sum(pmm)/num;
estvar = sum((pmm-estmean).^2)/num;
end