function [V, Cv, cont] = win_primal(ts, A, B, C_list, quant1, quant2, V)
  % Compute winning set of
  %  []A && <>[]B &&_i []<>C_i
  % under (quant1, forall)-controllability
  % with the initial condition V ("warm start")
  %
  % Returns a sorted set
  %
  % Expanding algo
  
  if nargin<7
    V = [];
  end
  
  if strcmp(ts.sys_setting, TransSyst.bdd_set)
    if nargout == 1
      V = ts.bdd_sys.win_primal(A, B, C_list, quant1, quant2);
    elseif nargout == 2
      [V, Cv] = ts.bdd_sys.win_primal(A, B, C_list, quant1, quant2);
    elseif nargout == 3
      [V, Cv, cont] = ts.bdd_sys.win_primal(A, B, C_list, quant1, quant2);
    end
    return;
  end

  if isempty(A)
    A = uint32(1:ts.n_s);
  end
  if isempty(B)
    B = uint32(1:ts.n_s);
  end
  if isempty(C_list)
    C_list = {uint32(1:ts.n_s)};
  end

  if isa(quant1, 'char') && strcmp(quant1, 'exists')
    quant1_bool = true;
  elseif isa(quant2, 'char') && strcmp(quant1, 'forall')
    quant1_bool = false;
  else
    error('quantifier must be exists or forall')
  end

  if isa(quant2, 'char') && strcmp(quant2, 'exists')
    quant2_bool = true;
  elseif isa(quant2, 'char') && strcmp(quant2, 'forall')
    quant2_bool = false;
  else
    error('quantifier must be exists or forall')
  end

  if quant2_bool
    % Dualize
    cA = setdiff(uint32(1:ts.n_s), A);
    cB = setdiff(uint32(1:ts.n_s), B);
    cC_list = {};
    for i=1:length(C_list)
      cC_list{i} = setdiff(uint32(1:ts.n_s), C_list{i});
    end
    V = setdiff(uint32(1:ts.n_s), win_dual(cA, cC_list, cB, ~quant1_bool, ~quant2_bool));
    return
  end

  Vlist = {};
  Klist = {};

  V = uint32(V);
  A = sort(A);

  iter = 1;
  while true
    [Z,K_pre] = ts.pre(V, [], quant1_bool, false);
    [Z_pg, K_pg] = ts.pre_pg(V, A, quant1_bool);
    if(nargout > 2)
        Klist{end+1} = K_pre;
        Vlist{end+1} = Z;
        if(length(Z_pg)>length(Z))
            Klist{end+1} = K_pg;
            Vlist{end+1} = Z_pg;
        end
    end
    Z = union(Z,Z_pg);
%     Z = union(Z, ts.pre_pg(V, A, quant1_bool));
    
    if nargout > 2
      [Vt, Ct, Kt] = ts.win_intermediate(A, B, Z, C_list, quant1_bool);
    elseif nargout > 1
      [Vt, Ct] = ts.win_intermediate(A, B, Z, C_list, quant1_bool);
    else
      Vt = ts.win_intermediate(A, B, Z, C_list, quant1_bool);
    end

    if nargout > 1 && iter == 1
      C_rec = Ct;
    end

    if length(Vt) == length(V)
      break
    end

    if nargout > 2
      Klist{end+1} = Kt;
      Vlist{end+1} = Vt;
    end

    V = Vt;
    iter = iter+1;
  end

  % Candidate set
  if nargout > 1
    Cv = union(setdiff(ts.pre(V, [], quant1_bool, true), V), C_rec);
  end

  % Controller
  if nargout > 2
    cont = Controller(Vlist, Klist, 'reach', 'win_primal');
  end

end