function Values = mycheckboxes(filenames)

label = filenames ;
figure(1459)
screensize = get(0,'screensize') ;
set(gcf,'Position',[.8*screensize(3),200,250 300]) % used to be 2400
for k=1:length(filenames); 
    cbh(k) = uicontrol('Style','checkbox','String',label{k}, ...
                       'Value',1,'Position',[30 280-20*k 150 20]) ;   
end
 
disp('Press Enter to select trials to analyze')
pause

try
for k=1:length(filenames); 
Values(k) = cbh(k).Value ;
end
catch
Values = ones(length(filenames),1) ;
end
close(figure(1459))