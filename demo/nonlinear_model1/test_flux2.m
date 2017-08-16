
load flux_pre.mat
load flux_ts.mat

%% Create B_list
disp('Create target set B_list...')
bnd_B = [x1min,x1max;
          h0-hlim,h0+hlim;
         -1, 1;
         -1, 1];
B_list = Create_B(bnd_B,M_X);
disp('Done.')
%% Controller
disp('Compute winning set and controller...')
ts.create_fast();
% tic
[W, C, cont]=ts.win_eventually_or_persistence([],{B_list'},1);
% toc


save('flux_cont.mat','zero','cont','W','B_list','-v7.3');

disp('Done.')