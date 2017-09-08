function Dist_list = ProjHole(holes,Seg_list,Str_list,list_deg,delta_deg)
% Project the holes into the lines which go through them.
    num_deg = length(Seg_list);
    num_hole = length(holes);
    
    Dist_list = cell(size(Seg_list));
    
    Phi = zeros(num_hole,1);
    Mag = Phi;
    for j = 1:num_hole
            pos = holes{j}.pos;
            Phi(j) = atan2d(pos(1),pos(2));
            Mag(j) = norm(pos);
    end
    
    for i = 1:num_deg
        
        lb = Phi + list_deg(i) - delta_deg/2;
        ub = Phi + list_deg(i) + delta_deg/2;
        
        [C_l,C_u] = bnd_sin(lb,ub,Mag);
        
        segments = Seg_list{i};
        strings = Str_list{i};
        
        for j = 1:length(segments)
            hole_in_line = segments{j};
            if(~isempty(hole_in_line))
                Dist_list{i}{j} = [C_l(hole_in_line)-strings{j},C_u(hole_in_line)+strings{j}];
            end
        end
    end
end