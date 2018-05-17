function modify_map_pg_lg(cont,set,P_set,u,sp_temp)
    
    set(cont.sets)=false;
    new_keys = uint32(sp_temp(set));

    for i=1:length(new_keys)
        cont.subcontrollers(new_keys(i)) = u;
    end
    % modify the '.sets' in cont
    cont.sets = P_set;
end