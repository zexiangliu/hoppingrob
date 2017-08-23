function subarr = sa2subarray(subcont,array)
    subarr = cell(length(array),1);
    for i = 1:length(array)
        subarr{i} = zeros(length(subcont.set),length(array{1}),'logical');
        idx = subcont.sa_map(:,i)==1;
        subarr{i}(idx,:) = array{i}(subcont.set(idx),:);
%         subarr{i} = sparse(subarr{i});
    end
%     subarr = zeros(length(array),length(subcont.set),length(array{1}),'logical');
%     for i = 1:length(array)
%         idx = subcont.sa_map(:,i)==1;
%         subarr(i,idx,:) = array{i}(subcont.set(idx),:);
% %         subarr{i} = sparse(subarr{i});
%     end
end