function array = ts2array(ts)
    n_a = double(ts.n_a);
    n_s = double(ts.n_s);
    idx_s2 = ts.state2 ~= n_s;
    array = cell(ts.n_a,1);
    for i = 1:n_a
%         array{i} = zeros(n_s-1,'logical');
        array{i} = sparse(n_s-1,n_s-1);
        idx_a = ts.action==i;
        idx = idx_a&idx_s2;
        % change sub to idx s.t. fast to assign 1's
        idx_m = sub2ind([n_s-1,n_s-1],ts.state1(idx),ts.state2(idx));
        array{i}(idx_m)=true;
    end
end