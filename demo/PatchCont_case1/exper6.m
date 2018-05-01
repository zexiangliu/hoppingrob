clc;clear all;
num_X = 4;
num_U = 8;
ts = TransSyst(num_X,num_U); 

ts.add_transition(1,2,2);
ts.add_transition(2,3,4);
ts.add_transition(3,4,6);
ts.add_transition(4,1,8);
ts.add_transition(2,1,1);
ts.add_transition(3,2,3);
ts.add_transition(4,3,5);
ts.add_transition(1,4,7);

ts.create_fast();

A_list = 1:4;
B_list = 1:4;
C_list = {[1],[3]};
[W,~,cont] = ts.win_primal(A_list,B_list,C_list,'exists','forall')
 %% remove (s1,s2,2)
ts_ref1 = TransSyst(num_X,num_U); 

ts_ref1.add_transition(2,3,4);
ts_ref1.add_transition(3,4,6);
ts_ref1.add_transition(4,1,8);
ts_ref1.add_transition(2,1,1);
ts_ref1.add_transition(3,2,3);
ts_ref1.add_transition(4,3,5);
ts_ref1.add_transition(1,4,7);


tic;
[W_ref1,~,cont_ref1] = ts_ref1.win_primal(A_list,B_list,C_list,'exists','forall')
t_syn = toc


% cont2 = cont.copy;
% u_res = [5];
% Vinv_lost = [];
% Vinv = 1:4;
%  
%% remove (s1,s4,7)
ts_ref2 = TransSyst(num_X,num_U); 


ts_ref2.add_transition(1,2,2);
ts_ref2.add_transition(2,3,4);
ts_ref2.add_transition(3,4,6);
ts_ref2.add_transition(4,1,8);
ts_ref2.add_transition(2,1,1);
ts_ref2.add_transition(3,2,3);
ts_ref2.add_transition(4,3,5);

tic;
[W_ref2,~,cont_ref2] = ts_ref2.win_primal(A_list,B_list,C_list,'exists','forall')
t_syn = toc


% cont2 = cont.copy;
% u_res = [5];
% Vinv_lost = [];
% Vinv = 1:4;
 
% tic;
% V = patch_primal(cont2,ts,u_res,A_list,B_list',C_list,Vinv_lost,Vinv)
% t_patch = toc
% 
% compare_conts(cont_ref,cont2)

% 
% cont.cont_trim();
% cont2.cont_trim();