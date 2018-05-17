function [Pt,Vt_new] = patch_until(cont,ts, u_res, P_lost, P, B)
    
    if(~strcmp(cont.from,'win_until') && ~strcmp(cont.from,'win_until_and_always')...
            && ~strcmp(cont.from,'win_intermediate'))
        error('InputError: cont isn''t from win_until')
    end
    
%     if(isa(ts,'TransSyst'))
%         ts = TransSyst_array_multi(ts);
%     end
    num_loop = length(cont.sets);
    set_all = cell(1,num_loop);
    set_all{1} = cont.sets{1};
    Vt_old = P;
    P_new = setdiff(P, P_lost);
    Pt = P_lost;
    Vt_new = P_new;
    % K_up and V_up records the history in case that winning set not
    % converge in num_loop iterations.
    K_up = {cont.subcontrollers{end-1}.copy,cont.subcontrollers{end}.copy};
    V_up = cell(num_loop,1);
    V_up{1} = Vt_old;
    % record convergence condition
    V_rec = zeros(num_loop,1);
    for i = 2:num_loop
        cont_tmp = cont.subcontrollers{i};
        if(strcmp(cont_tmp.from,'pre'))            
            Vt_old = union(P, intersect(B,cont.sets{i}));
            P_l = patch_pre(cont_tmp,ts,u_res,Pt);           
            set_all{i} = setdiff(cont.sets{i},P_l);         
            Vt_new = union(P_new, intersect(B,set_all{i}));
        elseif(strcmp(cont_tmp.from,'pre_pg'))
            % return the new winning set
            Vt_old = union(Vt_old, cont.sets{i});
            PG_new = patch_pre_pg_multi(cont_tmp,ts,u_res,B,Pt);
            set_all{i} = PG_new; 
            Vt_new = union(Vt_new, set_all{i});
        end  
        Pt = setdiff(Vt_old,Vt_new);
        V_up{i}=Vt_old;
        V_rec(i) = length(Vt_new);
    end
    if(length(V_up{end-2})~=length(V_up{end}))
        error('the input parameters must be wrong!');
    end
    if(V_rec(end-2)==V_rec(end))
        cont.set_sets(set_all);
    else
        % if not converge yet, keep growing the winning set
        V_up = V_up(end-1:end);
        [Vt_new, cont_new] = win_until_patch(ts, u_res, B, P_new, set_all,...
            cont.subcontrollers, Vt_new, V_up, K_up);
        Pt = setdiff(Vt_old,Vt_new);
        cont.set_sets(cont_new.sets);
        cont.set_cont(cont_new.subcontrollers);
    end
end

function [V, cont] = win_until_patch(ts, u_res, B, P, Vlist, Klist, V, V_up, K_up)

    while true
        % Normal pre
        preK = K_up{1}.copy;
        Pt = setdiff(V_up{1},V);
        P_l = patch_pre(preK, ts, u_res, Pt);
        preV = setdiff(K_up{1}.sets,P_l);
        Vt = union(P, intersect(B, preV));

        % PG pre
        preKinv = K_up{2}.copy;
        Pt = setdiff(V_up{2},Vt);
        preVinv = patch_pre_pg_multi(preKinv,ts,u_res,B, Pt);
        Vt = union(Vt, preVinv);
        Vt = reshape(Vt, 1, length(Vt));

        Vlist{end+1} = preV;
        Klist{end+1} = preK;
        Vlist{end+1} = preVinv;
        Klist{end+1} = preKinv;
        
        if length(V) == length(Vt)
            break
        end
        
        V = Vt;
        
    end
  
    cont = Controller(Vlist, Klist, 'reach', 'win_until');
end