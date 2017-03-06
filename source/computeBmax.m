%% Calculation of the burstiness of a link 
% using the distance between two successful transmissions
% bmin allows to define a minimum packet successful packet size
function Bmax=computeBmax(B,bmin)
D=(B==1);
Bmax=0;
    for i=bmin+1:length(D)
    issatisfied=true;
    
    for j=1:length(D)-i
        Bp=sum(D(j:j+i-1));
        if Bp<bmin
            issatisfied=false;
            break;
        end
    end
    if issatisfied == true
        Bmax = i - bmin;
        return;
    end
    end
end