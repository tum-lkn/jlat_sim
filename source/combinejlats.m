% Combining jlat of one link to that of a path
function jlatc=combinejlats(jlat1,jlat2)

jlatc=zeros(length(jlat1),1);
jlatc(1)=0;
for i=2:length(jlat1)
    dummy=0;
    for j=1:i-1
        dummy=dummy+jlat1(j)*jlat2(i-j);
    end
    jlatc(i)=dummy;
end

end