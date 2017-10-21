function [SwPt_list, Cont_list, Ures_list, Bnd_Grid] = ContGener_compact(Bnd_list,Dist_list,M_X,M_U,cont_ref,ts)
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
    Ures_list = {};
    Cont_list = {};
    
    % used for "refinement"
%     n1 = length(M_X.V{1});
%     n2 = length(M_X.V{2});

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
            idx_winning = search_win(M_X,Cont_list{pos},Win_list{i}{j},origin);
            % label winning states
            Win_list{i}{j}.M(idx_winning(:,1),idx_winning(:,2))=0;
            
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
            idx_winning = search_win(M_X,Cont_list{pos},Win_list{i}{j},origin);
            % label winning states
            Win_list{i}{j}.M(idx_winning(:,1),idx_winning(:,2))=0;
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
                conv_idx = find(tmp_conv==Conv{k});
                for l = conv_idx'
                    old_M = sum(Win_list{j}{k}.M(:));
                    origin = Bnd{j}.V{1}(l+1)-M_U.V{1}(1);
                    idx_winning = search_win(M_X,Cont_list{i},Win_list{j}{k},origin);
                    % label winning states
                    Win_list{j}{k}.M(idx_winning(:,1),idx_winning(:,2))=0;
                    
                    new_M = sum(Win_list{j}{k}.M(:));
                    if(old_M>new_M)
                        SwPt_list{j}{k}{end+1} = [l+1,i];
                        disp("Bingo!");
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
                num_l = Bnd{j}.numV-num_U;%floor((Bnd_list{i}{j}*2-len_X)/M_X.gridsize(1));
                
                if(num_l<=0)
                    break;
                elseif(num_l<=2) % adding controllers here won't change too much
                    continue;
                end
                
                freq = zeros(num_l,1);
                
                origin = Bnd{j}.V{1}(1)-M_U.V{1}(1);
                
                for l = 1:num_l                
                     mask = M_X.bnd(1,:)+origin;
                     freq(l) = conv_win(Win_list{i}{j},mask);
                     origin = origin + M_U.gridsize(1);
                end
                
                % Kick off the first two results, since adding controllers
                % in the very beginning will not change anything.
          
                freq(1:2) = 1;
                
                freq_expected = min(freq); 
                
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
                    SwPt_list{i}{j}{end+1} = [pointer,length(Cont_list)];
                else
                    SwPt_list{i}{j}{end+1} = [pointer,pos];
                end
                
                
                % check the performance
                origin = Bnd{j}.V{1}(pointer)-M_U.V{1}(1);
                mask = M_X.bnd(1,:)+origin;
                freq_true = conv_win(Win_list{i}{j},mask);

                
                if(freq_true>freq_expected)
                    
                    conv_u = zeros(num_U,1);
                    conv_u(u_res)=1;
                    
                    if(~bool)
                        idx_cont = length(Cont_list);
                        for j2 = 1:num_deg
                            Dist = Dist_bin{j2};
                            Bnd  = Bnd_Grid{j2};
                            Conv = Conv_list{j2};
                            for k2 = 1:length(Dist)
                                if(isempty(Dist{k2}))
                                    continue;
                                end
                                bin = Dist{k2};
                                tmp_conv = conv_bin(bin(2:end-1),conv_u);
                                conv_idx = find(tmp_conv==Conv{k2});
                                for l = conv_idx'
                                    old_M = sum(Win_list{j2}{k2}.M(:));
                                    origin = Bnd.V{1}(l+1)-M_U.V{1}(1);
                                    idx_winning = search_win(M_X,Cont_list{end},Win_list{j2}{k2},origin);
                                    % label winning states
                                    Win_list{j2}{k2}.M(idx_winning(:,1),idx_winning(:,2))=0;

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

function win = win_cand(bnd,M_X)
    tmp_bnd = M_X.bnd;
    tmp_bnd(1,:) = [-bnd,bnd]; 
    u = M_X.gridsize;
    range = abs(tmp_bnd(:,2)-tmp_bnd(:,1));  % range of each dimension
    num_node = ceil(range./u-1); % num of discretized points in each dimension
    num_node(num_node<0)=0;
    bnd_layer = (range-num_node.*u)/2;
    
    % coordinates in each direction
    win.V{1} = linspace(tmp_bnd(1,1)+bnd_layer(1),tmp_bnd(1,2)-bnd_layer(1),num_node(1)+1);
    win.V{2} = linspace(tmp_bnd(2,1)+bnd_layer(2),tmp_bnd(2,2)-bnd_layer(2),num_node(2)+1);
    win.M = ones(length(win.V{1}),length(win.V{2}),'logical');
end


function idx_winning = search_win(M_X,win_set,win_cand,origin)
    
    bnd = M_X.bnd+[origin;0];
    idx1 = find(win_cand.V{1}>=bnd(1,1)&win_cand.V{1}<=bnd(1,2));
    idx2 = find(win_cand.V{2}>=bnd(2,1)&win_cand.V{2}<=bnd(2,2));
    
    [IDX,IDY] = meshgrid(idx1,idx2);
    
    win_coord = M_X.get_coord(win_set) + [origin;0];

    idx_winning = zeros(size(win_coord,2),2,'logical');
    counter = 1;
    for i = 1:numel(IDX)
        if(win_cand.M(IDX(i),IDY(i))==0)
            continue;
        end
        dis = sum(abs(win_coord - [win_cand.V{1}(IDX(i));win_cand.V{2}(IDY(i))])<=M_X.gridsize/2);
        if(any(dis==2))
            idx_winning(counter,:) = [IDX(i) IDY(i)];
            counter = counter+1;
        end
    end
    idx_winning(counter:end,:)=[];
end

function freq = conv_win(win_cand,mask)
    idx1 = win_cand.V{1}>=mask(1)&win_cand.V{2}<=mask(2);
    freq = sum(sum(win_cand.M(idx1,:)))/numel(win_cand.M);
end