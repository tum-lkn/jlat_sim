function B=bursty_traffic_sim(Xp,Xn,maxiterationcount)

start=true;
state=0;
%maxiterationcount=100;
B=zeros(maxiterationcount,1);


random_pack=random('uniform',0,1,1,maxiterationcount);

if random_pack(1)<0.5
    state=1;
else
    state=-1;
end

B(1)=state;

    for i=2:maxiterationcount
       if state==1
           if random_pack(i)<1-Xp(i)
               state=-1;
           end
       else
           if random_pack(i)<Xn(i)
               state=1;
           end
       end
       B(i)=state;
    end

end