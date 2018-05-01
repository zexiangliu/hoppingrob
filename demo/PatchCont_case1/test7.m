for i = 1:10
    [~,~,cont] = ts.pre_pg_patch(P,B,1);        
    P_new = P(sort(randperm(length(P),length(P_new))));
    tic
    [~,~,cont_ref]=ts_ref.pre_pg_patch(P_new,B,1);
    toc
    %%
    cont2 = cont.copy;
    tic
    PG_new = patch_pre_pg_multi(cont2,ts,u_res,B,setdiff(P,P_new));
    toc
    %%
    compare_conts(cont2,cont_ref)
end