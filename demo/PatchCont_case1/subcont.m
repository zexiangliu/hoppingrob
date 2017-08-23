classdef subcont < handle

    properties
        set;
        sa_map;
        subarray;
        idx_lost;
        idx_mod;
    end

    methods
        function sc = subcont(ts,cont,u_res)
            [sc.set,sc.sa_map,sc.idx_mod] = cont2sa(ts,cont,u_res);            
            sc.subarray = sa2subarray(sc,ts.array);
            sc.idx_lost = zeros(length(sc.set),1,'logical');
        end
    end
end