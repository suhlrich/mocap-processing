function [] = writeSTO_OpenSense(time,data,header,Fs,filePath,fileName) 

osimVersion = org.opensim.modeling.opensimCommon.GetVersion();
% Columnwise data, header in a cell

    fid = fopen([filePath fileName '.sto'],'w') ;
% Write the header
    fprintf(fid,'%s\n',['DataRate=',num2str(Fs)]);
    fprintf(fid,'%s\n','DataType=Quaternion');
    fprintf(fid,'%s\n','version=3');
    fprintf(fid,'%s\n',['OpenSimVersion=',char(osimVersion)]);
    fprintf(fid,'%s\n','endheader');
    
    for i = 1:length(header)-1
        fprintf(fid,'%s\t',header{i}) ;
    end
    fprintf(fid,'%s\n',header{end}) ;
    
    % Write the data
    for j=1:size(data,1)
%         fprintf(fid,'%.6f\t',data(j,1:end-1));
%         fprintf(fid,'%.6f',data(j,end));
        fprintf(fid,'%.6f\t',time(j));
        fprintf(fid,'%s\t',data{j,1:end-1});
        fprintf(fid,'%s',data{j,end});
        fprintf(fid,'\n');
    end
    
    fclose all ;
    
    disp(['Successfully wrote ' filePath fileName '.sto to file.']) ;