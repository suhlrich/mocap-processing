function ALLSUBS = normalizeALLSUBSFields(NormFields,ALLSUBS) ;
% This function normalizes NormFields.height by height in meters and
% NormFields.weight by weight in Newtons

fn = fieldnames(ALLSUBS) ;

nSubs = length(ALLSUBS.subjects) ;
ALLSUBS.BW_N = ALLSUBS.BW_kg*9.81 ;
messageStatus = false ;

for i = 1:length(fn)
    
    isHeightField = sum(cellfun(@(s) ~isempty(strfind(fn{i}, s)), NormFields.height))>0 ;
    isWeightField = sum(cellfun(@(s) ~isempty(strfind(fn{i}, s)), NormFields.weight))>0 ;
    
    % Delete if already a normalized field
    if ~isempty(strfind(fn{i},'heightNorm')) || ~isempty(strfind(fn{i},'weightNorm'))
        rmfield(ALLSUBS,fn{i}); 
        if messageStatus == false
            disp('Deleting previous normalized values from ALLSUBS')
            messageStatus = true ;
        end
    else
        if isHeightField
            % Normalize by Height
            ALLSUBS = normalizeField(ALLSUBS,i,fn,nSubs,'h_m','heightNorm');
        elseif isWeightField
            % Normalize by Weight
            ALLSUBS = normalizeField(ALLSUBS,i,fn,nSubs,'BW_N','weightNorm'); 
        end
    end
    
end

end

function ALLSUBS = normalizeField(ALLSUBS,fieldNumber,fieldNames,nSubs,normField,fieldAppend)
    fn = fieldNames ;
    fieldSize = size(ALLSUBS.(fn{fieldNumber})) ;
    normMatrix = repmat(ALLSUBS.(normField)',[1 fieldSize(fieldSize~=nSubs)]) ;
    tempFieldSize = size(normMatrix) ;

    permInds = zeros(1,length(tempFieldSize)) ;
    for j = 1:length(permInds)
        permInds(j) = find(tempFieldSize == fieldSize(j)) ;
    end

    normMatrix = permute(normMatrix,permInds) ;

    ALLSUBS.([fn{fieldNumber} '_' fieldAppend]) = ALLSUBS.(fn{fieldNumber})./normMatrix ;
end