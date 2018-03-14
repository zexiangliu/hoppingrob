clc;clear all;
load ts_exper_until

close all;

cont_ref = load('ts_cons_until.mat','cont');
cont_ref = cont_ref.cont;

%% Patching
Z_lost = [1:99];
u_res = [1:10];
cont2=cont.copy;
P_l = patch_until(cont2,ts, u_res, Z_lost, Z, B_list')

% save ts_general

%%
V_old = [];

for i = 1:length(cont.sets)
    V_old = union(V_old,cont.sets{i});
end

V_new = [];

for i = 1:length(cont2.sets)
    V_new = union(V_new,cont2.sets{i});
end

P_l_ref = setdiff(V_old,V_new);

length(P_l_ref)==length(P_l)
setdiff(P_l_ref,P_l)
