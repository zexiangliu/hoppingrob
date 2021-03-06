% clc;clear all;
% load ts_exper_rand3.mat
% ts_exper = load('ts_exper_rand3');
% ts_cons = load('ts_cons_rand3');
% U_res = ts_cons.U_res;
% ts_ref = ts_cons.ts_ref;
% t_syn = ts_cons.t_syn;
% cont_ref = ts_cons.cont_ref;
% close all;
% %%
% t_patch =  cell(1,length(U_res));
% cont_patch = t_patch; 
% t_naive = t_patch;
% cont_naive = cont_patch;
% 
% B_list_new=[];
% C_list_new=[];
% num_X = length(W);
% num_U = M_U.numV-1;
% W2new = zeros(ts.n_s,1);
% 
% for i = 1:num_X
%     W2new(W(i)) = i;
% end
% 
% for i =1:length(W)
%     if(ismember(W(i),B_list))
%         B_list_new =[B_list_new;i];
%     end
% %     if(ismember(W(i),C_list))
% %         C_list_new =[C_list_new;i];
% %     end
% end


for i = 38:length(U_res)
    %% Patching
    
    u_res = U_res{i};
%     u_res = [1,3,5,7];
    % cont_inv2 = cont_inv.copy;

    % [Vinv_ref, ~, cont_inv_ref] = ts_ref.win_intermediate(uint32(1:ts_ref.n_s), A_list, [], {uint32(1:ts_ref.n_s)}, 1);

    % Vinv_new = patch_intermediate(cont_inv2,ts,u_res,[], [],A_list,{uint32(1:ts_ref.n_s)},[],[]);
    % 
%     Vinv_lost = setdiff(Vinv,Vinv_new);
    %%
    ts_exper = load('ts_exper_rand3','cont');
    cont_patch{i} = ts_exper.cont;

    Vinv_lost = [];
    Vinv = 1:ts.n_s;
    % A_list = 1:ts.n_s;
    % tic
%     profile on
    tic;
    V = patch_primal(cont_patch{i},ts,u_res,A_list,B_list',C_list,Vinv_lost,Vinv);
    t_patch{i} = toc
%     profile viewer
    % t_patch = toc
    % save ts_general
    
    assert(compare_conts(cont_ref{i},cont_patch{i}))
    i
    %%
    ts_tmp = TransSyst(num_X+1,num_U-length(u_res)); 
%     state1 = ts_ref{i}.state1;
%     state2 = ts_ref{i}.state2;
%     action = ts_ref{i}.action;
%     com1 = setdiff(1:ts.n_s,W);
%     state2_new = state2;
%     for j = 1:length(com1)
%         idx1 = state1==com1(j);        
%         state1(idx1)=[];
%         action(idx1)=[];
%         state2(idx1)=[];
%         state2_new(idx1)=[];
%         idx2 = state2==com1(j);
%         state2_new(idx2)=ts.n_s;
%     end
%     state2 = state2_new;
%     state1_new = state1;
%     
%     for j = 1:length(W)
%         state1_new(state1==W(j))=j;
%         state2_new(state2==W(j))=j;
%     end
%     state1_new(state1==ts.n_s)=num_X+1;
%     state2_new(state2==ts.n_s)=num_X+1;
%     ts_tmp.add_transition(state1_new,state2_new,action);
%     ts_naive{i} = ts_tmp;
%     ts_naive{i}.trans_array_enable();%           
%     for j = 1:length(ts_ref{i}.pg_U)
%         pg_U = ts_ref{i}.pg_U{j};
%         if(~any(ismember(u_res,pg_U)))
%             pg_G = W2new(intersect(ts_ref{i}.pg_G{j},W));
%             ts_naive{i}.add_progress_group(pg_U,...
%                 pg_G);
%         end
%     end

    tic;
    ts_tmp.trans_array_copy(ts_ref{i},W,setdiff(1:ts.n_a,u_res));
    ts_naive{i} = ts_tmp;
%     ts_naive{i}.trans_array_enable();
  
    [V,~,cont_naive{i}] = ts_naive{i}.win_primal_patch([], B_list_new, ... 
                                     C_list_new, 'exists', 'forall');
    t_naive{i} = toc
    % profile viewer
    % t_patch = toc
    % save ts_general
    %%
    assert(length(cont_ref{i}.sets{end})==length(V))
end

%%

t_p = cell2mat(t_patch);
t_s = cell2mat(t_syn)';
t_n = cell2mat(t_naive);
%%
ratio1 = t_p./t_s
ratio2 = t_n./t_s
ratio3 = t_p./t_n
avg1 = mean(reshape(ratio1,[10,6]),1)
avg2 = mean(reshape(ratio2,[10,6]),1)
avg3 = mean(reshape(ratio3,[10,6]),1)
avg_syn = mean(reshape(t_s,[10,6]),1)
avg_naive = mean(reshape(t_n,[10,6]),1)
avg_patch = mean(reshape(t_p,[10,6]),1)



