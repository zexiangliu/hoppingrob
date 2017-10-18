function [SwPt_list, Cont_list, Ures_list] = ContGener(Bnd_list,Dist_list,M_X,M_U,cont_ref,ts)
    num_deg = 1%length(Dist_list);
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
            
            pointer = -Bnd{j}; % pos of origin of state space r.w.t. map coord
            % Generate primitive controllers
            break_flag = 0;
            while(1)
                tmp_U = U + pointer + len_X/2;
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
                    Cont_list{end+1} = tmp_cont;
                    SwPt_list{i}{j}{end+1} = [pointer,length(Cont_list)];
                else
                    SwPt_list{i}{j}{end+1} = [pointer,pos];
                end
                
                if(break_flag == 1)
                    break;
                end
                
                pointer = pointer + len_X;
                if(pointer + len_X > Bnd{j})
                    pointer = pointer - floor((pointer+len_X-Bnd{j})/M_X.gridsize(1))*M_X.gridsize(1);
%                     pointer = Bnd{j}-len_X;
                    break_flag = 1;
                end
            end
            
            % "refinement" part
%             for k = 1:5
            while(1)
                winning_full = comb_win(SwPt_list{i}{j},M_X,Cont_list);
               
                
                % -len_X to avoild convoluting at the end of ROI, for
                % adding controllers there will change nothing.
                num_l = floor((Bnd_list{i}{j}*2-len_X)/M_X.gridsize(1));
                
                if(num_l<=0)
                    break;
                end
                freq = zeros(num_l,1);
                
                tmp_Vx = Vx - Bnd_list{i}{j} + len_X/2;
%                 tmp_Vx_para = Vx - Bnd_list{i}{j} + len_X/2;
                tmp_Vy = Vy;
                
                for l = 1:num_l
%                      tmp_Vx = tmp_Vx_para + (l-1)*M_X.gridsize(1);
                     mask = [tmp_Vx(:),tmp_Vy(:)];
                     freq(l) = conv_win(winning_full,mask,M_X.gridsize(1)/2);
                     tmp_Vx = tmp_Vx + M_X.gridsize(1);
                end
                
                % Kick off the first two results, since adding controllers
                % in the very beginning will not change anything.
                freq(1:2) = 1;
                
                freq_expected = min(freq); 
                
                % If there are multiple minimum, choose the rightest one.
                pos_list = find(freq == freq_expected);
                pos_point = pos_list(end);
                
                pointer = -Bnd{j}+(pos_point-1)*M_X.gridsize(1);
                
                % add controller to the point where freq is lowest
                tmp_U = U + pointer + len_X/2;
                u_res = [];
                % find the disabled actions
                for k = 1:length(tmp_U)
                    u = tmp_U(k);
                    if(abs(u)>Bnd{j}||any(u>=Dist{j}(:,1)&u<=Dist{j}(:,2)))
                        u_res = [u_res,k];
                    end
                end
                
                tmp_u_res = num2str(u_res);
                [bool,pos]=ismember(tmp_u_res,Ures_list);
                if(~bool)
                    Ures_list{end+1} = tmp_u_res;
                    tmp_cont = copy(cont_ref);
                    patch_cont_md(tmp_cont,ts,u_res);
                    Cont_list{end+1} = tmp_cont;
                    SwPt_list{i}{j}{end+1} = [pointer,length(Cont_list)];
                else
                    SwPt_list{i}{j}{end+1} = [pointer,pos];
                end
                
                
                % check the performance
                winning_full = comb_win(SwPt_list{i}{j},M_X,Cont_list);
                tmp_Vx = Vx + pointer + len_X/2;
                tmp_Vy = Vy;
                mask = [tmp_Vx(:),tmp_Vy(:)];
                freq_true = conv_win(winning_full,mask,M_X.gridsize(1)/2);
                
                if(freq_true>freq_expected)
                    continue;
                else
                    if(~bool)
                        Ures_list(end) = [];
                        Cont_list(end) = [];
                        SwPt_list{i}{j}(end) =[];
                    else
                        SwPt_list{i}{j}(end) =[];
                    end
                    break;
                end
                
            end
            
            i
            length(Cont_list)
        end
    end

end