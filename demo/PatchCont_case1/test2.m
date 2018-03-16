clc;clear all;
load ts_exper.mat

close all;
%%
cont_ref = load('ts_cons.mat');
V_Compl_ref = cont_ref.V_Compl;
K_Compl_ref = cont_ref.K_Compl;
ts_ref = cont_ref.ts;
cont_ref = cont_ref.cont;
%% Patching

u_res = [1:10];
cont_inv2 = cont_inv.copy;

% [Vinv_ref, ~, cont_inv_ref] = ts_ref.win_intermediate(uint32(1:ts_ref.n_s), A_list, [], {uint32(1:ts_ref.n_s)}, 1);

Vinv_new = patch_intermediate(cont_inv2,ts,u_res,[], [],A_list,{uint32(1:ts_ref.n_s)},[],[]);
% 
Vinv_lost = setdiff(Vinv,Vinv_new);
%%
cont2=cont.copy;

% Vinv_lost = [];
% Vinv = 1:ts.n_s;
% A_list = 1:ts.n_s;
% tic
% profile on
V = patch_primal(cont2,ts,u_res,A_list,B_list',C_list,V_Compl,K_Compl,Vinv_lost,Vinv)
% profile viewer
% t_patch = toc
% save ts_general
%%
compare_conts(cont2,cont_ref)