function V = patch_intermediate(cont,ts,u_res,P_lost,P,B,C_list,Vinv_lost,Vinv)

    if(~strcmp(cont.from,'win_intermediate'))
        error('InputError: cont isn''t from win_intermediate.')
    end
%    if(isa(ts,'TransSyst'))
%         ts = TransSyst_array_multi(ts);
%     end
    
    V = cont.sets{1};
    preV = ts.pre(V, 1:ts.n_a, 1, 0);
    preV_new = ts.pre(V, setdiff(1:ts.n_a,u_res),1,0);
    
    Q = cell(1,length(C_list));
    P_new = setdiff(P,P_lost);
    for i=1:length(C_list)
        cont_tmp = cont.subcontrollers{i};
        Q{i} = union(P, intersect(cont.sets{i+1}, preV));
        Qi_new = union(P_new, intersect(cont.sets{i+1}, preV_new));
        Qi_lost = setdiff(Q{i},Qi_new);
        if(strcmp(cont_tmp.from,'win_until_and_always'))
            Vi_l=patch_until_and_always(cont_tmp,ts,u_res,Qi_lost,Q{i},...
                B,Vinv_lost,Vinv);
        elseif(strcmp(cont_tmp.from,'win_until'))
            Vi_l=patch_until(cont_tmp,ts,u_res,Qi_lost,Q{i},B);
        else
            error('ContTypeError!')
        end
        Q{i} = Qi_new;
        V = setdiff(V,Vi_l);
    end
    
    if(isempty(V))
        cont.set_sets({});
        cont.set_cont({});
        return;
    end
    
%     set_all = cont.sets;
%     set_all{1} = V;
%     
%     cont.set_sets(set_all);
%     BC_list = cont.sets(2:end);
%     Klist = cont.subcontrollers;
    [V, cont_new] = win_intermediate_patch(ts,B, cont.sets(2:end), setdiff(P,P_lost),u_res, ...
                    Vinv_lost, Vinv,V,cont.subcontrollers,Q);
%     [V, ~, cont_new] = win_intermediate(ts_ref,B, BC_list, P_new,V,Klist);
    cont.set_sets(cont_new.sets);
    cont.set_cont(cont_new.subcontrollers);
end

function [V, cont] = win_intermediate_patch(ts,B, BC_list, P,u_res, ...
    Vinv_lost, Vinv,V,Klist,Q_pre)

%     quant1 = 1;
    Q_new = cell(1,length(BC_list));
    iter = 1;
    u_list = setdiff(1:ts.n_a,u_res);
    Vt = V;
    while true
        preV = ts.pre(V, u_list,1,0);

        for i=1:length(BC_list)
            Q_new{i} = union(P, intersect(BC_list{i}, preV));
            Qi_lost = setdiff(Q_pre{i},Q_new{i});
            if(strcmp(Klist{i}.from,'win_until_and_always'))
              Vti_l = patch_until_and_always(Klist{i},ts,u_res,Qi_lost,Q_pre{i},B, Vinv_lost, Vinv);
            elseif(strcmp(Klist{i}.from,'win_until'))
              [Vti_l] = patch_until(Klist{i},ts,u_res,Qi_lost,Q_pre{i},B);
            end
            Vt = setdiff(Vt,Vti_l);
            Q_pre{i} = Q_new{i};
        end

        if(isempty(Vt))
            cont = Controller({uint32([])},{}, 'recurrence', 'win_intermediate');
            V = [];
            return;
        end
        
        if length(V) == length(Vt)
            break
        end
        V = Vt;
        iter = iter + 1;
    end
    Vlist = {V};
    for i = 1:length(BC_list)
      Vlist{end+1} = BC_list{i};
    end
    cont = Controller(Vlist, Klist, 'recurrence', 'win_intermediate');
end
