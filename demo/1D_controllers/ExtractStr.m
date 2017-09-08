function String_list = ExtractStr(Int_list,Seg_list,Mc_l,Mc_u,r_list)
% return 1/2 max string for each holes
num_deg = length(Seg_list);

String_list = cell(size(Seg_list));

for i = 1:num_deg
    elem_int = Int_list{i};
    segments = Seg_list{i};
    
    for j = 1:length(segments)
        holes = segments{j};
        if(~isempty(holes))
            % interval
            int = elem_int(j:j+1);
            % central distance
            c_l = Mc_l(i,holes);
            c_u = Mc_u(i,holes);
            
            idx = zeros(size(c_l),'logical');
            min_c2s = 0*c_l';
            
            for l = 1:length(idx)
                if(intersect([c_l(l),c_u(l)],int))
                    idx(l)=true;
                end
            end
            
            min_c2s(idx) = 0;
            M = abs([c_l-int(2);c_u-int(1)]);
            % the min distance b.t center and string
            min_c2s(~idx) = min(M(:,~idx))'; 
            
            % 1/2 max string for each holes
            max_str = sqrt(r_list(holes).^2 - min_c2s.^2);
            String_list{i}{j} = max_str;
        end
    end

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