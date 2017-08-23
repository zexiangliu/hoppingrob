function modify_map(cont,subc,P_l)
    % delete lost states in map container
    idx = find(subc.idx_lost==1);
    for i = 1:length(idx)
        cont.subcontrollers.remove(subc.set(idx(i)));
    end
    
    % modify "modified states" in map container
    idx = find((subc.idx_mod&~subc.idx_lost)==1);
    for i = 1:length(idx)
        s = subc.set(idx(i)); % global idx of state
        cont.subcontrollers(s) = find(subc.sa_map(idx(i),:)==1);
    end

    % modify the '.sets' in cont
    cont.sets = setdiff(cont.sets,P_l);
end