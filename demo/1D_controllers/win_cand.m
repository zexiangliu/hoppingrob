classdef win_cand < handle
   properties
       V;
       M;
   end
    
   methods
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
        function search_win(win_cand,M_X,win_set,origin)

            bnd = M_X.bnd+[origin;0];
            idx1 = find(win_cand.V{1}>=bnd(1,1)&win_cand.V{1}<=bnd(1,2));
            idx2 = find(win_cand.V{2}>=bnd(2,1)&win_cand.V{2}<=bnd(2,2));

            [IDX,IDY] = meshgrid(idx1,idx2);

            win_coord = M_X.get_coord(win_set) + [origin;0];

            ind=sub2ind(size(win_cand.M),IDX(:),IDY(:));
            idx_valid=find(win_cand.M(ind)~=0)';

            for i = idx_valid
        %         if(win_cand.M(IDX(i),IDY(i))==0)
        %             continue;
        %         end
                dis = sum(abs(win_coord - [win_cand.V{1}(IDX(i));win_cand.V{2}(IDY(i))])<=M_X.gridsize/2);
                if(any(dis==2))
                    win_cand.M(IDX(i),IDY(i))=0;
                end
            end
        end
        

        function freq = conv_win(win_cand,mask)
            idx1 = win_cand.V{1}>=mask(1)&win_cand.V{1}<=mask(2);
            idx2 = win_cand.V{2}>=0;
            freq = sum(sum(win_cand.M(idx1,idx2)))/numel(idx1)/numel(idx2);
        end
   end
end