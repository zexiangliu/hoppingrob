%% Generate abstraction and controller
initial

%% Simulation
simulation

%% Animation 
animation

%% Animation based on Simulink
disp('Animation 2:')
u_list = get_coord(M_U,U_list);

save cont t_list u_list % used as input in simulink
len_leg1=h0/2;
len_leg2=sqrt(h0^2+(x1max-x1min+lmax)^2);
C = [1,0];
D=[0];
fre_hopping = pi/2/tau;
% u_list = zeros(ts.n_s,1);
% for i = 1:length(W)
%     tmp=cont.get_input(W(i));
%     u_list(W(i))=get_coord(tmp(1),M_U);
% end
% M_X.V = [];

% save cont u_list M_X
hopping_robot_R2012b

%% teardown
disp('Please any key to quit...');
pause;
close all;clear all;clc;