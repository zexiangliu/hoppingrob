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
avg_patch = mean(reshape(cell2mat(t_patch),[10,6]),1)