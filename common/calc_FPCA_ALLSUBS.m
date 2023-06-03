function ALLSUBS = calc_FPCA_ALLSUBS(ALLSUBS,nPC)
% Perform FPCA on timeseries data (any entry in ALLSUBS that has a
% dimension of 101 and has 3 dimensions
% nPC is the number of principle components to be analyzed. Default is 3

if ~exist('nPC') ;
    nPC = 3 ;
end
messageStatus = false ;
ALLSUBS.nPCs = nPC ;

% Set parameters for FPCA
p = setOptions('regular', 3, 'selection_k',nPC,'numBins',0, 'verbose','on');  

nSubs = length(ALLSUBS.subjects) ;
timeArray = repmat(0:100,1,nSubs) ;
time_cell = mat2cell(timeArray,1,101*ones(1,nSubs)) ;

if nSubs == 101 ;
    error('Threre are 101 subjects which will confuse the FPCA algorithm. Load 1 less or more subject')
end

fn = fieldnames(ALLSUBS) ;
for i = 1:numel(fn)
    sizeOfField = size(ALLSUBS.(fn{i})) ;
    if sum(find(sizeOfField==101))==1 && length(sizeOfField) == 3 % if there's a timeseries (101) dimension and it is averaged
        if ~isempty(strfind(fn{i},'_PC')) 
            rmfield(ALLSUBS,fn{i}) ;
            if messageStatus == false
                disp(['Removed old PCs from ALLSUBS'])
                messageStatus = true; 
            end
        else
            timeseries_cell = generateTimeseriesCell(ALLSUBS.(fn{i}),nSubs) ; % generate 5xnSubs cell of timeseries

            % preallocate
            ALLSUBS.([fn{i} '_PC']) = zeros(101,5,nPC) ;
            ALLSUBS.([fn{i} '_PCwt']) = zeros(nPC,5,nSubs) ;
            ALLSUBS.([fn{i} '_PCvarExp']) = zeros(nPC,5) ;
            ALLSUBS.([fn{i} '_PCgrp_u']) = zeros(101,5) ;

            % loop through 5 conditions
            for j = 1:5    
                  if isempty(strfind(fn{i},'diffBL')) || j >1 % ignores 0 cases for BL difference
                      out = FPCA(timeseries_cell(j,:),time_cell,p) ;
                      ALLSUBS.([fn{i} '_PC'])(1:101,j,1:nPC) = getVal(out,'phi') ;
                      ALLSUBS.([fn{i} '_PCwt'])(1:nPC,j,1:nSubs) = getVal(out,'xi_est')' ;       
                      varExp = getVal(out,'FVE') ;
                      ALLSUBS.([fn{i} '_PCvarExp'])(1:nPC,j) = varExp(1:nPC) ;
                      ALLSUBS.([fn{i} '_PCgrp_u'])(1:101,j) = getVal(out,'mu') ;
                  end
            end
        end
    end
end

end

% % % % Supporting Functions
function newCell = generateTimeseriesCell(oldMat,nSubs)
% turn into a 1xnSubs cell with a timeseries in each cell position
    if sum(size(oldMat) == [101,5,nSubs]) ~=3 % permute
        matSize = size(oldMat) ;
        dim1 = find(matSize==101) 
        dim2 = find(matSize== 5 ) 
        dim3 = find(matSize ==nSubs) 
        oldMat = permute(oldMat,[dim1 dim2 dim3]) ;
    end

    
    newCell = cell(5,nSubs) ;
    for i = 1:5
        tempMat = reshape(oldMat(:,i,:),1,101*nSubs) ;
        newCell(i,:) = mat2cell(tempMat,1,101*ones(1,nSubs)) ;
    end
end
