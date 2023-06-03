function [u sd KAMtrials_interp] = meanplot(KAMin,TIMEin,goodtrials,TITLE,savepath)

if nargin==1 ; TIMEin = [] ; goodtrials = []; end

if isempty(TIMEin) == 0 && isempty(goodtrials) == 0
steps = size(KAMin,1) ;
dt = [TIMEin(:,2:end),zeros(steps,1)] - TIMEin ;
dtmean = mean(dt(find(dt>0))) ;
samprate = 1/dtmean ;
TIME = zeros(length(goodtrials),101) ;
KAM = zeros(length(goodtrials),101) ;

    for i = 1:length(goodtrials)
        k = goodtrials(i) ;
        kam = KAMin(k,:) ;
        time = TIMEin(k,:) ;
        n = find(time == 0,1)-1 ;
        kam = kam(1:n) ;
        time = time(1:n) ;
        TIME = linspace(time(1),time(n),101);
        KAM(i,:) = interp1(time,kam,TIME) ;
        
        u = mean(KAM) ;
        sd = std(KAM) ;
    end
    KAMtrials_interp = KAM ;
else
    KAM = interp1(linspace(0,100,size(KAMin,2)),KAMin',0:100) ;
    KAM = KAM' ;
    u = mean(KAM);
    sd = std(KAM);
    KAMtrials_interp = KAM ;
end


if nargin>3 % plot if title specified
figure
low = u-sd ; hi = 2*sd ;
Y = [low',hi'] ;
x = 0:100 ;
plot([-1 101],[0 0],'Color',.6*[1 1 1],'Linewidth',.5)
hold on
a = area(x,Y,'LineStyle','none') ;
set(a(1),'FaceColor',[1 1 1])
set(a(2),'FaceColor',.7*[1 1 1])
plot(x,u,'k','LineWidth',2)
xlabel('Percent Stance','FontSize',18)
try
ylabel(TITLE,'FontSize',18)
catch
ylabel('mean of some parameter')
end
xlim([0 100])
if nargin>3
title(TITLE,'FontSize',18)

if nargin>4
delete([savepath '.png'])
saveas(gcf,[savepath '.png'])
end
end

end


