function A = Aq(q,u)
    A = [0,0,1,0;
         0,0,0,1;
         u(2),0,0,0;
         0,u(2),0,0];
end