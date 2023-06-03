function [fullFieldNames, X_norm, X] = buildRegressionInputMat(inputFieldNames,condition_col,ALLSUBS,normBinary)
% This finds fieldnames from ALLSUBS structure, puts into a matrix with
% columns as features. Then demeans and normalizes if normBinary is true.
% All principle components are selected for each desired feature with '_PC'
% in the name.

nSubs = length(ALLSUBS.subjects) ;
nFields = length(inputFieldNames) ;
PCFieldInds = find(~cellfun(@isempty,strfind(inputFieldNames,'_PC'))) ;
nonPCFieldInds = find(cellfun(@isempty,strfind(inputFieldNames,'_PC'))) ;
nPCs = ALLSUBS.nPCs ;
PCFieldNames = inputFieldNames(PCFieldInds) ;
nonPCFieldNames = inputFieldNames(nonPCFieldInds) ;


X = zeros(nSubs,length(nonPCFieldInds) + length(PCFieldInds)*nPCs) ;
fullFieldNames = cell(1,size(X,2)) ;
nFeature = 1 ;

for i = 1:length(nonPCFieldNames)
    varField = ALLSUBS.(nonPCFieldNames{i}) ;
   
    % Get the variable in the right order
    desiredOrder = [nSubs,5,1] ;
    desiredOrderSingle = [nSubs,1,1] ;
    permuteOrder = zeros(3,1) ;
    
    k = 1;
    for j = 1:3 ;
        try
        if sum(find(size(varField)==5)) > 0
            permuteOrder(j) = find(desiredOrder(j)==size(varField)) ;
            condInd = condition_col ;
        else
            if j <= 2
            newInds = find(desiredOrderSingle(j)==size(varField)) ;
            permuteOrder(j:j+length(newInds)-1) = newInds ;
            condInd = 1 ;
            end
        end  
        catch
            error(['Dimensions of ' nonPCFieldNames{i} ' are wrong.'])
        end
    end
    permuteOrder = permuteOrder(find(permuteOrder~=0)) ;
    varFieldPerm = permute(varField,permuteOrder) ;
    
    X(:,i) = varFieldPerm(:,condInd) ;
    fullFieldNames{i} = nonPCFieldNames{i} ;
end
nFeature = i+1 ;

% For the PCwt variables
for i = 1:length(PCFieldNames)
    varField = ALLSUBS.(PCFieldNames{i}) ;
   
    % Get the variable in the right order
    desiredOrder = [nSubs,5,nPCs] ;
    permuteOrder = zeros(3,1) ;
    
    k = 1;
    for j = 1:3 ;
        try
        permuteOrder(j) = find(desiredOrder(j)==size(varField)) ;
        condInd = condition_col ;
        catch
            error(['Dimensions of ' PCFieldNames{i} ' are wrong.'])
        end
    end
    permuteOrder = permuteOrder(find(permuteOrder~=0)) ;
    varFieldPerm = permute(varField,permuteOrder) ;
    
    X(:,nFeature:nFeature+nPCs-1) = varFieldPerm(:,condInd,:) ;
    
    PCnumCell = num2cell(1:nPCs) ;
    fullFieldNames(nFeature:nFeature+nPCs-1) = cellfun(@(c)[PCFieldNames{i} num2str(c)],PCnumCell,'uni',false) ;
    nFeature = nFeature+nPCs ;
end

% Normalize X
if normBinary
    X_norm = bsxfun(@rdivide,bsxfun(@minus,X,nanmean(X)),nanstd(X)) ; % compute z score
else
    X_norm = X ;
end
