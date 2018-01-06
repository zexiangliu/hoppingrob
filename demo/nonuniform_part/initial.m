clear all; close all; clc;
addpath('../../lib/');
resetpath
%%
addpath(genpath('./'));
addpath(genpath('../../lib/abstr-ref_reach/'));
addpath('../../lib/GridGener/');
addpath('../../lib/nonlinear_approx/');
addpath('../../lib/console/');
addpath('../../lib/Parallel/');
%%
% % add the third-parth libs
% PATH = pwd;
% cd('~/PROG/matlab/');
% save PATH PATH
% abstr_refine
% load PATH
% delete([pwd,'/PATH.mat']);
% cd(PATH);

PATH = pwd;
cd('../../../');
save PATH PATH

addpath ./mosek/8/toolbox/
javaaddpath ./mosek/8/tools/platform/linux64x86/bin/mosekmatlab.jar

addpath(genpath('./YALMIP-master'));
clear classes


load PATH
delete([pwd,'/PATH.mat']);
cd(PATH);

