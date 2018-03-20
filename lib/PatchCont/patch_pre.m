function P_l = patch_pre(cont,ts,u_res,P_lost)
    try
        subc = subcont(ts,cont,u_res);
    catch
        keyboard()
        subc = subcont(ts,cont,u_res);
    end
    % find states not feasiable due to restricted inputs and add into the
    % set P_lost

    P_l = restrict_u(subc); % record new lost states.
    
    % find state not feasiable due to P_lost iteratively.
    P_l = union(P_l,restrict_P(subc,P_lost));

    cont.modify_map(subc,P_l)
end