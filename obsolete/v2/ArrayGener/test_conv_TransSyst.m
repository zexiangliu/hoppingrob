% Represent the array in the form of TransSyst
test;
%%
n_s = length(M_X.ind2sub);
n_a = length(M_U.ind2sub);

ts = TransSyst(n_s+1,n_a);

transist = zeros(1,n_s);
for i=1:n_s
    for j = 1:n_a
        transist = array{j}(i,:);
        idx_ds = find(transist==1); % index of destination state
        for k = 1:length(idx_ds)
            ts.add_transition(i,idx_ds(k),j);
        end
    end
end
%%
ts.create_fast();