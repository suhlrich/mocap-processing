function [] =  KFMcomparison(subjectdir)
% subjectdir = 'C:\Users\suhlr_000\Documents\stanford\DelpResearch\OA_GaitRetrainingDATA\DATA_backup_10_1\Subject1\' ;
direc = pwd ;
res = get(0,'Screensize') ; res = res(3:4) ;
files = dir([subjectdir 'DATA_baseline*']) ; 
for i = 1:size(files,1) ; 
    trialnames{i} = files(i).name(6:end-4) ;
end

foot = 'lr' ;
for i = 1:size(trialnames,2) ;
trialname = trialnames{i} ;
load([subjectdir 'DATA_' trialname '.mat'])
    for j = 1:2 ;
    ft = foot(j) ;
    eval(['KFMin = DATA.KFM_filtered_' ft ';'])
    eval(['TIMEin = DATA.time_' ft ';'])
    eval(['goodtrials = DATA.GoodTrials_' ft ';'])

    cd(direc)
    [u sd] = meanplot(KFMin,TIMEin,goodtrials) ;

    eval(['DATA.KFMmean_' ft ' = u ;'])
    eval(['DATA.KFMsd_' ft ' = sd ;'])
    save([subjectdir 'DATA_' trialname '.mat'],'DATA')
    end
end


%% Plot mean KFMs
names = trialnames ;
style = {'-','--','-.','o','^'} ;
legendname = cell(length(trialnames),1) ;

KFMfig = figure(200);
set(KFMfig, 'Position', [.05*res(1) .05*res(2) .8*res(1) .8*res(2)])

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
    eval(['kfm_m = DATA.KFMmean_' ft ';']) 
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
    pl(i) = plot(kfm_m,st,'LineWidth',2) ;
    hold all
    FPAt(i) = FPA_training ;
    maxKFM(i) = max(kfm_m) ;
    firstpeak(i) = max(kfm_m(1:100)) ;
end


subplot(sp(j)) ;
set(gca,'FontSize',14)
ylabel(['KFM [%BW*height]'],'FontSize',16)
xlabel('Percent Stance','FontSize',16)
legend(pl,legendname{:},'Location','northeast')
set(gco,'FontSize',8)
if ft == DATA.leg
    title(['Feedback Leg ' ft])
else
    title(ft)
end

bl = find(FPAt==0);
maxKFMnorm = maxKFM/maxKFM(bl) ;
firstpeakredux = firstpeak/firstpeak(bl) ;

subplot(sp(2+j))
[FPAt srti] = sort(FPAt) ;
fpr = plot(FPAt,firstpeakredux(srti),'ko-','MarkerSize',6,'MarkerFaceColor','k','LineWidth',2) ;
hold on
ylabel('Peak KFM Normalized to Baseline','FontSize',16)
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


set(sp(1),'Position',[.05 .58 .40 .37]) ; 
set(sp(2),'Position',[.55 .58 .40 .37]) ; 
set(sp(3),'Position',[.05 .08 .40 .38]) ;
set(sp(4),'Position',[.55 .08 .40 .38]) ;
set(KFMfig, 'PaperPositionMode', 'auto');


for i = 1:length(names)
    load([subjectdir 'DATA_' trialnames{i} '.mat']) 
    eval(['DATA.firstpeakredux.' ft ' = 1-firstpeakredux(i) ;'])
    save([subjectdir 'DATA_' trialnames{i} '.mat'],'DATA')
end
 
end

set(KFMfig,'PaperPositionMode','auto');

saveas(KFMfig,[subjectdir 'images\KFMprofilecomparison_filt.png'])

