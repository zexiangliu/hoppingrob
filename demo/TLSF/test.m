clc;close all;
load ts.mat;
ts.trans_array_enable();
% % ts.trans_array_dummy_enable();
A_list = 1:ts.n_s;
% C_list = {B_list(1:225),B_list(226:450)};
C_list = {};

[W] = win_primal(ts, A_list, B_list, C_list, 'exists', 'forall');
filename = 'test_abs';
abstr2TLSF(filename,ts,A_list,B_list,C_list,W);

% %%
% L = setdiff(1:ts.n_s,W);
% abstr2TLSF(filename,ts,[],[],C_list,[W,L(1)]);

%%
% clc;clear all;
% filename = 'test_abs';
% ts = TransSyst(4,9);
% s1 = [1,1,2,2,4,2,3,3,4];
% a = [1,2,3,4,5,6,7,8,9];
% s2 = [1,2,1,4,2,3,2,3,4];
% ts.add_transition(s1,s2,a);
% ts.trans_array_enable();
% % ts.trans_array_dummy_enable();
% A_list = [1,2,3,4];
% B_list = [];
% C_list = {[1],[3,4]};
% W = [];
% abstr2TLSF(filename,ts,A_list,B_list,C_list,W);

%%
% 
% clc;clear all;
% filename = 'test_abs';
% ts = TransSyst(4,9);
% s1 = [1,1,2,2,4,2,3,3,4,4,3];
% a =  [1,2,3,4,5,6,7,8,9,5,7];
% s2 = [1,2,1,4,2,3,2,3,4,3,4];
% ts.add_transition(s1,s2,a);
% U = [5,7];
% G = [3,4];
% ts.add_progress_group(U,G);
% ts.trans_array_enable();
% % ts.trans_array_dummy_enable();
% A_list = [1,2,3,4];
% B_list = [];
% C_list = {[1],[3,4]};
% W = win_primal(ts, A_list, B_list, C_list, 'exists', 'forall');
% abstr2TLSF(filename,ts,A_list,B_list,C_list,W);