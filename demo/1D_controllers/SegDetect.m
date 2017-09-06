function lines = SegDetect(Mc,Md)
    
    [num_deg, num_hole] = size(Mc);
    lines = cell(num_hole,1);
    
    M_l = Mc-Md;
    M_u = Mc+Md;
    
    for i = 1:num_deg
        
        % element intervals
        elem_int = unique([M_l(i,:),M_u(i,:)]);
        % num of intervals
        num_int = length(elem_int)-1;
        segments = cell(num_int);
        % decompose intervals to elem intervals, save results in 'segments'
        for j = 1:num_int
            for k = 1:num_hole
                if(intersect([M_l(i,k);M_u(i,k)],elem_int(j:j+1)'))
                    segments{j} = [segments{j},k];
                end
            end
        end
        % find lines
        for j = 1:num_int
            if(~isempty(segments{j}))
                np = numel(segments{j});
                lines{np} = unique([lines{np},{num2str(segments{j})}]);                
            end
        end
    end

end

function bool = intersect(int1,int2)
    
    center1 = mean(int1);
    center2 = mean(int2);
    
    len1 = abs(int1(1)-int1(2))/2;
    len2 = abs(int2(1)-int2(2))/2;
    
    dis = abs(center1-center2);
    if(dis<= len1+len2)
        bool = true;
    else
        bool = false;
    end
end