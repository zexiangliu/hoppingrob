function adding_progress_group(M_X,M_U,ts)
    num_X =M_X.numV;  % remove the sink node
    num_U = M_U.numV; 
    g = 10;
    for i = 1: num_U -1
        u = M_U.get_coord(i);
        if(u(2)==0) % if u(2) == 0, there's no equilibra
            continue;
        end
        q0 =[u(1);-10/u(2);0;0]; % coordinates of equilibra
        idx_q0 = mapping(q0,M_X,[0;0;0;0]);
        PG = 1:num_X-1;
        if(idx_q0 ~= num_X)
            PG(idx_q0) = [];
        end
        ts.add_progress_group(i,PG);
    end
end