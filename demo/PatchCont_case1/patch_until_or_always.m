function P_l = patch_until_or_always(cont,ts,u_res,P_lost)
% Input: cont must be the one with type 'simple'
%        u_res: the input restricted
%        P_lost: the states no longer in P_inner

    subc = subcont(ts,cont,u_res);
    % find states not feasiable due to restricted inputs and add into the
    % set P_lost

    P_l = restrict_u(subc); % record new lost states.
    P_lost = union(P_lost,P_l);
    
    % find state not feasiable due to P_lost iteratively.
    while(1)
        P_lost = restrict_P(subc,P_lost);%union(P_lost,restrict_P(P_lost));    
        P_l = union(P_l,P_lost);
        if(isempty(P_lost))
            break;
        end
    end
    cont.modify_map(subc,P_l)
end
