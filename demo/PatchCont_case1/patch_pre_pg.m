function [Un_new,Un_old] = patch_pre_pg(cont,ts_arr,u_res,P_lost)
% output: Union of states of new cont
%         Union of states of old cont
    num_u = length(cont.sets);
    
    P_lost_old = P_lost;
    Un_old = cont.subcontrollers{1}.sets;

    P_list = cell(length(cont.sets),1); % used to set the new 'sets' for cont
    % delete lost states from cont.subcontroller{1}
    P_list{1} = setdiff(cont.subcontrollers{1}.sets,P_lost);
    cont.subcontrollers{1}.restrict_to(P_list{1});
   
    Un_new = cont.subcontrollers{1}.sets;

    for i = 2:num_u
        u = cont.subcontrollers{i}.subcontrollers.values;
        u = u{1};
        if(ismember(u,u_res))
            Un_old = union(Un_old,cont.subcontrollers{i}.sets);
            P_lost_old = union(P_lost_old,cont.subcontrollers{i}.sets);
            cont.subcontrollers{i}.restrict_to([]);
            continue;
        end
        
        set = cont.subcontrollers{i}.sets;
        subarray = ts_arr.array{u}(set,:);

%         P_lost = setdiff(P_lost_old,set);
        P_lost = P_lost_old;
        P_tmp = []; % record new lost states
        while(1)
            idx = sum(subarray(:,P_lost),2)~=0;
            subarray(idx,:) = 0;
            P_lost = set(idx);
            P_tmp = union(P_tmp,P_lost);

            if(~any(idx))
                break;
            end
        end
        P_lost_old = union(P_lost_old,P_tmp); % P_lost_old + new lost states in last pg (reason is in pginv)

        P_sets = setdiff(cont.subcontrollers{i}.sets,P_tmp);

        Un_old = union(Un_old,cont.subcontrollers{i}.sets);
        cont.subcontrollers{i}.restrict_to(P_sets);
        Un_new = union(Un_new,cont.subcontrollers{i}.sets);
        
        P_list{i} = P_sets;
    end
    
    cont.set_sets(P_list);
    
end
