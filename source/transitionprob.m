%% Transition function for burstiness
function [Xp,Xn]=transitionprob(beta,maxiterationcount)


Xp=zeros(maxiterationcount,1);
Xn=zeros(maxiterationcount,1);

    for i=1:maxiterationcount
        r=rand;
        while r<beta
           r=rand;
        end
        Xp(i)=r;
        Xn(i)=r-beta;     
    end

end