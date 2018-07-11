function [V, Cv, cont] = win_primal_patch(ts, A, B, C_list, quant1, quant2, V)
  % Compute winning set of
  %  []A && <>[]B &&_i []<>C_i
  % under (quant1, forall)-controllability
  % with the initial condition V ("warm start")
  %
  % Returns a sorted set
  %
  % Expanding algo
  global Vinv Cvinv

  if nargin<7
    V = [];
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
  
  flag_inv = false;
  if(length(A)~=ts.n_s)
      [Vinv, Cvinv, ~] = ts.win_intermediate(uint32(1:ts.n_s), A, [], {uint32(1:ts.n_s)}, quant1_bool);
      flag_inv = true;
  end
  
  iter = 1;
  while true
    if nargout > 2
        [V1,~,K1] = ts.pre_pg_patch(V, A, quant1_bool);
        [V2,K2] = ts.pre(V, [], quant1_bool, false);
    elseif nargout > 1
        V1 = ts.pre_pg(V, A, quant1_bool);
        V2 = ts.pre(V, [], quant1_bool, false);
    end
    Z = union(V1, V2);
    
    if nargout > 2
      [Vt, Ct, Kt] = ts.win_intermediate_patch(A, B, Z, C_list, quant1_bool);
    elseif nargout > 1
      [Vt, Ct] = ts.win_intermediate_patch(A, B, Z, C_list, quant1_bool);
    else
      Vt = ts.win_intermediate_patch(A, B, Z, C_list, quant1_bool);
    end

    if nargout > 1 && iter == 1
      C_rec = Ct;
    end

    if nargout > 2
        
      if flag_inv
%         K2.restrict_to(Vinv);
        Vlist{end+1} = V1;
        Vlist{end+1} = union(V1,intersect(V2,Vinv));
      else
        Vlist{end+1} = V1;
        Vlist{end+1} = union(V1,V2);
      end
      Klist{end+1} = K1;
      Klist{end+1} = K2;
      Klist{end+1} = Kt;
      Vlist{end+1} = Vt;
    end

    if length(Vt) == length(V)
      break
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
