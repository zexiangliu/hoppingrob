clc;clear all; close all;
load radiant

tic;
[W, ~, cont,V_Compl,K_Compl] = ts.win_primal_patch([], part.get_cells_with_ap({'SET'}), [], 'exists', 'forall');
t_syn = toc

%%
u_res = [1];
tic;
[W2] = patch_primal(cont,ts,u_res,[],part.get_cells_with_ap({'SET'}),[],V_Compl,K_Compl,[],[]);
t_pat = toc