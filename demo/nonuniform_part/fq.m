function f = fq(q,u)
    f = ([0 1; 10 0]+[0;-10]*[1 0])*q + [0;-10]*u;
end