function [estmean] = emergence(x,num)
len = 100000;
lambdaMax = 9.5;

maxTime = 24*60*12;
warmupTime = 24*60*2;
firstArrivalAfterWarmUp = 0;

ambarr = ones(1,num);
rec = ones(1,num);
lab = ones(1,num);
exam = ones(1,num);
reexam = ones(1,num);
treat = ones(1,num);
emer = ones(1,num);
AR = ones(1,num);
Unif = ones(1,num);

ambarrtime = exprnd (30,num,len);

rectime = exprnd (7.5,num,len);
labtime = unifrnd(0,1,num,len);
examtime = exprnd (15,num,len);
reexamtime = exprnd (9,num,len);
treattime = unifrnd(0,1,num,len);
emertime = exprnd(90,num,len);

ARtime = exprnd(60/lambdaMax,num,len);
Uniftime = unifrnd(0,1,num,len);

for i=1:num
    
    recqueue = zeros(2,1);
    examqueue = zeros(3,1);
    labqueue = zeros(2,1);
    treatqueue = zeros(2,1);
    emerqueue = zeros(2,1);
    
    Events = zeros(3,2);
    
    done = 0;
    
    next = 0;
    arrivalRates = [5.25 3.8 3 4.8 7 8.25 9 7.75 7.75 8 6.5 3.25];
    while done==0
        next = next + ARtime(i,AR(i));
        AR(i)=AR(i)+1;
        u = Uniftime(i,Unif(i));
        Unif(i)=Unif(i)+1;
        if (u <= arrivalRates(1+floor(mod(next/60,24)/2))/lambdaMax)
            done = 1;
        end
    end
    
    Events(:,1) = [next;1;1];
    Events(:,2) = [ambarrtime(i,ambarr(i));2;2];
    ambarr(i) = ambarr(i)+1;
    nArrivals = 2;
    
    if (next >=warmupTime && firstArrivalAfterWarmUp ==0)
        firstArrivalAfterWarmUp = 1;
    elseif (Events(1,2) >= warmupTime && firstArrivalAfterWarmUp ==0)
        firstArrivalAfterWarmUp = 2;
    end
    
    [~,nextEvent] = min(Events(1,:));
    Time = Events(1,nextEvent);
    Type = Events(2,nextEvent);
    Customer = Events(3,nextEvent);
    
    waitingTimes = zeros(2,2);
    nExits=0;
    
    while (Time <= maxTime)
        
        if Type ==1
            if (x(1) >0)
                sTime = rectime(i,rec(i));
                rec(i)=rec(i)+1;
                Events=[Events [(Time+sTime);3;Customer]];
                x(1)=x(1)-1;
            else
                recqueue = [recqueue [Customer;Time]];
            end
            
            nArrivals = nArrivals +1;
            waitingTimes = [waitingTimes zeros(2,1)];
            done = 0;
            next = Time;
            while done==0
                next = next + ARtime(i,AR(i));
                AR(i) = AR(i)+1;
                u = Uniftime(i,Unif(i));
                Unif(i)=Unif(i)+1;
                if (u <= arrivalRates(1+floor(mod(next/60,24)/2))/lambdaMax)
                    done = 1;
                end
            end
            Events = [Events [next;1;nArrivals]];
            
            if(next >= warmupTime && firstArrivalAfterWarmUp ==0)
                firstArrivalAfterWarmUp = nArrivals;
            end
            
        elseif Type==2
            
            if (x(2) > 0)
                x(2)=x(2)-1;
                sTime = examtime(i,exam(i));
                exam(i)=exam(i)+1;
                u = Uniftime(i,Unif(i));
                Unif(i) = Unif(i)+1;
                if (u <=0.5)
                    Events = [Events [(Time+sTime);4;Customer]];
                elseif (u <= 0.7)
                    Events = [Events [(Time+sTime);5;Customer]];
                elseif (u <= 0.9)
                    Events = [Events [(Time+sTime);6;Customer]];
                else
                    Events = [Events [(Time+sTime);7;Customer]];
                end
            else %¼±¾ÈÐèÒªµÈ´ý
                examqueue = [examqueue [Customer;Time;0]];
            end
            
            nArrivals = nArrivals +1;
            next = Time + ambarrtime(i,ambarr(i));
            ambarr(i) = ambarr(i)+1;
            Events = [Events [next;2;nArrivals]];
            waitingTimes = [waitingTimes zeros(2,1)];
            
            if(next >= warmupTime && firstArrivalAfterWarmUp ==0)
                firstArrivalAfterWarmUp = nArrivals;
            end
            
        elseif Type==3
            if (length(recqueue(1,:)) > 1)
                waitingTimes(1,recqueue(1,2)) = waitingTimes(1,recqueue(1,2))+(Time - recqueue(2,2));
                sTime = rectime(i,rec(i));
                rec(i)=rec(i)+1;
                Events = [Events [(Time+sTime);3;recqueue(1,2)]];
                recqueue(:,2)=[];
            else
                x(1)=x(1)+1;
            end
            
            if (x(2) > 0)
                x(2) = x(2)-1;
                sTime = examtime(i,exam(i));
                exam(i)=exam(i)+1;
                u = Uniftime(i,Unif(i));
                Unif(i) = Unif(i)+1;
                if (u <= 0.5)
                    Events = [Events [(Time+sTime);4;Customer]];
                elseif (u <= 0.7)
                    Events = [Events [(Time+sTime);5;Customer]];
                elseif (u <= 0.9)
                    Events = [Events [(Time+sTime);6;Customer]];
                else
                    Events = [Events [(Time+sTime);7;Customer]];
                end
            else
                examqueue = [examqueue [Customer;Time;0]];
            end
            
        elseif Type == 4
            if (length(examqueue(1,:)) > 1)
                waitingTimes(1,examqueue(1,2)) = waitingTimes(1,examqueue(1,2))+(Time - examqueue(2,2));
                
                if (examqueue(3,2)==1)
                    sTime = reexamtime(i,reexam(i));
                    reexam(i) = reexam(i)+1;
                else
                    sTime = examtime(i,exam(i));
                    exam(i) = exam(i)+1;
                end
                
                u = Uniftime(i,Unif(i));
                Unif(i) = Unif(i)+1;
                if (u <= 0.5)
                    Events = [Events [(Time+sTime);4;examqueue(1,2)]];
                elseif (u <= 0.7)
                    Events = [Events [(Time+sTime);5;examqueue(1,2)]];
                elseif (u <= 0.9)
                    Events = [Events [(Time+sTime);6;examqueue(1,2)]];
                else
                    Events = [Events [(Time+sTime);7;examqueue(1,2)]];
                end
                examqueue(:,2) = [];
            else
                x(2) = x(2)+1;
            end
            
            if (x(3) > 0)
                u = labtime(i,lab(i));
                lab(i)=lab(i)+1;
                if (u<0.5)
                    sTime = 10+sqrt(200*u);
                else
                    sTime = 30-sqrt(200*(1-u));
                end
                Events = [Events [(Time+sTime);8;Customer]];
                x(3)=x(3)-1;
            else
                labqueue = [labqueue [Customer;Time]];
            end
            
        elseif Type == 5
            if(length(examqueue(1,:))>1)
                waitingTimes(1,examqueue(1,2)) = waitingTimes(1,examqueue(1,2)) + (Time - examqueue(2,2));
                
                if(examqueue(3,2)==1)
                    sTime = reexamtime(i,reexam(i));
                    reexam(i) = reexam(i)+1;
                else
                    sTime = examtime(i,exam(i));
                    exam(i) = exam(i)+1;
                end
                
                u = Uniftime(i,Unif(i));
                Unif(i) = Unif(i)+1;
                if (u <= 0.5)
                    Events = [Events [(Time+sTime);4;examqueue(1,2)]];
                elseif (u <= 0.7)
                    Events = [Events [(Time+sTime);5;examqueue(1,2)]];
                elseif (u <= 0.9)
                    Events = [Events [(Time+sTime);6;examqueue(1,2)]];
                else
                    Events = [Events [(Time+sTime);7;examqueue(1,2)]];
                end
                examqueue(:,2)=[];
            else
                x(2) = x(2)+1;
            end
            
            if (x(4) > 0)
                x(4) = x(4) -1;
                u = treattime(i,treat(i));
                treat(i) = treat(i) +1;
                if (u<0.8)
                    sTime = 20+sqrt(80*u);
                else
                    sTime = 30-sqrt(20*(1-u));
                end
                Events = [Events [(Time+sTime);9;Customer]];
            else
                treatqueue = [treatqueue [Customer;Time]];
            end
            
        elseif Type == 6
            if(length(examqueue(1,:))>1)
                waitingTimes(1,examqueue(1,2)) = waitingTimes(1,examqueue(1,2)) + (Time - examqueue(2,2));
                
                if(examqueue(3,2)==1)
                    sTime = reexamtime(i,reexam(i));
                    reexam(i) = reexam(i)+1;
                else
                    sTime = examtime(i,exam(i));
                    exam(i) = exam(i)+1;
                end
                
                u = Uniftime(i,Unif(i));
                Unif(i) = Unif(i)+1;
                if (u <= 0.5)
                    Events = [Events [(Time+sTime);4;examqueue(1,2)]];
                elseif (u <= 0.7)
                    Events = [Events [(Time+sTime);5;examqueue(1,2)]];
                elseif (u <= 0.9)
                    Events = [Events [(Time+sTime);6;examqueue(1,2)]];
                else
                    Events = [Events [(Time+sTime);7;examqueue(1,2)]];
                end
                examqueue(:,2)=[];
            else
                x(2) = x(2)+1;
            end
            
            if (x(5) > 0)
                x(5) = x(5) -1;
                sTime = emertime(i,emer(i));
                emer(i) = emer(i)+1;
                Events = [Events [(Time+sTime);10;Customer]];
            else
                emerqueue = [emerqueue [Customer;Time]];
            end
            
        elseif Type==7
            
            waitingTimes(2,Customer) = 3;
            nExits = nExits +1;
            
            if(length(examqueue(1,:))>1)
                waitingTimes(1,examqueue(1,2)) = waitingTimes(1,examqueue(1,2)) + (Time - examqueue(2,2));
                
                if(examqueue(3,2)==1)
                    sTime = reexamtime(i,reexam(i));
                    reexam(i) = reexam(i)+1;
                else
                    sTime = examtime(i,exam(i));
                    exam(i) = exam(i)+1;
                end
                
                u = Uniftime(i,Unif(i));
                Unif(i) = Unif(i)+1;
                if (u <= 0.5)
                    Events = [Events [(Time+sTime);4;examqueue(1,2)]];
                elseif (u <= 0.7)
                    Events = [Events [(Time+sTime);5;examqueue(1,2)]];
                elseif (u <= 0.9)
                    Events = [Events [(Time+sTime);6;examqueue(1,2)]];
                else
                    Events = [Events [(Time+sTime);7;examqueue(1,2)]];
                end
                examqueue(:,2)=[];
            else
                x(2) = x(2)+1;
            end
            
        elseif Type == 8
            
            if(x(2)>0)
                sTime = reexamtime(i,reexam(i));
                reexam(i) = reexam(i)+1;
                u=Uniftime(i,Unif(i));
                Unif(i) = Unif(i)+1;
                if (u <= 0.5)
                    Events = [Events [(Time+sTime);4;Customer]];
                elseif (u <= 0.7)
                    Events = [Events [(Time+sTime);5;Customer]];
                elseif (u <= 0.9)
                    Events = [Events [(Time+sTime);6;Customer]];
                else
                    Events = [Events [(Time+sTime);7;Customer]];
                end
                x(2)=x(2)-1;
            else
                examqueue = [examqueue [Customer;Time;1]];
            end
            
            if(length(labqueue(1,:))>1)
                waitingTimes(1,labqueue(1,2)) = waitingTimes(1,labqueue(1,2)) + (Time - labqueue(2,2));
                u = labtime(i,lab(i));
                lab(i)=lab(i)+1;
                
                if (u <= 0.5)
                    sTime = 10+sqrt(200*u);
                else
                    sTime = 30-sqrt(200*(1-u));
                end
                Events = [Events [(Time+sTime);8;labqueue(1,2)]];
                labqueue(:,2)=[];
            else
                x(3) = x(3)+1;
            end
            
        elseif Type == 9
            nExits = nExits +1;
            waitingTimes(2,Customer) = 2;
            
            if (length(treatqueue(1,:))>1)
                waitingTimes(1,treatqueue(1,2)) = waitingTimes(1,treatqueue(1,2)) + (Time - treatqueue(2,2));
                u = treattime(i,treat(i));
                treat(i)=treat(i)+1;
                if (u < 0.8)
                    sTime = 20+sqrt(80*u);
                else
                    sTime = 30-sqrt(20*(1-u));
                end
                Events = [Events [(Time+sTime);9;treatqueue(1,2)]];
                treatqueue(:,2)=[];
            else
                x(4)=x(4)+1;
            end
            
        elseif Type == 10
            nExits = nExits + 1;
            waitingTimes(2,Customer) = 1;
            
            if (length(emerqueue(1,:))>1)
                waitingTimes(1,emerqueue(1,2)) = waitingTimes(1,emerqueue(1,2)) + (Time - emerqueue(2,2));
                sTime = emertime(i,emer(i));
                emer(i) = emer(i)+1;
                Events = [Events [(Time+sTime);10;emerqueue(1,2)]];
                emerqueue(:,2)=[];
            else
                x(5)=x(5)+1;
            end
        end
        
        Events(:,nextEvent) = [];
        [~,nextEvent] = min(Events(1,:));
        Time = Events(1,nextEvent);
        Type = Events(2,nextEvent);
        Customer = Events(3,nextEvent);
    end
    
    totalWT = zeros(3,1);
    nCustomers = zeros(3,1);
    for j = firstArrivalAfterWarmUp:length(waitingTimes)
        typ = waitingTimes(2,j);
        if typ~=0
            totalWT(typ) = totalWT(typ) + waitingTimes(1,j);
            nCustomers(typ) =  nCustomers(typ)+1;
        end
    end
    avgWT = totalWT./nCustomers;
    throughput = nExits/(maxTime/60);
end
estmean = avgWT(1,:);
end