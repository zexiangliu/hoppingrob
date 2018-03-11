function Pt = patch_until(cont,ts, u_res, P_lost, P, B)
    
    if(~strcmp(cont.from,'win_until') && ~strcmp(cont.from,'win_until_and_always')...
            && ~strcmp(cont.from,'win_intermediate'))
        error('InputError: cont isn''t from win_until')
    end
    
    if(isa(ts,'TransSyst'))
        ts = TransSyst_array(ts);
    end
    num_loop = length(cont.sets);
    set_all = cell(num_loop,1);
    set_all{1} = cont.sets{1};
    Vt_old = P;
    Vt_new = setdiff(P, P_lost);
    Pt = P_lost;
    for i = 2:num_loop
        cont_tmp = cont.subcontrollers{i};
        if(strcmp(cont_tmp.from,'pre'))            
            Vt_old = union(Vt_old, intersect(B,cont.sets{i}));
            P_l = patch_pre(cont_tmp,ts,u_res,Pt);           
            set_all{i} = setdiff(cont.sets{i},P_l);         
            Vt_new = union(Vt_new, intersect(B,set_all{i}));
        elseif(strcmp(cont_tmp.from,'pre_pg'))
            % return the new winning set
            Vt_old = union(Vt_old, intersect(B,cont.sets{i}));
            P_l = patch_pre_pg_md2(cont_tmp,ts,u_res,Pt);
            set_all{i} = P_l; 
            Vt_new = union(Vt_new, set_all{i});
        end  
        Pt = setdiff(Vt_old,Vt_new);
    end
    
    cont.set_sets(set_all);
end