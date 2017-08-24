function P_l = restrict_u(subcont)
%     for i = u_res
%         subarray{i} = 0*subarray{i};
%     end
    sum_arr = zeros(size(subcont.subarray{1},1),1,'logical');
    for i = 1:length(subcont.subarray)
        sum_arr = sum_arr | sum(subcont.subarray{i},2);
    end
    SUM = sum_arr;
    idx = SUM == 0;
    subcont.idx_lost = subcont.idx_lost|idx;
    P_l = subcont.set(idx);
end