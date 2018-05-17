% clc;clear all; close all;
% data1 = load ("../Simu_1D/ts.mat");
% data2 = load ("../Simu_1D/ts.mat");
% B_list = data1.B_list;
% ts1 = data1.ts;
% ts2 = data2.ts;
% ts1.create_fast();
% ts2.trans_array_enable();

% ts_array = TransSyst_array_multi(ts);
num_s = (ts1.n_s-1);
Q = uint32(1:(ts1.n_s-1));

for i = 1:100
    B_list = sort(Q(randperm(num_s,5000)));
    U = randperm(ts1.n_a,20);
    tic
    [pre_B1,cont1] = ts1.pre(B_list,U,1,0);
    t1=toc;
    
    tic
    [pre_B3,cont2] = ts2.pre(B_list,U,1,0);
    t2=toc;
    
    t2/t1
    length(pre_B3)

    union(setdiff(pre_B1,pre_B3),setdiff(pre_B3,pre_B1))

    assert(compare_conts(cont1,cont2))
    
    tic
    [pre_B1,cont1] = ts1.pre(B_list,U,1,1);
    t1=toc;

    tic
    [pre_B3,cont2] = ts2.pre(B_list,U,1,1);
    t2=toc;
    
    t2/t1
    assert(isempty(union(setdiff(pre_B1,pre_B3),setdiff(pre_B3,pre_B1))));
    
     
    tic
    [pre_B1,cont1] = ts1.pre(B_list,U,0,1);
    t1=toc;

    tic
    [pre_B3,cont2] = ts2.pre(B_list,U,0,1);
    t2=toc;
    
    t2/t1
    assert(isempty(union(setdiff(pre_B1,pre_B3),setdiff(pre_B3,pre_B1))));
    
    tic
    [pre_B1,cont1] = ts1.pre(B_list,U,0,0);
    t1=toc;

    tic
    [pre_B3,cont2] = ts2.pre(B_list,U,0,0);
    t2=toc;
    t2/t1
    assert(isempty(union(setdiff(pre_B1,pre_B3),setdiff(pre_B3,pre_B1))));
    
end