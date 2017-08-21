function f = fq(q,u)
% use model 1 in the candidate
% q = [x,z,dx,dz]
% u = [x_u,u]
    f = [q(3);
        q(4);
        (q(1)-u(1))*u(2);
        q(2)*u(2)-10];
end