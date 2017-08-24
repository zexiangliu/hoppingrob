function [W, Cw, cont] = pre_pg_ures(ts, V, B, quant1,u_res)
  % pre_pg: pre(V) under (quant1, forall) while remaining in B using progress groups
  % 
  % Returns a sorted set
  Vlist = cell(1e4,1);
  Klist = cell(1e4,1);
  counter = 1;
  
  W = uint32(V);
  Vlist{1} = V;
  Cw = [];
  Klist{1} = Controller(W, containers.Map(), 'simple');
  counter = counter + 1;
  
  for i=1:length(ts.pg_U)
    if(ismember(ts.pg_U{i},u_res))
        continue;
    end
    % Progress groups
    if nargout > 2
      [preVinv, Cw, preKinv] = ts.pginv(ts.pg_U{i}, ts.pg_G{i}, W, B, quant1);
      if ~isempty(preVinv)
        Vlist{counter} = preVinv;
        Klist{counter} = preKinv;
        counter = counter + 1;
      end
    elseif nargout > 1
      [preVinv, Cw] = ts.pginv(ts.pg_U{i}, ts.pg_G{i}, W, B, quant1);
    else
      preVinv = ts.pginv(ts.pg_U{i}, ts.pg_G{i}, W, B, quant1);
    end
    W = union(W, preVinv);
    W = reshape(W, 1, length(W));
  end

  if nargout > 2
    cont = Controller(Vlist(1:counter-1), Klist(1:counter-1), 'reach', 'pre_pg');
  end
end