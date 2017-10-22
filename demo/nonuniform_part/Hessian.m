function [Hc,Hd] = Hessian(q,u,r)
    M0 = zeros(2);
    D0 = zeros(2);
    Hc = {M0,M0};
    Hd = {D0,D0};
end