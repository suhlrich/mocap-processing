function ALLSUBS = computeALLSUBS_diffs(ALLSUBS) ;
% This function subtracts the baseline condition from any field in ALLSUBS
% that has 5 entries in some dimension.

fn = fieldnames(ALLSUBS) ;
nSubs = length(ALLSUBS.subjects) ;
messageStatus = false ;

if nSubs == 5
    error('You only have 5 subjects. This will confuse the differences program. Choose a different number of subjects')
end

for i = 1:length(fn)
    fieldSize = size(ALLSUBS.(fn{i})) ;
    
    % Delete if already a normalized field
    if ~isempty(strfind(fn{i},'diffBL'))
        rmfield(ALLSUBS,fn{i}); 
        if messageStatus == false
            disp('Deleting previous differenced values from ALLSUBS')
            messageStatus = true ;
        end
    elseif ~isempty(find(fieldSize == 5)) 
        condInd = find(fieldSize == 5) ;
        nonCondInd = find(fieldSize ~=5) ;
        permMat = permute(ALLSUBS.(fn{i}),[condInd nonCondInd]) ;
        switch length(fieldSize)
            case 2
                tempMat = bsxfun(@minus,permMat,permMat(1,:)) ;
            case 3
                tempMat = bsxfun(@minus,permMat,permMat(1,:,:)) ;
            case 4
                tempMat = bsxfun(@minus,permMat,permMat(1,:,:,:)) ;
            case 5
                tempMat = bsxfun(@minus,permMat,permMat(1,:,:,:,:)) ;
        end
        
        tempFieldSize = size(tempMat) ;
        permInds = zeros(1,length(tempFieldSize)) ;
        for j = 1:length(permInds)
            permInds(j) = find(tempFieldSize == fieldSize(j)) ;
        end
        
        ALLSUBS.([fn{i} '_diffBL']) = permute(tempMat,permInds);

    end
    
end

end