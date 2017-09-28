function [SwPt_list, Cont_list, Ures_list] = ContGener_simp(Bnd_list,Dist_list,M_X,M_U,cont_ref,ts)
% simplified version of ContGener
% do not arrange controllers anymore, directly use one controller whose
% state space is large enough.
    num_deg = length(Dist_list);
    bnd_X = M_X.bnd(1,:);
    bnd_U = M_U.bnd(1,:);
    
    X = M_X.V{1};
    U = M_U.V{1};
    
    len_X = bnd_X(2)-bnd_X(1);
    len_U = bnd_U(2)-bnd_U(1);
    
    SwPt_list = cell(size(Dist_list));
    Ures_list = {};
    Cont_list = {};
    
    % used for "refinement"
    n1 = length(M_X.V{1});
    n2 = length(M_X.V{2});

    V1 = M_X.V{1}(1:floor(n1/2));
    V2 = M_X.V{2}((ceil(n2/2)+1):end);

    [Vx,Vy]=meshgrid(V1,V2);
    
    
    for i = 1:num_deg
        Dist = Dist_list{i};
        Bnd  = Bnd_list{i};
        SwPt_list{i} = cell(length(Dist),1);
        for j = 1:length(Dist)
            if(isempty(Dist{j}))
                continue;
            end
            
            % Generate primitive controllers
            tmp_U = U;
            u_res = [];
            % find the disabled actions
            for k = 1:length(tmp_U)
                u = tmp_U(k);
                if(abs(u)>Bnd{j}||any(u>=Dist{j}(:,1)&u<=Dist{j}(:,2)))
                    u_res = [u_res,k];
                end
            end
            % match the dis. act with existing controllers, add if not
            % exist.
            tmp_u_res = num2str(u_res);
            [bool,pos]=ismember(tmp_u_res,Ures_list);
            if(~bool)
                Ures_list{end+1} = tmp_u_res;
                tmp_cont = copy(cont_ref);
                patch_cont_md(tmp_cont,ts,u_res);
                Cont_list{end+1} = tmp_cont.sets{end};
                SwPt_list{i}{j}{end+1} = length(Cont_list);
            else
                SwPt_list{i}{j}{end+1} = pos;
            end
            
            i
            length(Cont_list)
        end
    end

end