function f = fq(q,u)
% use model 1 in the candidate
% q = [x,z,dx,dz]
% u = [x_u,u]
    f = [q(2)
        5*u*q(2)+q(2)^3];
end