clear all;clc;close all;
demo_path = pwd;
cd ../../../lib
resetpath;
cd(demo_path);

addpath(genpath('./'));
addpath('../');
addpath(genpath('../../../lib/abstr-ref/'));
addpath('../../../lib/GridGener/');
addpath('../../../lib/ArrayGener_2D/');
addpath('../../../lib/SimuAndAnim/');
addpath('../../../lib/console/');
addpath('../../../lib/GroundGener/');
addpath('../../../lib/PatchCont/');
