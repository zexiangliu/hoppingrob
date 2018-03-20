function reset_pg_multi(cont,ts)
% add empty subcontrollers in cont with type 'pre_pg'
    num_u = length(ts.pg_U);
    num_s = length(cont.subcontrollers);
    l_u = zeros(num_u,1);
    for i = 2:num_s
        idx_u = cont.subcontrollers{i}.patch_info;
        l_u(idx_u) = 1;
    end
    l_u = find(l_u==1);
    cont.sets(l_u+1) = cont.sets(2:end);
    cont.subcontrollers(l_u+1) = cont.subcontrollers(2:end);
  
    % the inputs left which need to be complemented.
    l_c = setdiff(1:num_u,l_u);  
    for i = 1:length(l_c)
        cont.sets{l_c(i)+1}=[];
        cont.subcontrollers{l_c(i)+1}=Controller([], containers.Map('KeyType', 'uint32', 'ValueType', 'any'), 'simple');
        cont.subcontrollers{l_c(i)+1}.patch_info = l_c(i);
    end
end