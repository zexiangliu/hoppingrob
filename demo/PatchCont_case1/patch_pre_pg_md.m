function [Un_new] = patch_pre_pg_md(cont,ts,u_res,P_lost)
% output: Union of states of new cont
%         Union of states of old cont
    num_u = length(cont.sets);
    
%     P_lost_old = P_lost;

    P_list = cell(length(cont.sets),1); % used to set the new 'sets' for cont
    % delete lost states from cont.subcontroller{1}
    P_list{1} = setdiff(cont.subcontrollers{1}.sets,P_lost);
    cont.subcontrollers{1}.restrict_to(P_list{1});
    
%     P_inner = P_list{1};

    Un_new = cont.subcontrollers{1}.sets;
    P_l = P_lost; % record new lost states

    for i = 2:num_u
        u = cont.subcontrollers{i}.subcontrollers.values;
        u = u{1};
        if(ismember(u,u_res))
            P_l = union(P_l,cont.subcontrollers{i}.sets);
            cont.subcontrollers{i}.restrict_to([]);
            continue;
        end
        
        P_pot = intersect(P_l,ts.pg_G{u}); % potential new states
        set = union(cont.subcontrollers{i}.sets,P_pot);
        P_l = setdiff(P_l,set); % take off some states from P_l (*)
        subarray = ts.array{u}(set,:);
                
        % find states leading to states outside the 'set U P_list{i-1}'
        idx = (sum(subarray(:,union(set,Un_new)),2)-sum(subarray,2))~=0;
        subarray(idx,:) = 0;

        % find states who have no transitions
        idx = sum(subarray,2)==0;

%         P_lost = setdiff(P_lost_old,set);
        P_lost = union(P_l,set(idx));
        P_tmp = set(idx); % record new lost states
        while(1)
            idx = sum(subarray(:,P_lost),2)~=0;
            subarray(idx,:) = 0;
            P_lost = set(idx);
            P_tmp = union(P_tmp,P_lost);

            if(~any(idx))
                break;
            end
        end
        P_l = union(P_l,P_tmp); % return the left states (*) + new lost states

        P_sets = set(sum(subarray,2)~=0);
        modify_map_pg(cont.subcontrollers{i},P_sets,u);
        Un_new = union(Un_new,cont.subcontrollers{i}.sets);%%%
        
        P_list{i} = P_sets;
%         P_inner = union(P_inner,P_list{i});
    end
    
    cont.set_sets(P_list);
    
end
