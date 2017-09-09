function winning_full = comb_win(SwPt,M_X,Cont_list)
    
    bnd_X = M_X.bnd(1,:);
    len_X = bnd_X(2)-bnd_X(1);
    
    winning_full = [];
    
    for i = 1:length(SwPt)
        if(~isempty(SwPt{i}))
            origin = SwPt{i}(1)+len_X/2;
            cont = Cont_list{SwPt{i}(2)};
            W = cont.sets{end};
            coord_W = M_X.get_coord(W);
            coord_W(1,:) = coord_W(1,:) + origin;
            winning_full = [winning_full,coord_W];
        end
    end
    winning_full = winning_full';
end