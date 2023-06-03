function [] =  KAMcomparison(subjectdir)
% subjectdir = 'C:\Users\suhlr_000\Documents\stanford\DelpResearch\OA_GaitRetrainingDATA\DATA_backup_10_1\Subject1\' ;
direc = pwd ;
res = get(0,'Screensize') ; res = res(3:4) ;
files = dir([subjectdir 'DATA_baseline*deg.mat']) ; 
trialnames{1} = 'baseline' ;
for i = 1:size(files,1) ; 
    trialnames{i+1} = files(i).name(6:end-4) ;
end
foot = 'lr' ;
for i = 1:size(trialnames,2) ;
trialname = trialnames{i} ;
load([subjectdir 'DATA_' trialname '.mat'])
    for j = 1:2 ;
    ft = foot(j) ;
    eval(['KAMin = DATA.KAM_' ft ';'])
    eval(['TIMEin = DATA.time_' ft ';'])
    eval(['goodtrials = DATA.GoodTrials_' ft ';'])

    cd(direc)
    [u sd] = meanplot(KAMin,TIMEin,goodtrials) ;
    impulse = sum((u>0).*u) ;

    eval(['DATA.KAMmean_' ft ' = u ;'])
    eval(['DATA.KAMsd_' ft ' = sd ;'])
    eval(['DATA.KAMimpulse_' ft ' = impulse ;'])
    save([subjectdir 'DATA_' trialname '.mat'],'DATA')
    end
end


%% Plot mean KAMs
names = trialnames ;
style = {'-','--','-.','o','^'} ;
legendname = cell(length(trialnames),1) ;

KAMfig = figure(100);
set(KAMfig, 'Position', [.05*res(1) .05*res(2) .8*res(1) .8*res(2)])

sp(1) = subplot(2,2,1) ; plot([0 100],[0 0],'k') ; hold on ;
sp(2) = subplot(2,2,2) ; plot([0 100],[0 0],'k') ; hold on ;
sp(3) = subplot(2,2,3) ; plot([-30 30],[1 1],'k') ; hold on ;
sp(4) = subplot(2,2,4) ; plot([-30 30],[1 1],'k') ; hold on ;

for j = 1:2 ;
    ft = foot(j) ;
    negcounter = 1 ; poscounter = 1;

for i = 1:length(names) ;
    load([subjectdir 'DATA_' trialnames{i} '.mat']) 
    FPA_training = DATA.FPA_training ;
    FPArange(i) = FPA_training ;
    eval(['kam = DATA.KAMmean_' ft ';']) 
    eval(['imp(' num2str(i) ') = DATA.KAMimpulse_' DATA.leg ';']) 
    legendname{i} = [num2str(FPA_training) ' deg'] ;

    if FPA_training<0
        st = ['r' style{negcounter}] ;
        negcounter = negcounter + 1;
    elseif FPA_training == 0
        st = 'k' ;
        legendname{i} = 'baseline' ;
    else
        st = ['b' style{poscounter}] ;
        poscounter = poscounter + 1;
    end
    subplot(sp(j)) ;
    pl(i) = plot(kam,st,'LineWidth',2) ;
    hold all
    FPAt(i) = FPA_training ;
    maxKAM(i) = max(kam) ;
    firstpeak(i) = max(kam(1:50)) ;
    secondpeak(i) = max(kam(51:100));
end


subplot(sp(j)) ;
set(gca,'FontSize',14)
ylabel(['KAM [%BW*height]'],'FontSize',16)
xlabel('Percent Stance','FontSize',16)
legend(pl,legendname{:},'Location','south')
if ft == DATA.leg
    title(['Feedback Leg ' ft])
else
    title(ft)
end

bl = find(FPAt==0);
maxKAMnorm = maxKAM/maxKAM(bl) ;
impnorm = imp/imp(bl) ;
firstpeakredux = firstpeak/firstpeak(bl) ;
secondpeakredux = secondpeak/secondpeak(bl) ;

subplot(sp(2+j))
[FPAt srti] = sort(FPAt) ;
pl2(1) = plot(FPAt,firstpeakredux(srti),'bo-','MarkerSize',6,'MarkerFaceColor','b','LineWidth',2);
hold on
pl2(2) = plot(FPAt,secondpeakredux(srti),'ro-','MarkerSize',6,'MarkerFaceColor','r','LineWidth',2);
pl2(3) = plot(FPAt,impnorm(srti),'ko-','MarkerSize',6,'MarkerFaceColor','k','LineWidth',2);
l2(j) = legend(pl2,'first peak reduction','second peak reduction','KAMimpulse','Location','Southoutside');
ylabel('Normalized to Baseline','FontSize',16)
xlabel('FPA','FontSize',16)
xlim([min(FPArange) max(FPArange)])

% if ft == DATA.leg
%     title(['Feedback Leg ' ft])
% else
%     title(ft)
% end

set(gca,'FontSize',14)
b = findobj(gcf,'Type','axes','Tag','legend');
set(b,'Fontsize',10);
set(gcf,'Units','normalized'); set(l2(j),'Position',[.22+.5*(j-1),.01,.05,.1]) ;

set(sp(1),'Position',[.05 .58 .40 .37]) ; 
set(sp(2),'Position',[.55 .58 .40 .37]) ; 
set(sp(3),'Position',[.05 .19 .40 .28]) ;
set(sp(4),'Position',[.55 .19 .40 .28]) ;
set(KAMfig, 'PaperPositionMode', 'auto');


for i = 1:length(names)
    load([subjectdir 'DATA_' trialnames{i} '.mat']) 
    eval(['DATA.firstpeakredux.' ft ' = 1-firstpeakredux(i) ;'])
    eval(['DATA.secondpeakredux.' ft ' = 1-secondpeakredux(i) ;'])
    save([subjectdir 'DATA_' trialnames{i} '.mat'],'DATA')
end
 
end
set(KAMfig,'PaperPositionMode','auto');

saveas(KAMfig,[subjectdir 'images\KAMprofilecomparison_filt.png'])



