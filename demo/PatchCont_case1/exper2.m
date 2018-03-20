clc;clear all; close all;
load radiant
%%
tic;
[W, ~, cont,V_Compl,K_Compl] = ts.win_primal_patch([], part.get_cells_with_ap({'SET'}), [], 'exists', 'forall');
t_syn = toc

%%

ts_ref = ts;

[W, ~, cont,V_Compl,K_Compl] = ts_ref.win_primal_patch([], part.get_cells_with_ap({'SET'}), [], 'exists', 'forall');

%%
clc
u_res = [];
cont2 = cont.copy;
K_Compl2 = cell(size(K_Compl));

for i = 1:length(K_Compl2)
    K_Compl2{i}=K_Compl{i}.copy;
end

tic;
[W2] = patch_primal(cont2,ts,u_res,[],part.get_cells_with_ap({'SET'}),[],[],[]);
t_pat = toc

%%

compare_conts(cont2,cont)

%%
Z = union(V_Compl{3},V_Compl{4});
[W,~,cont_pre] = ts.pre_pg_patch([],1:ts.n_s,1);
%%
W2 = patch_pre_pg_multi(cont_pre,ts,[],1:ts.n_s,Z)