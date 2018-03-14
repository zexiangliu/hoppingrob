clc;clear all;
load ts_exper_inter

close all;
%%
cont_ref = load('ts_cons_inter.mat','cont');
cont_ref = cont_ref.cont;

%% Patching
A_list = uint32(1:ts.n_s);
[Vinv, ~, cont_inv] = ts.win_intermediate(uint32(1:ts.n_s), A_list, [], {uint32(1:ts.n_s)}, 1);

%%
cont_inv2 = cont_inv.copy;
Vinv_lost = patch_until(cont_inv2.subcontrollers{1},ts,u_res,[], [],A_list);

%%
cont2=cont.copy;
u_res = [1:10];
Z_lost = [1:100];

V = patch_intermediate(cont2,ts, u_res, Z_lost, Z, B_list',C_list,Vinv_lost,Vinv)

% save ts_general
