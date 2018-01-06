function bool = constr_test(Rq,u)
    persistent lmax lmin
    
    bool = 1;

    lmax = 2; % here lmax represents the max length of the leg.
    lmin = 0.5; % here lmin represents the min length of the leg.
    x_int = [Rq.cv(1)-norm(Rq.gener(1,:),1),Rq.cv(1)+norm(Rq.gener(1,:),1)];
    z_int = [Rq.cv(2)-norm(Rq.gener(2,:),1),Rq.cv(2)+norm(Rq.gener(2,:),1)];
    l1 = norm([x_int(1)-u(1),z_int(2)]);
    l2 = norm([x_int(2)-u(1),z_int(2)]);
    l3 = norm([x_int(1)-u(1),z_int(2)]);
    l4 = norm([x_int(2)-u(1),z_int(2)]);
    
    if(max(l1,l2)>lmax||min(l3,l4)<lmin)
        bool = 0;
    end
    
end