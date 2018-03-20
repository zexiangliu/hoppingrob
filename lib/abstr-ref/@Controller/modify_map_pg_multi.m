function P_sets = modify_map_pg_multi(cont,sets,subarray,u)
    
    subc = containers.Map('KeyType', 'uint32', 'ValueType',...
        'any');
    % state-action matrix
    sa_mat = zeros(length(sets),length(u),'logical');
    for i = 1:length(u)
        sa_mat(:,i)=sum(subarray{i},2)~=0;
    end
    
    for i = 1:length(sets)
        u_tmp = u(sa_mat(i,:));
        if(~isempty(u_tmp))
            subc(sets(i)) = u(sa_mat(i,:));
        end
    end
    
    cont.subcontrollers = subc;
    P_sets = cell2mat(cont.subcontrollers.keys);
    % modify the '.sets' in cont
    cont.sets = P_sets;
end