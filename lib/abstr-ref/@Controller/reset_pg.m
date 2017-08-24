function reset_pg(cont,num_u)
% add empty subcontrollers in cont with type 'pre_pg'
    num_s = length(cont.sets)-1;
    l_u = zeros(num_s,1);
    for i = 1:num_s
        u = cont.subcontrollers{i+1}.subcontrollers.values;
        l_u(i) = u{1};
    end
    cont.sets(l_u+1) = cont.sets(2:end);
    cont.subcontrollers(l_u+1) = cont.subcontrollers(2:end);
  
    % the inputs left which need to be complemented.
    l_c = setdiff(1:num_u,l_u);  
    for i = 1:length(l_c)
        cont.sets{l_c(i)+1}=[];
        cont.subcontrollers{l_c(i)+1}=Controller([], containers.Map('KeyType', 'uint32', 'ValueType', 'any'), 'simple');
    end
end