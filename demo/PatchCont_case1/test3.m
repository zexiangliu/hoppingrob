clc;clear all;
load ts_exper.mat
ts_exper = load('ts_exper');
W = ts_exper.W;
ts_cons = load('ts_cons_rand');
U_res = ts_cons.U_res;
ts_ref = ts_cons.ts_ref;
t_syn = ts_cons.t_syn;
cont_ref = ts_cons.cont_ref;
close all;

%% restrict the abstraction to the winning set of ideal case
num_X = length(W);
num_U = M_U.numV-1;

for i = 41:length(ts_ref)
    ts_tmp = TransSyst(num_X+1,num_U); 
    state1 = ts_ref{i}.state1;
    state2 = ts_ref{i}.state2;
    action = ts_ref{i}.action;
    com1 = setdiff(1:ts.n_s,W);
    state2_new = state2;
    for j = 1:length(com1)
        idx1 = state1==com1(j);        
        state1(idx1)=[];
        action(idx1)=[];
        state2(idx1)=[];
        state2_new(idx1)=[];
        idx2 = state2==com1(j);
        state2_new(idx2)=ts.n_s;
    end
    state2 = state2_new;
    state1_new = state1;
    
    for j = 1:length(W)
        state1_new(state1==W(j))=j;
        state2_new(state2==W(j))=j;
    end
    state1_new(state1==ts.n_s)=num_X+1;
    state2_new(state2==ts.n_s)=num_X+1;
    ts_tmp.add_transition(state1_new,state2_new,action);
    ts_ref{i} = ts_tmp;
    ts_ref{i}.create_fast();
end

B_list_new=[];
C_list_new=[];
for i =1:length(W)
    if(ismember(W(i),B_list))
        B_list_new =[B_list_new;i];
    end
%     if(ismember(W(i),C_list))
%         C_list_new =[C_list_new;i];
%     end
end
B_list = B_list_new; C_list = C_list_new;
%%
t_patch =  cell(1,length(U_res));
cont_patch = t_patch;
for i = 41:length(U_res)
    %% Patching
    
    u_res = U_res{i};
%     u_res = [1,3,5,7];
    % cont_inv2 = cont_inv.copy;

    % [Vinv_ref, ~, cont_inv_ref] = ts_ref.win_intermediate(uint32(1:ts_ref.n_s), A_list, [], {uint32(1:ts_ref.n_s)}, 1);

    % Vinv_new = patch_intermediate(cont_inv2,ts,u_res,[], [],A_list,{uint32(1:ts_ref.n_s)},[],[]);
    % 
%     Vinv_lost = setdiff(Vinv,Vinv_new);
    %%

%     Vinv_lost = [];
%     Vinv = 1:ts.n_s;
    % A_list = 1:ts.n_s;
    % tic
    % profile on
    tic;
%     V = patch_primal(cont_patch{i},ts,u_res,A_list,B_list',C_list,Vinv_lost,Vinv)
    [V,~,cont_patch{i}] = ts_ref{i}.win_primal_patch([], B_list, ... 
                                     C_list, 'exists', 'forall');
    t_patch{i} = toc
    % profile viewer
    % t_patch = toc
    % save ts_general
    %%
    assert(length(cont_ref{i}.sets{end})==length(V))
end

%%
avg_syn = mean(reshape(cell2mat(t_syn),[10,6]),1)
avg_patch = mean(reshape(cell2mat(t_patch),[10,2]),1)