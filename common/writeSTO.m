function [] = writeSTO(data,header,filePath,fileName) ;
% Columnwise data, header in a cell

    fid = fopen([filePath fileName '.sto'],'w') ;
% Write the header
    fprintf(fid,'%s\n',fileName);
    fprintf(fid,'%s\n',['nRows=' num2str(length(data))]);
    fprintf(fid,'%s\n',['nColumns=',num2str(length(header))]);
    fprintf(fid,'%s\n','endheader');
    
    for i = 1:length(header)-1
        fprintf(fid,'%s\t',header{i}) ;
    end
    fprintf(fid,'%s\n',header{end}) ;
    
    % Write the data
    for j=1:size(data,1)
        fprintf(fid,'%.6f\t',data(j,1:end-1));
        fprintf(fid,'%.6f',data(j,end));
        fprintf(fid,'\n');
    end
    
    fclose all ;
    
    disp(['Successfully wrote ' filePath fileName '.sto to file.']) ;