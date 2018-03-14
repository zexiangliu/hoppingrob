function V_new = patch_primal(cont,ts,u_res,A,B,C_list,V,V_Compl,K_Compl,Vinv_lost,Vinv,ts_ref)

if(isa(ts,'TransSyst'))
    ts = TransSyst_array(ts);
end

set_all = cont.sets;
V_lost = [];

cont_up = cont.subcontrollers{end}.copy; 
V_up = cont.sets{end};
K1_up = K_Compl{end-3}.copy;
K2_up = K_Compl{end-2}.copy;
Z1_up = V_Compl{end-3};
Z2_up = V_Compl{end-2};

for i = 1:length(cont.sets)
    if(~isempty(V_Compl{2*i}))
        Z1_l = patch_pre(K_Compl{2*i-1},ts,u_res,V_lost);
        Z2_new = patch_pre_pg_md2(K_Compl{2*i},ts,u_res,A,V_lost);
    else
        Z1_l = [];
        Z2_new = [];
    end
    
    Z_new = union(setdiff(V_Compl{2*i-1},Z1_l),Z2_new)';
    Z_old = union(V_Compl{2*i-1},V_Compl{2*i});
    Z_lost = setdiff(Z_old,Z_new);
    
    cont_tmp = cont.subcontrollers{i};
    V_new = patch_intermediate(cont_tmp,ts,u_res,Z_lost,Z_old,B,C_list,Vinv_lost,Vinv,ts_ref);
    
    V_lost = setdiff(set_all{i},V_new);
    
    set_all{i} = V_new;
end

K_list = cont.subcontrollers;
% while true
%     Z1_l = patch_pre(K1_up.copy,ts,u_res,V_lost);
%     Z2_l = patch_pre_pg_md2(K2_up.copy,ts,u_res,V_lost);
%     Z_new = union(setdiff(Z1_up,Z1_l),setdiff(Z2_up,Z2_l));
%     Z_lost = setdiff(Z_old,Z_new);
%     
%     cont_tmp = cont_up.copy;
%     V_new = patch_intermediate(cont_tmp,ts,u_res,Z_lost,Z_old,B,C_list,Vinv_lost,Vinv);
%     
%     if(length(V_new) == length(set_all{end}))
%         break;
%     end
%     
%     V_lost = setdiff(V_up,V_new);
% 
%     set_all{end+1}=V_new;
%     K_list{end+1} = cont_tmp;
%     
% end

cont.set_sets(set_all);
cont.set_cont(K_list);
end

