function [Un_new] = patch_pre_pg_multi(cont,ts,u_res,B, P_lost)
% the one totally captures the mode of pre_pg, modified cont is the same as the real one.
% consider the potential states in P_lost as well as the potential new inputs
% output: Union of states of new cont
%         Union of states of old cont
% 
% add support to multi-action PG
%     if(isa(ts,'TransSyst')&&isempty(ts.trans_array))
%         ts = TransSyst_array_multi(ts);
%     end
    
    num_u = length(ts.pg_U);
    
    reset_pg_multi(cont,ts); %%%
%     P_lost_old = P_lost;();
    
    P_list_old = cont.sets;
    P_list = cell(length(cont.sets),1); % used to set the new 'sets' for cont
    % delete lost states from cont.subcontroller{1}
    P_list{1} = setdiff(cont.subcontrollers{1}.sets,P_lost);
    
    cont.subcontrollers{1}.restrict_to(P_list{1});
    
%     P_inner = P_list{1};
    Un_old = P_list_old{1};
    Un_new = cont.subcontrollers{1}.sets;
%     P_l = P_lost; % record new lost states in the winning set of pgpre, dZ for inv
    dZ = P_lost;
    P_l = setdiff(1:ts.n_s,Un_new);
    
    for i = 2:num_u+1
        u = ts.pg_U{i-1};
        if(any(ismember(u,u_res)))
            Un_old = union(Un_old,P_list_old{i});
            dZ = setdiff(Un_old, Un_new); % the dZ in the algorithm
            P_l = union(P_l,cont.subcontrollers{i}.sets);
            cont.subcontrollers{i}.restrict_to([]);
            continue;
        end
        
        P_pot = intersect(B,intersect(dZ,ts.pg_G{i-1})); % potential new states
        i
        set = union(cont.subcontrollers{i}.sets,P_pot); % Y_0
        P_l = setdiff(P_l,set); % take off some states from P_l (*), dY_0
        subarray = {ts.trans_array{u(1)}(set,:)};
        if(length(u)>1)
            for j = 2:length(u)
                subarray{j} = ts.trans_array{u(j)}(set,:);
            end
        end
        
        % find states leading to states outside the 'set U P_list{i-1}'
        idx = true(length(set),1);
        for j = 1:length(u)
            % Un_new here is the \widehat{Z} in Inv
%             idx_tmp = (sum(subarray{j}(:,union(set,Un_new)),2)-sum(subarray{j},2))~=0;
            idx_tmp = sum(subarray{j}(:,P_l),2)~=0; %%%
            subarray{j}(idx_tmp,:) = 0;
            idx_tmp = sum(subarray{j},2)==0;            
            % find states who have no transitions
            idx = idx&idx_tmp;
        end
        % idx is dY_1
%         P_lost = setdiff(P_lost_old,set);
        
        if length(u)==1
            P_lost = union(P_l,set(idx));
            P_tmp = set(idx); % record new lost states
            while(1)
                idx = sum(subarray{1}(:,P_lost),2)~=0;
                subarray{1}(idx,:) = 0;
%                 P_lost = union(,set(idx)); %%%%
                P_lost = set(idx); %%%%
                P_tmp = union(P_tmp,P_lost);

                if(~any(idx))
                    break;
                end
            end
            P_l = union(P_l,P_tmp); % return the left states (*) + new lost states
        else
            idx_pre = false(length(set),1);
            P_l = union(P_l,set(idx));
            while(1)
                idx_pre = idx_pre | idx;
                idx = true(length(set),1);
                for j = 1:length(u)
                    idx_tmp = sum(subarray{j}(:,P_l),2)~=0;
                    subarray{j}(idx_tmp,:) = 0;    
                    idx_tmp = sum(subarray{j},2)==0;
                    % find states who have no transitions
                    idx = idx&idx_tmp;
                end
                idx = idx & ~idx_pre;
                P_l = union(P_l,set(idx));
                
                if(~any(idx))
                    break;
                end
            end
        end
                
        if(length(u)==1)
            P_sets = set(sum(subarray{1},2)~=0);
            modify_map_pg(cont.subcontrollers{i},P_sets,u);
        else
            P_sets = modify_map_pg_multi(cont.subcontrollers{i},set,subarray,u);
        end
        
        Un_old = union(Un_old,P_list_old{i});
        Un_new = union(Un_new,cont.subcontrollers{i}.sets);%%%
        dZ = setdiff(Un_old, Un_new); % the dZ in the algorithm
        
        P_list{i} = P_sets;
%         P_inner = union(P_inner,P_list{i});
    end
    
    cont.set_sets(P_list);
    cont.clear_empty();
end
