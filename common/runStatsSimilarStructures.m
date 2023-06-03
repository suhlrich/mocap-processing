function structOut = runStatsSimilarStructures(structIn1,structIn2) 

a = size(structIn1.KAMP1) ;
nSubs(1) = a(end) ;
a = size(structIn2.KAMP1) ;
nSubs(2) = a(end) ;

fn = fieldnames(structIn1) ;
for i = 1:numel(fn)
    if isnumeric(structIn1.(fn{i})) && ismember(nSubs(1),size(structIn1.(fn{i}))) && size(structIn1.(fn{i}),1) == 1
        nDims = length(size(structIn1.(fn{i}))) ;
        numEl2Dim = size(structIn1.(fn{i}),2) ;
%         disp(fn{i})
        switch nDims
            case 2
                     structOut.(fn{i}).dif_u = nanmean(structIn1.(fn{i}))-nanmean(structIn2.(fn{i})) ;
                     [~,structOut.(fn{i}).dif_p] = ttest2(structIn1.(fn{i}),structIn2.(fn{i})) ;
                     
                     if structOut.(fn{i}).dif_p <0.05
                         disp([fn{i} '.dif_p = ' num2str(structOut.(fn{i}).dif_p) ', and the mean is ' num2str(structOut.(fn{i}).dif_u) '.'])
                     end
                     
            case 3
                 if ~isempty(strfind(fn{i},'delta')) || size(structIn1.(fn{i}),2) == 1
                     structOut.(fn{i}).grp1_u_minus_grp2_u = nanmean(structIn1.(fn{i}))-nanmean(structIn2.(fn{i})) ;
                     [~,structOut.(fn{i}).grp1_u_minus_grp2_p] = ttest2(structIn1.(fn{i}),structIn2.(fn{i})) ;
                 
                     if structOut.(fn{i}).grp1_u_minus_grp2_p <0.05
                         disp([fn{i} '.FPAminusBL_p = ' num2str(structOut.(fn{i}).grp1_u_minus_grp2_p) ', and the mean is ' num2str(structOut.(fn{i}).grp1_u_minus_grp2_u) '.'])
                     end
                            
                 else
                     structOut.(fn{i}).BL_dif_u = nanmean(structIn1.(fn{i})(:,1,:))-nanmean(structIn2.(fn{i})(:,1,:)) ;
                     [~,structOut.(fn{i}).BL_dif_p] = ttest2(structIn1.(fn{i})(:,1,:),structIn2.(fn{i})(:,1,:)) ;

                     structOut.(fn{i}).FPA_dif_u = nanmean(structIn1.(fn{i})(:,2,:))-nanmean(structIn2.(fn{i})(:,2,:)) ;
                     [~,structOut.(fn{i}).FPA_dif_p] = ttest2(structIn1.(fn{i})(:,2,:),structIn2.(fn{i})(:,2,:)) ;
                 
                     if structOut.(fn{i}).BL_dif_p <0.05
                         disp([fn{i} '.BL_delta_p = ' num2str(structOut.(fn{i}).BL_dif_p) ', and the mean is ' num2str(structOut.(fn{i}).BL_dif_u) '.'])
                     end
                     
                     if structOut.(fn{i}).FPA_dif_p <0.05
                         disp([fn{i} '.FPA_dif_p = ' num2str(structOut.(fn{i}).FPA_dif_p) ', and the mean is ' num2str(structOut.(fn{i}).FPA_dif_u) '.'])
                     end
                 
                 end

        end
    end
end 
