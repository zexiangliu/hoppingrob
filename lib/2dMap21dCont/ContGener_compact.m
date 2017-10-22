function [SwPt_list, Cont_list, Ures_list, Bnd_Grid,Win_list] = ContGener_compact(Bnd_list,Dist_list,M_X,M_U,cont_ref,ts)
% the compact version of ContGener
% 'compact' refers that we try to minimize the number of controllers
    disp('Initialization');
    num_deg = length(Dist_list);
%     bnd_X = M_X.bnd(1,:);
%     bnd_U = M_U.bnd(1,:);
    
%     X = M_X.V{1};
%     U = M_U.V{1};
    
%     len_X = bnd_X(2)-bnd_X(1);
%     len_U = bnd_U(2)-bnd_U(1);
    num_U = length(M_U.V{1});
    % template 1 vector used for conv_bin
    templ_u = ones(num_U,1);
    
    SwPt_list = cell(size(Dist_list));
    Ures_list = {num2str([])};
    Cont_list = {cont_ref.sets{end}};
    
    % used for "refinement"
%     n1 = length(M_X.V{1});
%     n2 = length(M_X.V{2});
    half_bnd = [M_X.bnd(1,1),M_X.bnd(1,1)+(M_X.bnd(1,2)-M_X.bnd(1,1))/6];
%     V1 = M_X.V{1}(1:floor(n1/2));
%     V2 = M_X.V{2}((ceil(n2/2)+1):end);

%     [Vx,Vy]=meshgrid(V1,V2);
    
    % Discretize the bnd and holes
    Bnd_Grid = cell(size(Dist_list));
    Dist_bin = cell(size(Dist_list));
    Conv_list = cell(size(Dist_list));
    % save the discretized state space of each line as winning candidate
    Win_list = cell(size(Dist_list)); 
    for i = 1:num_deg
        Dist = Dist_list{i};
        Bnd  = Bnd_list{i};
        for j = 1:length(Dist)
            if(isempty(Dist{j}))
                continue;
            end
            tmp_U.bnd = [-Bnd{j},Bnd{j}];
            tmp_U.gridsize = M_U.gridsize;
            Bnd_Grid{i}{j} = GridGener(tmp_U);
            
            tmp_numV = Bnd_Grid{i}{j}.numV-1;
            
            tmp_bin = ones(max(tmp_numV,num_U),1);
            for k=1:tmp_numV
                u = Bnd_Grid{i}{j}.V{1}(k);
                if(any(u<Dist{j}(:,1)|u>Dist{j}(:,2)))
                    tmp_bin(k) = 0;
                end
            end
            
            Dist_bin{i}{j}=tmp_bin;
            Conv_list{i}{j} = conv_bin(tmp_bin(2:end-1),templ_u);
            
            % Generate winning candidates
            Win_list{i}{j}=win_cand(Bnd{j},M_X);
        end
    end
    
    
    % Generate primitive controllers (the beginning place and the end place)     
    disp('Generate primitive controllers')
    for i = 1:num_deg
        Dist = Dist_bin{i};
        Bnd  = Bnd_Grid{i};
        SwPt_list{i} = cell(length(Dist),1);
        for j = 1:length(Dist)
            if(isempty(Dist{j}))
                continue;
            end
            
            % first controller
            pointer = 1;
            % find the disabled actions
            u_res = find(Dist{j}(1:num_U))';
            % match the dis. act with existing controllers, add if not
            % exist.
            tmp_u_res = num2str(u_res);
            [bool,pos]=ismember(tmp_u_res,Ures_list);
            if(~bool)
                Ures_list{end+1} = tmp_u_res;
                tmp_cont = copy(cont_ref);
                patch_cont_md(tmp_cont,ts,u_res);
                Cont_list{end+1} = tmp_cont.sets{end};
                pos = length(Cont_list);
            end
            SwPt_list{i}{j}{end+1} = [pointer,pos];
            
            origin = Bnd{j}.V{1}(pointer)-M_U.V{1}(1);
            search_win(Win_list{i}{j},M_X,Cont_list{pos},origin);
        
            % the last controller
            pointer = length(Dist{j})-num_U + 1;
            u_res = find(Dist{j}(pointer:end))';
            
            tmp_u_res = num2str(u_res);
            [bool,pos]=ismember(tmp_u_res,Ures_list);
            if(~bool)
                Ures_list{end+1} = tmp_u_res;
                tmp_cont = copy(cont_ref);
                patch_cont_md(tmp_cont,ts,u_res);
                Cont_list{end+1} = tmp_cont.sets{end};
                pos = length(Cont_list);
            end
            
            SwPt_list{i}{j}{end+1} = [pointer,pos];
            
            origin = Bnd{j}.V{1}(pointer)-M_U.V{1}(1);
            search_win(Win_list{i}{j},M_X,Cont_list{pos},origin);
        end
        i
    end
    
    for i = 1:length(Cont_list)
        u_res = zeros(num_U,1);
        u_res(str2num(Ures_list{i}))=1;
        for j = 1:num_deg
            Dist = Dist_bin{j};
            Bnd  = Bnd_Grid{j};
            Conv = Conv_list{j};
            for k = 1:length(Dist)
                if(isempty(Dist{k}))
                    continue;
                end
                bin = Dist{k};
                tmp_conv = conv_bin(bin(2:end-1),u_res);
                if(all(u_res==0))
                    conv_idx = find(tmp_conv==Conv{k});
                   for l = conv_idx'
                        search_win(Win_list{j}{k},M_X,Cont_list{i},origin); 
                        SwPt_list{j}{k}{end+1} = [l+1,i];
                        disp("Bingo!");
                    end
                else
                    conv_idx = find(tmp_conv==Conv{k}&Conv{k}~=0);
                    for l = conv_idx'
                        old_M = sum(Win_list{j}{k}.M(:));
                        origin = Bnd{j}.V{1}(l+1)-M_U.V{1}(1);
                        search_win(Win_list{j}{k},M_X,Cont_list{i},origin); 
                        new_M = sum(Win_list{j}{k}.M(:));
                        if(old_M>new_M)
                            SwPt_list{j}{k}{end+1} = [l+1,i];
                            disp("Bingo!");
                        end
                    end
                end
                
            end
        end
    end
    
    for i = 1:num_deg
        Dist = Dist_bin{i};
        Bnd  = Bnd_Grid{i};
        for j = 1:length(Dist)
            if(isempty(Dist{j}))
                continue;
            end
    % "refinement" part
%             for k = 1:5
            while(1)               
                % -len_X to avoild convoluting at the end of ROI, for
                % adding controllers there will change nothing.
                num_l = Bnd{j}.numV-num_U-1;%floor((Bnd_list{i}{j}*2-len_X)/M_X.gridsize(1));
                
                if(num_l<=0)
                    break;
                elseif(num_l<=2) % adding controllers here won't change too much
                    continue;
                end
                
                freq = zeros(num_l,1);
                
%                 origin = Bnd{j}.V{1}(1)-M_U.V{1}(1);
                
                for l = 1:num_l                
                     origin =  Bnd{j}.V{1}(l)-M_U.V{1}(1);
                     mask = half_bnd+origin;
                     freq(l) = conv_win(Win_list{i}{j},mask);
                end
                
                % Kick off the first two results, since adding controllers
                % in the very beginning will not change anything.
          
                freq(1:2) = 0;
                
                freq_expected = max(freq); 
                
                % If there are multiple minimum, choose the rightest one.
                pos_list = find(freq == freq_expected);
                pointer = pos_list(end);
                
                % add controller to the point where freq is lowest
                u_res = find(Dist{j}(pointer:pointer+num_U-1)==1)';
                
                tmp_u_res = num2str(u_res);
                [bool,pos]=ismember(tmp_u_res,Ures_list);
                if(~bool)
                    Ures_list{end+1} = tmp_u_res;
                    tmp_cont = copy(cont_ref);
                    patch_cont_md(tmp_cont,ts,u_res);
                    Cont_list{end+1} = tmp_cont.sets{end};
                    pos = length(Cont_list);
                end
                
                SwPt_list{i}{j}{end+1} = [pointer,pos];
                
                % update Win_list
                origin = Bnd{j}.V{1}(pointer)-M_U.V{1}(1);
                search_win(Win_list{i}{j},M_X,Cont_list{pos},origin); 
                
                % check the performance
                mask = half_bnd+origin;
                freq_true = conv_win(Win_list{i}{j},mask);

                
                if(freq_true<freq_expected)
                    
                    conv_u = zeros(num_U,1);
                    conv_u(u_res)=1;
                    
                    if(~bool)
                        idx_cont = length(Cont_list);
                        for j2 = 1:num_deg
                            Dist2 = Dist_bin{j2};
                            Bnd2  = Bnd_Grid{j2};
                            Conv2 = Conv_list{j2};
                            for k2 = 1:length(Dist2)
                                if(isempty(Dist2{k2}))
                                    continue;
                                end
                                bin = Dist2{k2};
                                tmp_conv = conv_bin(bin(2:end-1),conv_u);
                                conv_idx = find(tmp_conv==Conv2{k2}&Conv2{k2}~=0);
                                for l = conv_idx'
                                    old_M = sum(Win_list{j2}{k2}.M(:));
                                    origin = Bnd2{k2}.V{1}(l+1)-M_U.V{1}(1);
                                    search_win(Win_list{j2}{k2},M_X,Cont_list{end},origin);
                                    
                                    new_M = sum(Win_list{j2}{k2}.M(:));
                                    if(old_M>new_M)
                                        SwPt_list{j2}{k2}{end+1} = [l+1,idx_cont];
                                        disp("Bingo 2!");
                                    end
                                end
                            end
                        end
                    end
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

function r = conv_bin(signal,window)
    len_win = length(window);
    if(length(signal)<len_win)
        r = [];
        return;
    end
    r = zeros(length(signal)-len_win+1,1);
    for i = 1:length(r)
        r(i) = signal(i:i+len_win-1)'*window;
    end
end

% function win = win_cand(bnd,M_X)
%     tmp_bnd = M_X.bnd;
%     tmp_bnd(1,:) = [-bnd,bnd]; 
%     u = M_X.gridsize;
%     range = abs(tmp_bnd(:,2)-tmp_bnd(:,1));  % range of each dimension
%     num_node = ceil(range./u-1); % num of discretized points in each dimension
%     num_node(num_node<0)=0;
%     bnd_layer = (range-num_node.*u)/2;
%     
%     % coordinates in each direction
%     win.V{1} = linspace(tmp_bnd(1,1)+bnd_layer(1),tmp_bnd(1,2)-bnd_layer(1),num_node(1)+1);
%     win.V{2} = linspace(tmp_bnd(2,1)+bnd_layer(2),tmp_bnd(2,2)-bnd_layer(2),num_node(2)+1);
%     win.M = ones(length(win.V{1}),length(win.V{2}),'logical');
% end


