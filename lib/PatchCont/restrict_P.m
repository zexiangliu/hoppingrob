function P_l = restrict_P(subcont,P_lost)

    for i = 1:length(subcont.subarray)
        SUM = sum(subcont.subarray{i}(:,P_lost),2);
        idx = SUM ~= 0;
        subcont.subarray{i}(idx,:) = 0;
        subcont.sa_map(idx,i) = 0;
        subcont.idx_mod = subcont.idx_mod|idx;
    end
    
    sum_arr = zeros(size(subcont.subarray{1},1),1,'logical');
    for i = 1:length(subcont.subarray)
        sum_arr = sum_arr | sum(subcont.subarray{i},2);
    end
    SUM = sum_arr;%sum(sum_arr,2);
    idx = (SUM == 0)&(~subcont.idx_lost);
    subcont.idx_lost = subcont.idx_lost|idx;
    P_l = subcont.set(idx);
end