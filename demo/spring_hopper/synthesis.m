clear all;close all;clc;
load ts.mat
ts.trans_array_enable();
B_list = mapping_ext(0.0,M_X,0.2);
C_list = {};
% C1 = mapping_ext(-0.5,M_X,0.5);
% C2 = mapping_ext(0.5,M_X,0.5);
% C_list = {C1, C2};

%%
[W, ~, cont]=ts.win_primal([],B_list,[],'exists','forall');

% [W, C, cont]=ts.win_eventually_or_persistence([],{B_list'},1);

save cont.mat