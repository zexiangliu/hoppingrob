function modify_map_pg(cont,P_set,u)
    
    set = cont.sets;
    new_keys = uint32(setdiff(P_set,set));

    for i=1:length(new_keys)
        cont.subcontrollers(new_keys(i)) = u;
    end
    % modify the '.sets' in cont
    cont.sets = P_set;
end