function M = mass_lt(t,s)
    M = eye(4);
    M(4,4) = s(1)^2;
end