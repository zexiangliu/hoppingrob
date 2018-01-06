function [set,sa_map,idx_mod]=cont2sa(ts,cont,u_res)
% The input control structure must be 'simple'
    n_s = length(cont.sets);
    set = cont.sets;
    sa_map = zeros(n_s,ts.n_a,'logical');
    
%     for i = 1:n_s
%         sa_map(i,cont.subcontrollers(cont.sets(i)))=1;
%     end
    
    keys = cell2mat(cont.subcontrollers.keys);
    values = cont.subcontrollers.values;
    
    [~,ia] = intersect(keys,cont.sets);
    
    for i = 1:n_s
        sa_map(i,values{ia(i)})=1;
    end

    idx_mod = sum(sa_map(:,u_res),2)~=0;
    sa_map(:,u_res)=0;
%     sa_map = sparse(sa_map);
end