function structOut = pickAllStructSubVals(structIn,inds,FPAind) 

nSubs = length(structIn.subjects) ;

fn = fieldnames(structIn) ;
for i = 1:numel(fn)
    if ~isempty(find(size(structIn.(fn{i}))==nSubs))
        if(isnumeric(structIn.(fn{i})) || ischar(structIn.(fn{i})) )
            nDims = length(size(structIn.(fn{i}))) ;
            numEl2Dim = size(structIn.(fn{i}),2) ;
            if numEl2Dim == 5
                inds2Dim = [1,FPAind] ;
            else
                inds2Dim = 1:numEl2Dim ;
            end
            switch nDims
                case 2
                     structOut.(fn{i}) = structIn.(fn{i})(:,inds) ;
                     structOut.([fn{i} '_grp_u']) = nanmean(structOut.(fn{i}),2) ;
                     structOut.([fn{i} '_grp_sd']) = nanstd(structOut.(fn{i}),0,2) ;
                case 3
                     structOut.(fn{i}) = structIn.(fn{i})(:,inds2Dim,inds) ; 
                     structOut.([fn{i} '_grp_u']) = nanmean(structOut.(fn{i}),3) ;
                     structOut.([fn{i} '_grp_sd']) = nanstd(structOut.(fn{i}),0,3) ;
                     if numEl2Dim == 5
                         structOut.([fn{i} '_delta']) = diff(structOut.(fn{i}),1,2) ;
                         structOut.([fn{i} '_delta_grp_u']) = nanmean(structOut.([fn{i} '_delta']),3) ;
                         structOut.([fn{i} '_delta_grp_sd']) = nanstd(structOut.([fn{i} '_delta']),0,3) ;
                     end

                case 4
                     structOut.(fn{i}) = structIn.(fn{i})(:,inds2Dim,:,inds) ; 
                     structOut.([fn{i} '_grp_u']) = nanmean(structOut.(fn{i}),4) ;
                     structOut.([fn{i} '_grp_sd']) = nanstd(structOut.(fn{i}),0,4) ;
                     if numEl2Dim == 5
                         structOut.([fn{i} '_delta']) = diff(structOut.(fn{i}),1,2) ;
                         structOut.([fn{i} '_delta_grp_u']) = nanmean(structOut.([fn{i} '_delta']),3) ;
                         structOut.([fn{i} '_delta_grp_sd']) = nanstd(structOut.([fn{i} '_delta']),0,3) ;
                     end
            end
        end
    end
end 
