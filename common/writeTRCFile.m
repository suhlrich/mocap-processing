function done = writeTRCFile(time,mrkdata,mrknames,directory,file)
% time: nSamples vector of times
% mrkdata: nSamples x (nMarkers*3) matrix of marker xyz positions
% mrknames: nMarkers x 1 cell of marker names
% Directory you want to write to
% beginning of filename - the trc gets added automatically


if length(time)<2
    time(2)=1;
end
T=time(2)-time(1);

f=1/T;
[mk,nk]=size(mrkdata);
nk=nk/3;
fid = fopen([directory,'/',file,'.trc'],'w');
fprintf(fid,'PathFileType  4	(X/Y/Z) %s\n',directory);
fprintf(fid,'DataRate	CameraRate	NumFrames	NumMarkers	Units	OrigDataRate	OrigDataStartFrame	OrigNumFrames\n');
fprintf(fid,'%7.1f	\t%7.1f	\t%7d	\t%7d	\t mm	%7.1f	%7d	%7d\n',f,f,mk,nk,f,1,mk);
fprintf(fid,'Frame#\t');
fprintf(fid,'Time\t');
for i=1:nk
    mark=cellstr(mrknames(i,:)); mark=char(mark);
    fprintf(fid,'%s\t\t\t',mark);
end
fprintf(fid,'\n');
fprintf(fid,'		');
for i=1:nk
    if (i<10)
        fprintf(fid,'X%1d	Y%1d	Z%1d	',i,i,i);
    elseif (i<100)
        fprintf(fid,'X%2d	Y%2d	Z%2d	',i,i,i);
    else
        fprintf(fid,'X%3d	Y%3d	Z%3d	',i,i,i);
    end
end
fprintf(fid,'\n');
fprintf(fid,'\n');

for i=1:mk
    fprintf(fid,'%d',i);
    fprintf(fid,'\t%.5f',time(i));
    fprintf(fid,'\t%.3f',mrkdata(i,:));
    fprintf(fid,'\n');
end
fclose(fid);
done=1;
end

