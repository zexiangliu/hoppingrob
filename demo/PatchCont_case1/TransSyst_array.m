classdef TransSyst_array < handle

    properties(SetAccess=protected)
        n_s;
        n_a;
        array;
        pg_G;
    end

    methods
        function ts_arr = TransSyst_array(ts)
            ts_arr.n_s = ts.n_s;
            ts_arr.n_a = ts.n_a;
            ts_arr.array = ts2array(ts);
            ts_arr.pg_G = cell(ts.n_a,1);
            for i = 1:length(ts.pg_U)
                ts_arr.pg_G{ts.pg_U{i}}=ts.pg_G{i};
            end
        end
    end

end