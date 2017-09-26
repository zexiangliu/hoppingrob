function winning_full = visual_comb_win(fig,SwPt,M_X,Cont_list,Bnd,Dist)
    figure(fig);
    
    bnd_X = M_X.bnd(1,:);
    len_X = bnd_X(2)-bnd_X(1);
    
    winning_full = [];
    
    for i = 1:length(SwPt)
        
        origin = SwPt{i}(1)+len_X/2;
        cont = Cont_list{SwPt{i}(2)};
        W = cont.sets{end};
        coord_W = M_X.get_coord(W);
        coord_W(1,:) = coord_W(1,:) + origin;
        winning_full = [winning_full,coord_W];
        
    end
    
    plot(winning_full(1,:),winning_full(2,:),'.c','markersize',1);
    hold on;
    plot([-Bnd,Bnd],[0,0],'-b','linewidth',2);
    for i = 1:size(Dist,1)
        plot(Dist(i,:),[0;0],'-r','linewidth',4);
    end
    axis equal;
    winning_full = winning_full';
end