function CCI = calc_CCI(muscle1,muscle2,percentages)
% muscle1 = 1x101 vector of agonist activity (could be stance or g. cycle)
% muscle2 = 1x101 vector of antagonist activity
% percentages = 2x1 vector of start time and end time as percent of gait
% cycle (integers only) 0 to 100

% for testing
% muscle1 = ones(1,101) ; muscle2 = .5*ones(1,101) ;
% percentages = [95 100] ;

%% CCI_method1 Area_{overalp} / Area_{uppermost}
% rg = percentages(1)+1:percentages(2)+1 ; % add 1 b/c 0:100 is indexed as 1:101
% overlap = sum(min([muscle1(rg);muscle2(rg)])) ;
% denom = sum(max([muscle1(rg);muscle2(rg)])) ;
% CCI = overlap/denom ;

%% CCI_method4 Area_{overlap} / number of points
rg = percentages(1)+1:percentages(2)+1 ; % add 1 b/c 0:100 is indexed as 1:101
overlap = sum(min([muscle1(rg);muscle2(rg)])) ;
CCI = overlap/range(rg) ;

    