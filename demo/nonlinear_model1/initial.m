clear all;clc;close all;
addpath(genpath('./'));
addpath(genpath('../../lib/abstr-ref/'));
addpath('../../lib/GridGener/');
addpath('../../lib/nonlinear_approx/');
addpath('../../lib/console/');

delete(gcp('nocreate'));
if(~exist('thePool','var'))
    NP = 4;
    thePool = parpool('local',4);
end
