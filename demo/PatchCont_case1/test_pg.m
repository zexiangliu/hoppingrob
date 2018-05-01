load ts_pg_exper
% 
% cont_ref = load('ts_pg_cons');
% cont_ref = cont_ref.cont_tmp;

ts = load('ts_exper_until');
ts = ts.ts;

ts_ref = load('ts_cons_until');
ts_ref = ts_ref.ts;

%%

ts.add_progress_group([1,20],uint32(1:3500));

ts.add_progress_group([4,5,6,7,20],uint32(1:3500));
ts.add_progress_group([15,20],uint32(1:3000));
ts.add_progress_group([18,20],uint32(1:3500));

% ts_ref.add_progress_group([1,20],uint32(1:3500));
ts_ref.add_progress_group([15,20],uint32(1:3000));
ts_ref.add_progress_group([18,20],uint32(1:3500));


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