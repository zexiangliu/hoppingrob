function freq = comb_win3(SwPt,M_X,Cont_list,Bnd,Dist,Bnd_Dist,u1)    
    bnd_X = M_X.bnd(1,:);
    len_X = bnd_X(2)-bnd_X(1);
    
    winning_full = [];
    
    for i = 1:length(SwPt)
        
        origin = Bnd_Dist.V{1}(SwPt{i}(1))-u1;
        W = Cont_list{SwPt{i}(2)};
        coord_W = M_X.get_coord(W);
        coord_W(1,:) = coord_W(1,:) + origin;
        winning_full = [winning_full,coord_W];
        
    end
    
    winning_full = unique(winning_full','rows')';
    
    [X,Y]=meshgrid(Bnd_Dist.V{1},M_X.V{2});
    counter = 0;
    for i = 1:length(X(:))
        
        if(min((winning_full(1,:)-X(i)).^2+(winning_full(2,:)-Y(i)).^2)<M_X.gridsize(1)^2/4)
            counter = counter+1;
        end
        
    end
    freq = counter/length(X(:));
end