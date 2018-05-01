clc;clear all;
num_X = 4;
num_U = 9;
ts = TransSyst(num_X,num_U); 

ts.add_transition(1,1,1);
ts.add_transition(1,2,2);
ts.add_transition(2,1,3);
ts.add_transition(2,4,4);
ts.add_transition(4,2,5);
ts.add_transition(2,3,6);
ts.add_transition(3,2,7);
ts.add_transition(3,3,8);
ts.add_transition(4,4,9);

ts.create_fast();

A_list = 1:4;
B_list = 1:4;
C_list = {[1],[3,4]};
[W,~,cont] = ts.win_primal(A_list,B_list,C_list,'exists','forall')
% 
% ts_ref = TransSyst(num_X,num_U); 
% 
% ts_ref.add_transition(1,1,1);
% ts_ref.add_transition(1,2,2);
% ts_ref.add_transition(2,1,3);
% ts_ref.add_transition(2,4,4);
% ts_ref.add_transition(2,3,6);
% ts_ref.add_transition(3,2,7);
% ts_ref.add_transition(3,3,8);
% ts_ref.add_transition(4,4,9);
% 
% tic;
% [W_ref,~,cont_ref] = ts_ref.win_primal_patch(A_list,B_list,C_list,'exists','forall')
% t_syn = toc
% 
% 
% cont2 = cont.copy;
% u_res = [5];
% Vinv_lost = [];
% Vinv = 1:4;
% 
% tic;
% V = patch_primal(cont2,ts,u_res,A_list,B_list',C_list,Vinv_lost,Vinv)
% t_patch = toc
% 
% compare_conts(cont_ref,cont2)

% 
% cont.cont_trim();
% cont2.cont_trim();