classdef TransSyst_array < handle

    properties(SetAccess=protected)
        n_s;
        n_a;
        array;
    end

    methods
        function ts_arr = TransSyst_array(ts)
            ts_arr.n_s = ts.n_s;
            ts_arr.n_a = ts.n_a;
            ts_arr.array = ts2array(ts);
        end
    end

end