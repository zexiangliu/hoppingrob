clear all;clc;close all;

load ts_cons_rand
%% with u_res

for i = 51:60%length(U_res)
    u_res = U_res{i};
    % TransSyst
    ts_ref{i} = ArrayGener_parallel(M_X,M_U,tau,r,lmax,u_res);
    disp('Done.')
    %% Controller
    disp('Compute winning set and controller...')

    % ts_ref.add_progress_group([1,20],uint32(1:3500));
%     ts_ref.add_progress_group([15,20],uint32(1:3000));
%     ts_ref.add_progress_group([18,20],uint32(1:3500));

    ts_ref{i}.create_fast();
    tic;
    % [W, C, cont]=ts.win_primal([],B_list'W,[],'exists','forall');
    [W_tmp, ~, cont_tmp] = ts_ref{i}.win_primal_patch(A_list, B_list, ... 
                                     C_list, 'exists', 'forall');
    
    W_ref{i} = W_tmp;
    cont_ref{i} = cont_tmp;
    t_syn{i} = toc
    
end

% ts_name = 'ts_cons_rand2';
% save(ts_name);