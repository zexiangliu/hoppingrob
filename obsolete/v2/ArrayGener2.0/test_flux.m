%% 6 Test ArrayGener_ts 
% store the transist system in class 'TransSyst'
% add progress group in ArrayGener_ts.m
clc;clear all;close all;
addpath('../GroundGener/');
addpath(genpath('../abstr-ref/'));

if(~exist('thePool','var'))
    NP = 4;
    thePool = parpool('local',4);
end
load test.mat
tic
ts = ArrayGener(M_X,M_U,tau,lmax,UConsConfig,system);
toc
delete(thePool);
disp('Abstraction Done.');
zero = 0;
save('rt_ts.mat','zero','ts','-v7.3')
% %% 7 find target set B_list
% bnd_B = [M_X.bnd(1:2,:);
%          -2,  2;
%          -2,  2];
% B_list = Create_B(bnd_B,M_X);
% % visual(M_X,bnd_B,B_list,coord_bias,UConsConfig.ROT,'X')
% disp('Target set Done.');
% 
% %% 8 winning set
% ts.create_fast();
% [W, C, cont]=ts.win_eventually_or_persistence([],{B_list'},1);
% size(W)
% % visual(M_X,bnd_B,W,coord_bias,UConsConfig.ROT,'W')
% disp('Winning set Done.')
% save('rt_cont.mat','zero','W','cont','-v7.3');