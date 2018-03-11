clc;clear all;
load ts_exper

close all;

cont_ref = load('ts_cons.mat','cont');
cont_ref = cont_ref.cont;

%% Patching
Z_lost = [];
u_res = [1:10];
cont2=cont.copy;
P_l = patch_until(cont2,ts, u_res, Z_lost, Z, B_list')

% save ts_general
