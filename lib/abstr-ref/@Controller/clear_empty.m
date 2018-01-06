function clear_empty(cont)
    num_sets = length(cont.sets);
    idx = zeros(num_sets,1,'logical');
    for i = 1:num_sets
        if(isempty(cont.sets{i}))
            idx(i)=1;
        end
    end
    list = find(idx);
    cont.sets(list)=[];
    cont.subcontrollers(list) = [];
end