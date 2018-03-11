function V = patch_intermediate(cont,ts,ts_array,u_res,P_lost,P,B,C_list,Vinv_lost,Vinv,A)

    if(~strcmp(cont.from,'win_intermediate'))
        error('InputError: cont isn''t from win_intermediate.')
    end
    V = cont.sets{1};
    preV = ts.pre(V, [], 1, 0);

    if(isempty(ts_array))
        ts_array = TransSyst_array(ts);
    end
    
    for i=1:length(C_list)
        cont_tmp = cont.subcontrollers{i};
        Qi = union(P, intersect(cont.sets{i+1}, preV));
        Qi_lost = setdiff(P_lost,intersect(cont.sets{i+1}, preV));
        if(strcmp(cont_tmp.from,'win_until_and_always'))
            Vi_l=patch_until_and_always(cont_tmp,ts_array,u_res,Qi_lost,Qi,...
                B,Vinv_lost,Vinv);
        elseif(strcmp(cont_tmp.from,'win_until'))
            Vi_l=patch_until(cont_tmp,ts_array,u_res,Qi_lost,Qi,B);
        else
            error('ContTypeError!')
        end
        V = setdiff(V,Vi_l);
    end
%     set_all = cont.sets;
%     set_all{1} = V;
%     
%     cont.set_sets(set_all);
    [V, ~, cont_new] = win_intermediate_patch(ts, A, B, P, C_list,V);
    cont.set_sets(cont_new.sets);
    cont.set_cont(cont_new.subcontrollers);
end

function [V, Cv, cont] = win_intermediate_patch(ts, A, B, P, C_list,V)

  quant1 = 1;
  Klist = {};

  iter = 1;
  while true
    Vt = V;
    preV = ts.pre(V, [], quant1, false);
    
    if nargout > 1
      Cv = [];
    end

    for i=1:length(C_list)
      Qi = union(P, intersect(intersect(B, C_list{i}), preV));
      Qi = reshape(Qi, 1, length(Qi));
      if nargout > 2
        [Vti, Cvi, Ki] = ts.win_until_and_always(A, B, Qi, quant1);
        Klist{i} = Ki;
      elseif nargout > 1
        [Vti, Cvi] = ts.win_until_and_always(A, B, Qi, quant1);
        Cv = union(Cv, Cvi);
      else
        Vti = ts.win_until_and_always(A, B, Qi, quant1);
      end
      Vt = intersect(Vt, Vti);
    end
    
    if nargout > 1 && iter == 1
      V1 = Vt;
      C_rec = Cv;
    end

    if length(V) == length(Vt)
      break
    end
    V = Vt;
    iter = iter + 1;
  end

  if nargout > 1
    % Contracting: C_rec U (V_1\V_last)
    Cv = union(C_rec, setdiff(V1, V));
  end

  if nargout > 2
    Vlist = {V};
    for i = 1:length(C_list)
      Vlist{end+1} = intersect(B, C_list{i});
    end
    cont = Controller(Vlist, Klist, 'recurrence', 'win_intermediate');
  end
end