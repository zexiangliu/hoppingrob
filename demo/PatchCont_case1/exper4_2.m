clc;clear all;
load ts_exper_sp.mat
ts_exper = load('ts_exper_sp');
ts_cons = load('ts_cons_sp1');
U_res = ts_cons.U_res;
close all;
%%
T_syn = cell(1,length(U_res));
T_mod = T_syn;
ts_ref = T_syn;
cont_ref = T_syn;
cont_patch = T_syn;
ts.trans_array_enable();
for i = 1:length(U_res)
    ts_cons = load(['ts_cons_sp',num2str(i)]);
    ts_ref{i} = ts_cons.ts;
    T_syn{i} = ts_cons.t_syn
    cont_ref{i} = ts_cons.cont;
    %% Patching
    
    u_res = U_res{i};
%     u_res = [1,3,5,7];
    % cont_inv2 = cont_inv.copy;

%     [Vinv_ref, ~, cont_inv_ref] = ts_ref.win_intermediate(uint32(1:ts_ref.n_s), A_list, [], {uint32(1:ts_ref.n_s)}, 1);

    Vinv_new = patch_intermediate(cont_inv,ts,u_res,[], [],A_list,{uint32(1:ts_ref{i}.n_s)},[],[]);
    % 
    Vinv_lost = setdiff(Vinv,Vinv_new);
    %%
    ts_exper = load('ts_exper_sp','cont');
    cont_patch{i} = ts_exper.cont;

%     Vinv_lost = [];
%     Vinv = 1:ts.n_s;
    % A_list = 1:ts.n_s;
    % tic
    % profile on
    tic;
    V = patch_primal(cont_patch{i},ts,u_res,A_list,B_list',C_list,Vinv_lost,Vinv);
    T_mod{i} = toc
    % profile viewer
    % t_patch = toc
    % save ts_general
    %%
    compare_conts(cont_patch{i},cont_ref{i})
end