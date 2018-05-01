load ts_exper.mat

cont.cont_trim();
for j = 1%:(length(cont.sets)-1)
    V1=cont.sets{j};
    ts.fast_enabled();
    Q = 1:4000;
    Z1 = union(cont.patch_info{1}{2*j+1},cont.patch_info{1}{2*j+2});

    %%

    DZ = setdiff(Z1,V1);

    %%
    for i = 1:length(DZ)
        cont(uint32(DZ(i)))
    end
end