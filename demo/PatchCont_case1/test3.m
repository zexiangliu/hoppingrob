clc; clear all; close all;
load spec
ts_arr =ts;
exper = load('ts_exper','ts');
ts = exper.ts;
cons = load('ts_cons','ts');
ts_ref = cons.ts;

% cont = cont_tmp.copy;
PG_new = patch_pre_pg_md2(cont_tmp,ts_arr,u_res,Pt,B)';
[PG_ref,~,cont_ref] = ts_ref.pre_pg(P_new,B,true);