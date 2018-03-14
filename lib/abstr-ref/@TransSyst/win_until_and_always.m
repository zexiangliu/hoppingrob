function [V, Cv, cont] = win_until_and_always(ts, A, B, P, quant1)
  % Compute the winning set of
  %   []A && B U P
  % under (quant1, forall)-controllability
  %
  % Note: A must be sorted
  % Returns a sorted set
  if ~isempty(setdiff(1:ts.n_s, A))
    % Need to worry about []A
    if nargout > 2
      [Vinv, Cvinv, cont_inv] = ts.win_intermediate(uint32(1:ts.n_s), A, [], {uint32(1:ts.n_s)}, quant1);
      [V, Cvu, cont] = ts.win_until(intersect(B, Vinv), intersect(P, Vinv), quant1);
      cont.from = 'win_until_and_always';% while true
%     Z1_l = patch_pre(K1_up.copy,ts,u_res,V_lost);
%     Z2_l = patch_pre_pg_md2(K2_up.copy,ts,u_res,V_lost);
%     Z_new = union(setdiff(Z1_up,Z1_l),setdiff(Z2_up,Z2_l));
%     Z_lost = setdiff(Z_old,Z_new);
%     
%     cont_tmp = cont_up.copy;
%     V_new = patch_intermediate(cont_tmp,ts,u_res,Z_lost,Z_old,B,C_list,Vinv_lost,Vinv);
%     
%     if(length(V_new) == length(set_all{end}))
%         break;
%     end
%     
%     V_lost = setdiff(V_up,V_new);
% 
%     set_all{end+1}=V_new;
%     K_list{end+1} = cont_tmp;
%     
% end

      Cv = union(Cvinv, Cvu);
    elseif nargout > 1
      [Vinv, Cvinv] = ts.win_intermediate(uint32(1:ts.n_s), A, [], {uint32(1:ts.n_s)}, quant1);
      [V, Cvu] = ts.win_until(intersect(B, Vinv), intersect(P, Vinv), quant1);
      Cv = union(Cvinv, Cvu);
    else
      Vinv = ts.win_intermediate(uint32(1:ts.n_s), A, [], {uint32(1:ts.n_s)}, quant1);
      V = ts.win_until(intersect(B, Vinv), intersect(P, Vinv), quant1);
    end
  else
    % No need to worry about []A
    if nargout > 2
      [V, Cv, cont] = ts.win_until(B, P, quant1);
      cont.from = 'win_until';
    elseif nargout > 1
      [V, Cv] = ts.win_until(B, P, quant1);
    else
      V = ts.win_until(B, P, quant1);
    end
  end
end
