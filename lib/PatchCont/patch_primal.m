function V_new = patch_primal(cont,ts,u_res,A,B,C_list,Vinv_lost,Vinv)
%     input: cont---controller to be modified
%            ts --- abstraction FTS
%            u_res---removed inputs
%            A,B,C_list --- intput parameters of win_primal
%            V_Compl, K_Compl --- outputs of win_primal
%            Vinv_lost --- the states removed from Vinv after u_res is removed
%            Vinv --- the invariant set calculated by Win([]A)
%    output: V_new --- modified winning sets

if isempty(A)
    A = uint32(1:ts.n_s);
end
if isempty(B)
    B = uint32(1:ts.n_s);
end
if isempty(C_list)
    C_list = {uint32(1:ts.n_s)};
end

V_Compl = cont.patch_info{1};
K_Compl = cont.patch_info{2};
    
if(nargin <=6||isempty(Vinv_lost)&&isempty(Vinv))
    if length(A) == ts.n_s
        Vinv = 1:ts.n_s;
        Vinv_lost = [];
    else
        [Vinv, ~, cont_inv] = ts.win_intermediate(uint32(1:ts.n_s), A,...
            [], {uint32(1:ts.n_s)}, 1);
        Vinv_new = patch_intermediate(cont_inv,ts,u_res,[], [],A_list,...
            {uint32(1:ts_ref.n_s)},[],[]);
        if(isempty(Vinv_new))
            disp('[]A cannot hold.')
            V_new = [];
            return;
        end
        Vinv_lost = setdiff(Vinv,Vinv_new);
    end
end


% if(isa(ts,'TransSyst') && isempty(ts.trans_array))
%     ts.trans_array_enable();%TransSyst_array_multi(ts);
% end

set_all = cont.sets;
V_lost = [];

cont_up = cont.subcontrollers{end}.copy; 
V_up = cont.sets{end};
K1_up = K_Compl{end-1}.copy;
K2_up = K_Compl{end}.copy;
Z1_up = V_Compl{end-1};
% Z2_up = V_Compl{end};

is_converge = false;
V_new = []; Ud = 1:ts.n_a; Ud(u_res)=[];

for i = 1:length(cont.sets)
    if(~isempty(V_Compl{2*i}))
%         Z1_l = patch_pre(K_Compl{2*i-1},ts,u_res,V_lost);
        Z1_new = ts.pre(V_new,Ud,1,0);
        Z2_new = patch_pre_pg_lg(K_Compl{2*i},ts,u_res,A,V_lost);
    else
%         Z1_l = [];
        Z1_new = V_Compl{2*i-1};
        Z2_new = [];
    end
    
%     Z_new = union(setdiff(V_Compl{2*i-1},Z1_l),Z2_new)';
    Z_new = union(Z1_new,Z2_new);
    Z_old = union(V_Compl{2*i-1},V_Compl{2*i});
    Z_lost = setdiff(Z_old,Z_new);
    
    cont_tmp = cont.subcontrollers{i};
    V_new = patch_intermediate(cont_tmp,ts,u_res,Z_lost,Z_old,B,C_list,...
        Vinv_lost,Vinv);
    V_lost = setdiff(set_all{i},V_new);
    
    if(i~=1 && length(set_all{i-1}) == length(V_new))
        set_all=set_all(1:i-1);
        K_list = cont.subcontrollers(1:i-1);
        is_converge = true;
        break;
    end
    
    set_all{i} = V_new;
end

if(isempty(V_new))
    set_all={};
    K_list = {};
    cont.set_sets(set_all);
    cont.set_cont(K_list);
    disp('Winning set is empty.');
    return;
end

if(~is_converge)
    K_list = cont.subcontrollers;
    while true
%         Z1_l = patch_pre(K1_up.copy,ts,u_res,V_lost);
        Z1_new = ts.pre(V_new,Ud,1,0);
        Z2_new = patch_pre_pg_lg(K2_up.copy,ts,u_res,A,V_lost);
%         Z_new = union(setdiff(Z1_up,Z1_l),Z2_new);
        Z_new = union(Z1_new,Z2_new);
        Z_lost = setdiff(Z_old,Z_new);

        cont_tmp = cont_up.copy;
        V_new = patch_intermediate(cont_tmp,ts,u_res,Z_lost,Z_old,B,...
              C_list,Vinv_lost,Vinv);

        if(length(V_new) == length(set_all{end}))
            break;
        end

        V_lost = setdiff(V_up,V_new);

        set_all{end+1}=V_new;
        K_list{end+1} = cont_tmp;
    end
end
cont.set_sets(set_all);
cont.set_cont(K_list);
end

