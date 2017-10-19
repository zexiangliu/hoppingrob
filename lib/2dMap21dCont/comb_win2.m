function winning_full = comb_win2(SwPt,M_X,Grid,u1,Cont_list)
    num_p = 0;
    for i = 1:length(SwPt)
        num_p = num_p + length(Cont_list{SwPt{i}(2)});
    end
    
    winning_full = zeros(2,num_p);
    counter = 1;
    
    for i = 1:length(SwPt)
        if(~isempty(SwPt{i}))
            origin = Grid.V{1}(SwPt{i}(1))-u1;
%             cont = Cont_list{SwPt{i}(2)};
%             W = cont.sets{end};
            W = Cont_list{SwPt{i}(2)};

            coord_W = M_X.get_coord(W);
            coord_W(1,:) = coord_W(1,:) + origin;
            winning_full(:,counter:counter+length(W)-1) = coord_W;
            counter = counter + length(W);
        end
    end
    winning_full = unique((winning_full'*1e14)/1e14,'rows');
end