clear all; close all; clc;
addpath('../../lib/');
resetpath
%%
addpath(genpath('./'));
addpath(genpath('../../lib/abstr-ref/'));
addpath('../../lib/GridGener/');
addpath('../../lib/nonlinear_approx/');
addpath('../../lib/console/');
addpath('../../lib/Parallel/');
%%
% add the third-parth libs
PATH = pwd;
cd('~/PROG/matlab/');
save PATH PATH
abstr_refine
load PATH
delete([pwd,'/PATH.mat']);
cd(PATH);
