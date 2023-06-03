function [visuallyGoodTrials] = visualPlotEditingSD(valuesMatrix,GT_in,badTrials,numtrials,plotTitles)
% This plots docked figures and lets you select bad trials, then returns
% the goodtrials (visuallyGoodTrials) vector to you
% valuesMatrix == nsamples x numplots x numtrials
% plotTitles = 1xnumplots cell of titles
% GT_in = vector of all good trials coming in (this could start as all
% trials)
% badTrials = these are badtrials and get removed from GT_in
% This plots median and standard deviation as well

numplots = size(valuesMatrix,2) ;

ind = xor(ones(1,length(GT_in)), ismember(GT_in,badTrials)) ;
GT = GT_in(ind~=0) ;

for p = 1:numplots
    figure ;
    plotMat = interp101(squeeze(valuesMatrix(:,p,GT))') ;
    hold on  
    plot(0:100,plotMat')
    xlim([0 100]) ;
    
    medianTrace = median(plotMat) ;
    plotMatsorted = sort(plotMat) ;
    sdVec = std(plotMatsorted(4:end-3,:)) ;
    xfill = [0:100 fliplr(0:100)] ;
    yfill = [medianTrace-3*sdVec fliplr(medianTrace+3*sdVec)] ;
    p1 = plot(0:100,medianTrace,'k','linewidth',4) ;
    p2 = plot(0:100,[medianTrace-3*sdVec; medianTrace+3*sdVec],'k--','linewidth',2) ;
    legHandle = legend([p1;p2(1)],{'median','median±3SD'},'location','NorthEastOutside') ;
    legend boxoff
    
    
    set(gcf, 'WindowStyle', 'docked')    
    set(datacursormode,'UpdateFcn',@TrialSelectLabels)
    try
    title(plotTitles{p})
    end
    setappdata(gca,'plot_GT',GT);   
    setappdata(gca,'plot_badtrials',[]);    
    haxis{p} = gca ;
    datacursormode on
end

% Exclude bad EMG files for each trial
happy = 0 ;
    while happy == 0 ;
    badselections = [];
    input('Click on bad traces, press enter when done')
    for ii = 1:size(valuesMatrix,2)
        badselections = [badselections getappdata(haxis{ii},'plot_badtrials')] ; %retrieves lines clicked on in plotbrowser
    end
    disp('The following trials have been labeled as bad trials')
    badselections = unique(badselections) ;
    badselections

    badTrials = [badTrials; badselections'] ;
    if isempty(badselections)
        happy = 1;
    else
        ind = xor(ones(1,length(GT_in)), ismember(GT_in,[badTrials' badselections])) ;
        GT = GT_in(ind~=0) ;
%         GT = GT_in(end-size+1:end);
        close all

        for p = 1:numplots
            figure ;
            plotMat = interp101(squeeze(valuesMatrix(:,p,GT))') ;
            hold on  
            plot(0:100,plotMat')
            xlim([0 100]) ;

            medianTrace = median(plotMat) ;
            plotMatsorted = sort(plotMat) ;
            sdVec = std(plotMatsorted(4:end-3,:)) ;
            xfill = [0:100 fliplr(0:100)] ;
            yfill = [medianTrace-3*sdVec fliplr(medianTrace+3*sdVec)] ;
            p1 = plot(0:100,medianTrace,'k','linewidth',4) ;
            p2 = plot(0:100,[medianTrace-3*sdVec; medianTrace+3*sdVec],'k--','linewidth',2) ;
            legHandle = legend([p1;p2(1)],{'median','median±3SD'},'location','NorthEastOutside') ;
            legend boxoff


            set(gcf, 'WindowStyle', 'docked')    
            set(datacursormode,'UpdateFcn',@TrialSelectLabels)
            try
            title(plotTitles{p})
            end
            setappdata(gca,'plot_GT',GT);   
            setappdata(gca,'plot_badtrials',[]);    
            haxis{p} = gca ;
            datacursormode on
        end
        
        happy = isempty(input('Press Enter if you are happy, a number otherwise \n')) ;
    end
    end
hold off

visuallyGoodTrials = GT ;