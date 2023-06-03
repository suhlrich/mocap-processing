function [visuallyGoodTrials] = visualPlotEditing(valuesMatrix,GT_in,badTrials,numTrials,plotTitles)
% This plots docked figures and lets you select bad trials, then returns
% the goodtrials (visuallyGoodTrials) vector to you
% valuesMatrix == nsamples x numplots x numtrials
% plotTitles = 1xnumplots cell of titles
% GT_in = vector of all good trials coming in (this could start as all trials)
% badTrials = these are badtrials and get removed from GT_in
% numTrials doesn't have any function currently

% Example use: valuesMatrix of 2 different quantities (GRF, knee angle),
% 57 trials with 101 samples each would be (101 x 2 x 57). GT_in would be a
% matrix  with the 57 trials that are thought to be good. If all may be
% good, just put in 1:57. badTrials would be the trials from 1 to 57 that
% are bad. numTrials does nothing, plotTitles is the name of the traces
% like {'GRF_z','Knee Angle'}. 

numplots = size(valuesMatrix,2) ;

ind = xor(ones(1,length(GT_in)), ismember(GT_in,badTrials)) ;
GT = GT_in(ind~=0) ;

for p = 1:numplots
    figure ;
    plot(squeeze(valuesMatrix(:,p,GT)))
    set(gcf, 'WindowStyle', 'docked')    
    try
        set(datacursormode,'UpdateFcn',@TrialSelectLabels)
    catch
        error('You probably dont have TrialSelectLabels.m in your current directory or path')
    end
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
        plot(squeeze(valuesMatrix(:,p,GT)))
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