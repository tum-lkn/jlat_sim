%% Simulator for JLAT paper
% Simulation and plotting on same file

%% Parameter settings
% Number of nodes in the network
% A full connected mesh is generated.
% n-1 link quality for each of the nodes. 
N=4;
%number of nodes in topology

beta=0.8;
% for the first simulations only the effect of burst is observed. thus it
% is assumed that each link has the same burst.

realsize=10^6;
%training data set size
realdata=zeros(N,N-1,realsize);

paths=zeros(5,1);
%variable for saving routing decision for all paths

%% Generate loss statistics for each link
% If allows prioritization of one path
for i=1:N
    for j=1:N-1
            if (i==1 && j==1) || (i==2 && j==3)
                beta=0.01;
                betagood=beta;
            else
                beta=0.9;
                betabad=beta;
            end
            [Xp,Xn]=transitionprob(beta,realsize);
            %trainingdata(i,j,:)=squeeze(bursty_traffic_sim(Xp,Xn,trainingsize));
            realdata(i,j,:)=squeeze(bursty_traffic_sim(Xp,Xn,realsize));
    end
end


%Extract some part of the data for routing decisions
trainingdata=realdata(:,:,1:1000);

%% Use the training data to allocate routing decisions

% Path notation
% 1-4 (1)/ 1-2-4 (2)/ 1-3-4 (3)/ 1-2-3-4 (4)/ 1-3-2-4 (5)


%calculate metrics for routing decision.
% ETX
cutoff=20;
%limitofpmf for JLAT
etx=zeros(N,N-1);
burstmax=zeros(N,N-1);
jlat=zeros(N,N-1,cutoff);
%training data for routing decisions
for i=1:N
    for j=1:N-1
        etx(i,j)= trainingsize/sum(trainingdata(i,j,:)>0);
        burstmax(i,j)=computeBmax(squeeze((trainingdata(i,j,:))),1);
        jlat(i,j,:)=squeeze(computeJLAT(squeeze(trainingdata(i,j,:))));
        %assume one way transmissions
    end
end

selections=zeros(6,1);
%A string for selection of all routing algorithms

order=1:5;

selectedroute_minhop=1;
selections(1)=1;
%not much to evaluate for minhop

paths(1)=squeeze(etx(1,3));
paths(2)=squeeze(etx(1,1)+etx(2,3));
paths(3)=squeeze(etx(1,2)+etx(3,3));
paths(4)=squeeze(etx(1,1)+etx(2,2)+etx(3,3));
paths(5)=squeeze(etx(1,2)+etx(3,2)+etx(2,3));
%sum up etx's

Selectedroute_etx=order(paths(:)==min(paths));
selections(2)=Selectedroute_etx;
%allocate selected path for ETX


paths(1)=burstmax(1,3)+1;
paths(2)=burstmax(1,1)+burstmax(2,3)+2;
paths(3)=burstmax(1,2)+burstmax(3,3)+2;
paths(4)=burstmax(1,1)+burstmax(2,2)+burstmax(3,3)+3;
paths(5)=burstmax(1,2)+burstmax(3,2)+burstmax(2,3)+3;
%sum up burstmax's
Selectedroute_burstmax=order(paths==min(paths));
selections(3)=Selectedroute_burstmax;
%allocate selected path for Bmax

path=zeros(5,cutoff);
%JLAT requires a bigger array
path(1,:)=squeeze(jlat(1,3,:));
path(2,:)=combinejlats(squeeze(jlat(1,1,:)),squeeze(jlat(2,3,:)));
path(3,:)=combinejlats(squeeze(jlat(1,2,:)),squeeze(jlat(3,3,:)));
path(4,:)=combinejlats(combinejlats(squeeze(jlat(1,1,:)),squeeze(jlat(2,2,:))),squeeze(jlat(3,3,:)));
path(5,:)=combinejlats(combinejlats(squeeze(jlat(1,2,:)),squeeze(jlat(3,2,:))),squeeze(jlat(2,3,:)));
%Calculate JLAT for each path

%Modify deadline for each JLAT(2) JLAT(5) JLAT(8)
selectdeadline=2;
sumpath=zeros(5,1);
for i=1:5
    sumpath(i)=sum(path(i,1:selectdeadline));
end
Selectedroute_jlat=order(sumpath==max(sumpath));
selections(4)=Selectedroute_jlat;


selectdeadline=5;
sumpath=zeros(5,1);
for i=1:5
    sumpath(i)=sum(path(i,1:selectdeadline));
end
Selectedroute_jlat=order(sumpath==max(sumpath));
selections(5)=Selectedroute_jlat;

selectdeadline=8;
sumpath=zeros(5,1);
for i=1:5
    sumpath(i)=sum(path(i,1:selectdeadline));
end
Selectedroute_jlat=order(sumpath==max(sumpath));
selections(6)=Selectedroute_jlat;


%% Simulation actually starts now
freq_pack=30;
%set packet generation frequency

paths=1:5;
delay=zeros(ceil(realsize/freq_pack +1),5);
%delay calculation variable


for i=1:5
    
    %Select the loss-success behaviour of the links on the selected path
    if paths(i)==1
        datah1 = squeeze(realdata(1,3,:));
    elseif paths(i)==2
        datah1 = squeeze(realdata(1,1,:));%1-2
        datah2 = squeeze(realdata(2,3,:));%2-4
    elseif paths(i)==3
        datah1 = squeeze(realdata(1,2,:));%1-3
        datah2 = squeeze(realdata(3,3,:));%3-4
    elseif paths(i)==5
        datah1 = squeeze(realdata(1,2,:));%1-3
        datah2 = squeeze(realdata(3,2,:));%3-2
        datah3 = squeeze(realdata(2,3,:));%2-4
    elseif paths(i)==4
        datah1 = squeeze(realdata(1,1,:));%1-2
        datah2 = squeeze(realdata(2,2,:));%2-3
        datah3 = squeeze(realdata(3,3,:));%3-4
    end
    packcount=0;
    %Calculate the distance between packet generation and consecutive 
    %successes for each path to allocate delay
    for j=1:realsize
        if mod(j,freq_pack)==0
            packcount=packcount+1;
           if paths(i)==1
               count=1;
               while datah1(j)~=1 && j~=realsize
                    j=j+1;
                    count=count+1;
               end
               delay(packcount,i)=count;
           elseif paths(i)==2 || paths(i)==3
               count=1;
               while datah1(j)~=1 && j~=realsize
                    j=j+1;
                    count=count+1;
               end 
               if j==realsize
                   break;
               end
               j=j+1;
               count=count+1;
               while datah2(j)~=1 && j~=realsize
                    j=j+1;
                    count=count+1;
               end
               delay(packcount,i)=count;
           elseif paths(i)==4 || paths(i)==5
                count=1;
               while datah1(j)~=1 && j~=realsize
                    j=j+1;
                    count=count+1;
               end 
               if j==realsize
                   break;
               end
               j=j+1;
               count=count+1;
               while datah2(j)~=1 && j~=realsize
                    j=j+1;
                    count=count+1;
               end 
               if j==realsize
                   break;
               end
                j=j+1;
                count=count+1;
               while datah3(j)~=1 && j~=realsize
                    j=j+1;
                    count=count+1;
               end 
               delay(packcount,i)=count;
           end
        end
    end
end

% Extract cdf of the delay
[f1,x1] = ecdf(delay(:,1));
[f2,x2] = ecdf(delay(:,2));
[f3,x3] = ecdf(delay(:,3));
[f4,x4] = ecdf(delay(:,4));
[f5,x5] = ecdf(delay(:,5));


%% Plotting part
%%make up


% Set golden ratio 
width = 3.487*3;
height = width / 1.618;



% Create the figure holder
 fig=figure('Units','inches',...
 'Position',[2 2 width height],...
 'PaperPositionMode','auto');

% Plot in stairs for a CMF like view
stairs(x1,f1,'r--','LineWidth',2)
hold on
stairs(x2,f2,'b-s','LineWidth',2)
stairs(x3,f3,'p-.','LineWidth',2)
stairs(x4,f4,'m-<','LineWidth',2)
stairs(x5,f5,'k:','LineWidth',3)
hold off

%Boldify the prioritized path
AX=legend('Path 1','\textbf{Path 2}','Path 3','Path 4','Path 5','Location','southwest');

%Axis settings
set(AX,...
'FontSize',18,...
'FontName','Helvetica',...
'LineWidth',1,...
 'Interpreter', 'latex')

% General settings
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'GridLineStyle',':',...
'FontSize',14,...
'LineWidth',2,...
'FontName','Helvetica')

%labels
ylabel({'Cumulative mass'},...
'FontUnits','points',...
'interpreter','latex',...
'FontSize',20,...
'FontName','Helvetica')

xlabel('Latency in slots',...
'FontUnits','points',...
'interpreter','latex',...
'FontSize',20,...
'FontName','Helvetica')

% Since delay is up to 8 fix x axis
% Y axis to 0 1 due to CMF
axis([0 8 0 1])

% Add extra information about routing decision
Decisions= ['Minhop = Path ' ,num2str(selections(1)),char(10),  'ETX = Path ',num2str(selections(2)),char(10),'BMAX = Path ' ,...
    num2str(selections(3)),char(10),'JLAT DL=2 = Path ' ,num2str(selections(4)),char(10),'JLAT DL=5 = Path ' ,num2str(selections(5)),char(10),'JLAT DL=8 = Path ' ,num2str(selections(6))];
text1=text(0.2,0.75,Decisions);
set(text1,...
'FontSize',18,...
'FontName','Helvetica',...
 'Interpreter', 'latex')

% Add extra information about beta allocation
Beta = ['Beta = ' ,num2str(betabad),char(10),'Beta_p= ' ,num2str(betagood)];
text2=text(2.6,0.87,Beta);
set(text2,...
'FontSize',18,...
'FontName','Helvetica',...
 'Interpreter', 'latex')

% Save as eps for handling
print(fig,'delay_routing_mixed_path2','-depsc','-r0')




