function run_example(PATH)
addpath('../lib/')
resetpath
addpath('console/')
if(nargin == 0)
    % Enter manual mode
    manual_mode;
    return;
end
PATH_old = pwd;
cd(PATH);

save PATH PATH_old
%% Generate abstraction and controller
initial

%% Simulation
simulation

%% Animation 
animation

%% teardown
disp('Please any key to quit...');
pause;
load PATH
delete('PATH.mat');
cd(PATH_old);
close all;clear all;clc;
