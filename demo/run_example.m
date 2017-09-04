function run_example(PATH,info,exec_mode)
% input: PATH      ---- the path of folder of demo
%        exec_mode ---- execution mode -f: fast -p: profile on
%        info      ---- output of tag(), contains the names of main files
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

save PATH PATH_old exec_mode


if(nargin == 1||isempty(info))
    info = tag();
end

if(nargin == 2)
    exec_mode = '';
end


if(ismember('f',exec_mode)&&info.fast_able)
    eval(info.fast);
elseif(ismember('h',exec_mode))
    eval(info.flux);
else
    eval(info.run);
end

%% teardown
load PATH
if(~ismember('h',exec_mode))
    disp('Please any key to quit...');
    pause;
end
delete('PATH.mat');
cd(PATH_old);
close all;clear all;clc;
