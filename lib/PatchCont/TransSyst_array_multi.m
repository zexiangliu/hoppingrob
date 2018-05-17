classdef TransSyst_array_multi < handle

    properties(SetAccess=protected)
        n_s;
        n_a;
        trans_array;
        pg_U;
        pg_G;
    end

    methods
        function ts_arr = TransSyst_array_multi(ts)
            ts_arr.n_s = ts.n_s;
            ts_arr.n_a = ts.n_a;
            ts_arr.trans_array = ts2array(ts);
            ts_arr.pg_G = cell(ts.n_a,1);
%             for i = 1:length(ts.pg_U)
%                 u = ts.pg_U{i};
%                 ts_arr.pg_G{u}=ts.pg_G{i};
%             end
            ts_arr.pg_U = ts.pg_U;
            ts_arr.pg_G = ts.pg_G;
        end
        
        function preV = pre(ts_arr, V, u_list)
            % return controllable pre
            if(isempty(u_list))
                preV = [];
                return;
            end
            preV = zeros(ts_arr.n_s,1);
            for i = 1:length(u_list)
                u = u_list(i);
                sum1 = sum(ts_arr.trans_array{u}(:,V),2);
                sum2 = sum(ts_arr.trans_array{u},2);
                preV(sum1 == sum2 & sum1~=0)=1;
            end
            preV = find(preV==1);
        end
    end

end