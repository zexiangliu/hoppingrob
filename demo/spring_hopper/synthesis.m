clear all;close all;clc;
load ts_non_uni.mat
part.ts.trans_array_enable()
[Win, Cwin, cont_non] = part.ts.win_primal([], B, [], 'exists', 'forall', []);

save cont_non.mat
