clc;clear all;
load ts_exper.mat
ts_exper = load('ts_exper');
ts_cons = load('ts_cons_rand');
U_res = ts_cons.U_res;
ts_ref = ts_cons.ts_ref;
t_syn = ts_cons.t_syn;
cont_ref = ts_cons.cont_ref;
close all;
%%
t_patch =  cell(1,length(U_res));
cont_patch = t_patch;
for i = 1:length(U_res)
    %% Patching
    
    u_res = U_res{i};
%     u_res = [1,3,5,7];
    % cont_inv2 = cont_inv.copy;

    % [Vinv_ref, ~, cont_inv_ref] = ts_ref.win_intermediate(uint32(1:ts_ref.n_s), A_list, [], {uint32(1:ts_ref.n_s)}, 1);

    % Vinv_new = patch_intermediate(cont_inv2,ts,u_res,[], [],A_list,{uint32(1:ts_ref.n_s)},[],[]);
    % 
%     Vinv_lost = setdiff(Vinv,Vinv_new);
    %%
    ts_exper = load('ts_exper','cont');
    cont_patch{i} = ts_exper.cont;

    Vinv_lost = [];
    Vinv = 1:ts.n_s;
    % A_list = 1:ts.n_s;
    % tic
    % profile on
    tic;
    V = patch_primal(cont_patch{i},ts,u_res,A_list,B_list',C_list,Vinv_lost,Vinv)
    t_patch{i} = toc
    % profile viewer
    % t_patch = toc
    % save ts_general
    %%
    assert(compare_conts(cont_ref{i},cont_patch{i}))
end

%%
avg_syn = mean(reshape(cell2mat(t_syn),[10,6]),1)
avg_patch = mean(reshape(cell2mat(t_patch),[10,6]),1)