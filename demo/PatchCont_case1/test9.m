clc;clear all;
load test9
i=2
Z2_new = patch_pre_pg_multi(K_Compl{2*i},ts,u_res,A,V_lost)
load test9
tmp = patch_pre_pg_lg(K_Compl{2*i},ts,u_res,A,V_lost)