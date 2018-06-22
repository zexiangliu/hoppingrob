% initial condition
m = 1;
g = 10;
l0 = 0.5;
k = 7000;

param.rest_len = l0;
param.gravity = g;
param.mass = m;
param.k = k;

dt_max = 10;
M_U = [97,98,99,100];%(90-dt_max):(90+dt_max);

% dx0 = -4.15;%-4.1110;
y0 = 0.8727;

K = -1/2*m*3.5648^2; %-6.4559
K_idx = mapping_ext(K,M_X,0);
% K = M_X.get_coord(K_idx);

M_X.get_coord(find(ts.trans_array{u_list(1)}(K_idx,:)))

%%

dx0 = sign(K)*sqrt(2*abs(K)/m);

K_min = K-0.1;
K_max = K+0.1;

dx_min = sign(K_min)*sqrt(2*abs(K_min)/m);
dx_max = sign(K_max)*sqrt(2*abs(K_max)/m);

dx_list = linspace(dx_min,dx_max,10);

E = abs(K) + m*g*y0;
dE = 2;



% fix E, test the monotonicity w.r.t. dx
E0_1 = zeros(length(dx_list),1); E0_2 = E0_1; E0_3 = E0_1;
E1_1 = E0_1; E1_2 = E0_1; E1_3 = E0_1;
K0_1 = E0_1; K0_2 = E0_1; K0_3 = E0_1;
K1_1 = E0_1; K1_2 = E0_1; K1_3 = E0_1;
P0_1 = E0_1; P0_2 = E0_1; P0_3 = E0_1;
P1_1 = E0_1; P1_2 = E0_1; P1_3 = E0_1;
cnt = 1;
for j = 1%:length(M_U)
    figure(cnt);
    K1_1 = zeros(length(dx_list),1);
    for i =1:length(dx_list)
        %% type 1
        dx0 = dx_list(i);
        y0 = (E-1/2*m*dx0^2)/m/g;
        init = [y0;dx0];
        u = M_U(j)*pi/180;
        try
            [t_list,X,Y,dx1] = simuOneJump_lt(param, init, u);

            E0_1(i) = m*g*y0 + 1/2*m*dx0^2;
            E1_1(i) = m*g*Y(end) + 1/2*m*dx1^2;

            K0_1(i) = 1/2*m*dx0^2;
            K1_1(i) = sign(dx1)*1/2*m*dx1^2;

            P0_1(i) = m*g*y0;
            P1_1(i) = m*g*Y(end);
            
            figure(cnt);
            hold on;
            plot(K1_1);
%             plot(E1_1);
%             plot(1/2*m*dx_list.^2)
        catch ME1
            warning(ME1.message);
        end
        pause();
    end
%     idx = K1_1 <= K1_2+0.01 & K1_2 <= K1_3+0.01 | K1_3 <= K1_2+0.01 & K1_2 <= K1_1+0.01;
%     idx = idx(K1_1~=0 & K1_2 ~= 0 & K1_3 ~= 0);
%     assert(all(idx));
    cnt = cnt + 1;
end


% %% fix dx, test the monotonicity w.r.t. E+-dE
% E0_1 = zeros(length(dx_list),1); E0_2 = E0_1; E0_3 = E0_1;
% E1_1 = E0_1; E1_2 = E0_1; E1_3 = E0_1;
% K0_1 = E0_1; K0_2 = E0_1; K0_3 = E0_1;
% K1_1 = E0_1; K1_2 = E0_1; K1_3 = E0_1;
% P0_1 = E0_1; P0_2 = E0_1; P0_3 = E0_1;
% P1_1 = E0_1; P1_2 = E0_1; P1_3 = E0_1;
% cnt = 1;
% for j = 1:length(M_U)
% %     figure(cnt);
%     for i =1:length(dx_list)
%         %% type 1
%         dx0 = dx_list(i);
%         y0 = (E-1/2*m*dx0^2)/m/g;
%         init = [y0;dx0];
%         u = M_U(j)*pi/180;
%         try
%             [t_list,X,Y,dx1] = simuOneJump_xy(param, init, u);
% 
%             E0_1(i) = m*g*y0 + 1/2*m*dx0^2;
%             E1_1(i) = m*g*Y(end) + 1/2*m*dx1^2;
% 
%             K0_1(i) = 1/2*m*dx0^2;
%             K1_1(i) = dx1;
% 
%             P0_1(i) = m*g*y0;
%             P1_1(i) = m*g*Y(end);
%         catch ME1
%             warning(ME1.message);
%         end
%         %% type 2
%         y0 = (E-1/2*m*dx0^2+dE)/m/g;
%         init = [y0;dx0];
%         u = M_U(j)*pi/180;
%         try
%             [t_list,X,Y,dx1] = simuOneJump_xy(param, init, u);
%             
%             E0_2(i) = m*g*y0 + 1/2*m*dx0^2;
%             E1_2(i) = m*g*Y(end) + 1/2*m*dx1^2;
% 
%             K0_2(i) = 1/2*m*dx0^2;
%             K1_2(i) = dx1;
% 
%             P0_2(i) = m*g*y0;
%             P1_2(i) = m*g*Y(end);
%         catch ME1
%             warning(ME1.message);
%         end
% 
%          %% type 3
%         y0 = (E-1/2*m*dx0^2-dE)/m/g;
%         init = [y0;dx0];
%         u = M_U(j)*pi/180;
%         try
%             [t_list,X,Y,dx1] = simuOneJump_xy(param, init, u);
%             E0_3(i) = m*g*y0 + 1/2*m*dx0^2;
%             E1_3(i) = m*g*Y(end) + 1/2*m*dx1^2;
% 
%             K0_3(i) = 1/2*m*dx0^2;
%             K1_3(i) = dx1;
% 
%             P0_3(i) = m*g*y0;
%             P1_3(i) = m*g*Y(end);
%         catch ME1
%             warning(ME1.message);
%         end
%         
%     end
%     idx = K1_3 <= K1_1+0.01 & K1_1 <= K1_2+0.01 | K1_2 <= K1_1+0.01 & K1_1 <= K1_3+0.01;
%     idx = idx(K1_1~=0 & K1_2 ~= 0 & K1_3 ~= 0);
%     assert(all(idx));
% %     figure(1);
% %     hold on;
% %     plot(K1_1);
% %     plot(K1_2);
% %     plot(K1_3);
% %     plot(E1_1);
% %     plot(E1_2);
% %     plot(E1_3);
% %     plot(1/2*m*dx_list.^2)
% %     cnt = cnt + 1;
% end