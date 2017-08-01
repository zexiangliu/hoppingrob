function run_example(PATH)
% input: PATH      ---- the path of folder of demo
%        exec_mode ---- execution mode -f: fast -p: profile on
% Note: The process of generating abstraction and controller is slow.
% Alternatively, you can see the simulation and animation using previous
% abstraction and controller by setting -f in the exec_mode.
addpath('../lib/')
resetpath
addpath('../lib/console/')
if(nargin == 0)
    % Enter manual mode
    manual_mode;
    return;
end
PATH_old = pwd;
cd(PATH);

save PATH PATH_old

if(nargin == 1)
    exec_mode = '';
end

if(~ismember('f',exec_mode))
    %% Initialize
    initial

    %% Generate abstraction and controller
    abstraction
else
    initial
end

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
