function [Int_list,Seg_list] = SegDetect(M_l,M_u)
% Given an interval matrix, find the intersections for each row of the matrix.
% Input:    Mc --- Center matrix
%           Md --- Delta matrix
% Output:   Int_list --- list of elements intervals for each direction of
%                        lines
%           Seg_list --- list of holes in each element interval in each
%                        direction

    [num_deg, num_hole] = size(M_l);
%     lines = cell(num_hole,1);
    
    Int_list = cell(num_deg,1);
    Seg_list = cell(num_deg,1);

    for i = 1:num_deg
        
        % element intervals
        elem_int = unique([M_l(i,:),M_u(i,:)]);
        
        Int_list{i} = elem_int;
        
        % num of intervals
        num_int = length(elem_int)-1;
        segments = cell(num_int,1);
        % decompose intervals to elem intervals, save results in 'segments'
        for j = 1:num_int
            for k = 1:num_hole
                if(intersect([M_l(i,k);M_u(i,k)],elem_int(j:j+1)'))
                    segments{j} = [segments{j},k];
                end
            end
        end
        
        Seg_list{i} =  segments;
        
%         % find lines
%         for j = 1:num_int
%             if(~isempty(segments{j}))
%                 np = numel(segments{j});
%                 lines{np} = unique([lines{np},{num2str(segments{j})}]);                
%             end
%         end
    end

end

function bool = intersect(int1,int2)
    
    center1 = mean(int1);
    center2 = mean(int2);
    
    len1 = abs(int1(1)-int1(2));
    len2 = abs(int2(1)-int2(2));
    
    dis = abs(center1-center2);
    if(2*dis+1e-10 < (len1+len2)) % add 1e-10 for overcoming numerical error; in practice, we neglect extreme tiny intersections.
        bool = true;
    else
        bool = false;
    end
end