%Computes the jlat of a given success fail stream
function jlat=computeJLAT(B)
D= (B==1);
order=1:length(D);
successes=order(D);

% First check if the moment of sending is in the list of successes
% if not find the next success and calculate latency.
j=1;
k=length(successes);
for i = 1:successes(k)
    if (successes(j)==i)
        latency(i)=1;
        j=j+1;
    else
        latency(i)=successes(j)-i+1;
    end
end



%cutoffpmf
%This cutoff should be around one order of magnitude higher than deadline
cutoff=20;

denominator=length(D);
jlat=zeros(cutoff,1);
%normalize with cut-off
for i=1:cutoff
    select=(latency==i);
    jlat(i)=sum((select))/denominator;
end








end