function abstract(part, U_list,param, sys_set, enc_set)
    % abstract: abstract the dynamics in dyn_list = {fx1, ..., fxM}
    %
    % Dynamics:  \dot x = f_m(x, d), f polynomial
    %                                d \in drec
    % Input:
    %   fx : sdpvar vector in variables 'vars'
    %   vars : sdpvars
    %   drec : bound on disturbance variables (must be at the end of vars)
  
  if nargin < 5
    sys_set = TransSyst.sparse_set;
  end
  
  if nargin < 6
    enc_set = BDDSystem.split_enc;
  end

  part.create_ts(sys_set, enc_set);
  
  % Figure out transitions
  for m = 1:length(U_list)
    part.ts.add_action();
    for i=1:length(part)
        
       [K, bool] = reachable_set(part.cell_list(i),U_list(m),param);
       if ~bool
           % out of domain
           part.ts.add_transition(i*ones(length(part)+1,1),...
               (1:(length(part)+1))', m*ones(length(part)+1,1));
       else
           % add new transition
           for j = 1:length(part)
               if(K.intersects(part.cell_list(j)))
                   part.ts.add_transition(i, j, m);
               end
           end
       end
    end
  end

end