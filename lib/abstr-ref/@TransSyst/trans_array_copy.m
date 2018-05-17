function trans_array_copy(ts,ts_source,subX, subU)
    n_s_old = size(ts_source.trans_array{1},2);
    n_s_new = length(subX) + 1;
    lossX = setdiff(1:n_s_old,subX);
    U2newidx = zeros(length(subU),1);
    X2newidx = zeros(n_s_old,1);
    for i = 1:length(subU)
%         ts.trans_array{i}= false(n_s_new,n_s_new);
        ts.trans_array{i}(1:(n_s_new),1:(n_s_new))=...
            ts_source.trans_array{subU(i)}([subX,n_s_new],[subX,n_s_new]);
        ts.trans_array{i}(1:(end-1),n_s_new) = ...
            sum(ts_source.trans_array{subU(i)}(subX,lossX),2)~=0;    
        ts.trans_array{i}(end,end) = 1;
        U2newidx(subU(i))=i;
    end
    
    for i = 1:length(subX)
        X2newidx(subX(i))=i;
    end
    
    for i = 1:length(ts_source.pg_U)
        pg_U = ts_source.pg_U{i};
        if(isempty(setdiff(pg_U,subU)))
            pg_U = U2newidx(pg_U);
            pg_G = X2newidx(intersect(ts_source.pg_G{i},subX));
            ts.add_progress_group(pg_U,pg_G);
        end
    end
end