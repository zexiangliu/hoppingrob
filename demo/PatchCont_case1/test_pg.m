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
ts.add_progress_group([15,20],uint32(1:3000));
ts.add_progress_group([18,20],uint32(1:3500));

% ts_ref.add_progress_group([1,20],uint32(1:3500));
ts_ref.add_progress_group([15,20],uint32(1:3000));
ts_ref.add_progress_group([18,20],uint32(1:3500));

[~,~,cont] = ts.pre_pg_patch(P,B,1);
[~,~,cont_ref]=ts_ref.pre_pg_patch(P_new,B,1);

%%
cont2 = cont.copy;
PG_new = patch_pre_pg_multi(cont2,ts,u_res,B,Pt);

%%
compare_conts(cont2,cont_ref)