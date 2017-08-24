function patch_cont_md(cont,ts,u_res)
    ts_arr = TransSyst_array(ts);
    sets_old = cont.sets;
    P = []; % input P of function win_eventually_or_persistence
    num_loop = length(cont.sets)/3;
    set_all = cell(num_loop,1);

    P_l = patch_until_or_always(cont.subcontrollers{3}.subcontrollers{1},ts_arr,u_res,[]);
    cont.subcontrollers{3}.set_sets({cont.subcontrollers{3}.subcontrollers{1}.sets});
    set_all{3} = cont.subcontrollers{3}.subcontrollers{1}.sets;

    P_lost = P_l;
    for i = 2:num_loop

        patch_pre(cont.subcontrollers{i*3-2},ts_arr,u_res,P_lost);
        set_all{i*3-2} = union(P,cont.subcontrollers{i*3-2}.sets);

        [U_n] = patch_pre_pg_md(cont.subcontrollers{i*3-1},ts_arr,u_res,P_lost);
        set_all{i*3-1} = union(set_all{i*3-2},U_n);
        
        P_lost = setdiff(union(sets_old{i*3-2},sets_old{i*3-1}),set_all{i*3-1});
        P_lost = setdiff(P_lost,cont.subcontrollers{i*3}.subcontrollers{1}.sets); 
        patch_until_or_always(cont.subcontrollers{i*3}.subcontrollers{1},ts_arr,u_res,P_lost);
        set_all{i*3} = union(set_all{i*3-1},cont.subcontrollers{i*3}.subcontrollers{1}.sets)';
        
        % P_lost prepared for next patch_pre
        P_lost = setdiff(sets_old{i*3},set_all{i*3});
        
        cont.subcontrollers{i*3}.set_sets({set_all{i*3}});
    end


    cont.set_sets(set_all);
end