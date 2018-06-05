% clc;close all;
% load ts.mat;
% ts.trans_array_enable();
% ts.trans_array_dummy_enable();
% A_list = 1:ts.n_s;
% C_list = {B_list(1:225),B_list(226:450)};
% 
% [W] = win_primal(ts, [], [], C_list, 'exists', 'forall');
% filename = 'test_abs';
% abstr2TLSF(filename,ts,[],[],C_list,W);

%%
filename = 'test_abs';
ts = TransSyst(5,9);
s1 = [1,1,2,2,4,2,3,3,4];
a = [1,2,3,4,5,6,7,8,9];
s2 = [1,2,1,4,2,3,2,3,4];
ts.add_transition(s1,s2,a);
ts.trans_array_enable();
ts.trans_array_dummy_enable();
A_list = [1,2,4];
B_list = [];
C_list = {[1],[2,3,4]};
W = [];
abstr2TLSF(filename,ts,A_list,B_list,C_list,W);
