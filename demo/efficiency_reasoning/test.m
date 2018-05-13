load ("../Simu_1D/ts.mat")

ts_array = TransSyst_array_multi(ts);

tic
pre_B1 = ts.pre(B_list,[],1,0);
toc

tic
pre_B2 = ts_array.pre(B_list,1:35);
toc