clc;clear all;
load ts_exper

close all;

cont_ref = load('ts_cons.mat','cont');
cont_ref = cont_ref.cont;

%% Patching
Z_lost = [];
u_res = [1:10];

A_list = uint32(1:ts.n_s);
[Vinv, ~, cont_inv] = ts.win_intermediate(uint32(1:ts.n_s), A_list, [], {uint32(1:ts.n_s)}, 1);

%%
cont_inv2 = cont_inv.copy;
Vinv_lost = patch_until(cont_inv2.subcontrollers{1},ts,u_res,[], [],A_list);

%%
cont2=cont.copy;
P_l = patch_intermediate(cont2,ts,[], u_res, Z_lost, Z, B_list',C_list,Vinv_lost,Vinv,A_list)

% save ts_general
