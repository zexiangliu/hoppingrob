function [Hc,Hd] = Hessian(q,u,r)
    M1 = zeros(2);
    M2 = [0 0;
         0 6*q(2)];
    I2 = [0 0;
          0 6*r(2)];
    Hc = {M1,M2};
    Hd = {M1,I2};
end