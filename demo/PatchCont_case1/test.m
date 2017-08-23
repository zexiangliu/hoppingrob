load ts.mat

ts = TransSyst_array(ts);
sets_old = cont.sets;
% list of actions which need to be removed
u_res = [1;3;4;5];
P = []; % input P of function win_eventually_or_persistence
% P_l = patch_until_or_always(cont.subcontrollers{3}.subcontrollers{1},ts,u_res,[]);

% P_l = patch_pre(cont.subcontrollers{4},ts,u_res,cont.subcontrollers{3}.sets{1});

% [U_n,U_o] = patch_pre_pg(cont.subcontrollers{5},ts,u_res,cont.subcontrollers{5}.sets{1}(1:100));

num_loop = length(cont.sets)/3;
set_all = cell(num_loop,1);

P_l = patch_until_or_always(cont.subcontrollers{3}.subcontrollers{1},ts,u_res,[]);
cont.subcontrollers{3}.set_sets({cont.subcontrollers{3}.subcontrollers{1}.sets});
set_all{3} = cont.subcontrollers{3}.subcontrollers{1}.sets';

P_lost = P_l;
for i = 2:num_loop
    P_l = patch_pre(cont.subcontrollers{i*3-2},ts,u_res,P_lost);
    set_all{i*3-2} = union(P,cont.subcontrollers{i*3-2}.sets);
    [U_n,U_o] = patch_pre_pg(cont.subcontrollers{i*3-1},ts,u_res,P_lost);
    set_all{i*3-1} = union(set_all{i*3-2},U_n);
    P_lost = setdiff(union(sets_old{i*3-2},sets_old{i*3-1}),set_all{i*3-1});
    P_lost = patch_until_or_always(cont.subcontrollers{i*3}.subcontrollers{1},ts,u_res,P_lost);
    set_all{i*3} = union(set_all{i*3-1},cont.subcontrollers{i*3}.subcontrollers{1}.sets);
    cont.subcontrollers{i*3}.set_sets({set_all{i*3}});
end


cont.set_sets(set_all);
