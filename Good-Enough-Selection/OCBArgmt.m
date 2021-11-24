function [PCS,N]=OCBArgmt(k,n0,T,mu0,sigma0,sigma,num,m)
PCS=zeros(1,T);
truemu=zeros(1,k);
X0=zeros(n0,k);
I=zeros(1,k-m);
tic

for t=1:num
    for i=1:k
        truemu(i)=normrnd(mu0(i),(sigma0(i))^(1/2));
    end
    for i=1:n0
        X0(i,:)=normrnd(truemu,sigma.^(1/2));
    end
    estmean=mean(X0);
    estvar=var(X0,1);
    N=n0*ones(1,k);
    pv=(1./sigma0+N./estvar).^(-1);
    pm=pv.*(mu0./sigma0+N.*estmean./estvar);
    Nrv=normrnd(0,1,1,T);
    
    for budget=1:T
        [~,id4]=sort(pm,'descend');
        id4 = id4(1:m);
        ree = setdiff((1:k),id4);
        
        if sum(truemu(id4)>max(truemu(ree)))>=1
            PCS(budget)=PCS(budget)+1/num;
        end
        
        [~,nm]=sort(estmean,'descend');
        
        Sn=zeros(1,k-m+1);
        Sn(1) = nm(1);
        Sn(2:end) = nm((m+1):k);
        
        u0 = N(Sn(1))^2/estvar(Sn(1));
        
        un = sum(N(Sn(2:end)).^2./estvar(Sn(2:end)));
        
        
        if u0<un
            id2=Sn(1);
        else
            ww=N(Sn(1:end))./sum(N(Sn(1:end)));
            for i=1:(k-m)
                I(i)=(truemu(Sn(1))-truemu(Sn(i+1)))^2/(estvar(Sn(1))/ww(1)+estvar(Sn(i+1))/ww(i+1));    
            end
            b=find(I==min(I));
            id2=Sn(b+1);
        end
        
        mm=estmean(id2);
        x=truemu(id2)+(sigma(id2)).^(1/2).*Nrv(budget);
        estmean(id2)=(estmean(id2).*N(id2)+x)./(N(id2)+1);
        estvar(id2)=(N(id2)./(N(id2)+1)).*(estvar(id2)+(mm-x).^2./(N(id2)+1));
        N(id2)=N(id2)+1;
        
        pv(id2)=(1./sigma0(id2)+N(id2)./estvar(id2))^(-1);
        pm(id2)=pv(id2).*(mu0(id2)./sigma0(id2)+N(id2).*estmean(id2)./estvar(id2));
    end
end
toc
end