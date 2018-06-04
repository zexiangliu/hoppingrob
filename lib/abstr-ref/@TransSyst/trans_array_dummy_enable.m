function trans_array_dummy_enable(ts)
% enable the dummy state (the last state by default)
    for i = 1:ts.n_a
        % idx of states without transition under action i
        idx = sum(ts.trans_array{i},2)==0;
        ts.trans_array{i}(idx,ts.n_s) = 1;
    end
end