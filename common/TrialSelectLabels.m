function output_txt = TrialSelectLabels(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');
output_txt = {['X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)]};

% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
end

hLine = get(event_obj,'Target') ;
ydat = hLine.YData ;
xdat = hLine.XData ;
hAxis = hLine.Parent ;
numlines = length(hAxis.Children);
Lines = hLine.Parent.Children ;
DATA = zeros(numlines,length(xdat)) ;
for p = 0:numlines-1
    DATA(numlines-p,:) = Lines(p+1).YData ;
end
ind = ismember(DATA,ydat,'rows');
GT = getappdata(hAxis,'plot_GT');
bt = getappdata(hAxis,'plot_badtrials');
bt = [bt GT(ind)] ;
setappdata(hAxis,'plot_badtrials',bt);
Trialnum = GT(ind) ;
output_txt{end+1} = ['Trial Num: ',num2str(Trialnum)];
