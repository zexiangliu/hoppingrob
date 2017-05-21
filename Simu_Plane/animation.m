% CoM
[x,y,z]  = sphere(20);

CoM.x=x/15;
CoM.y=y/15;
CoM.z=z/15;

% Padel
vert = [1 1 -1; 
        -1 1 -1; 
        -1 1 1; 
        1 1 1; 
        -1 -1 1;
        1 -1 1; 
        1 -1 -1;
        -1 -1 -1];

fac = [1 2 3 4; 
       4 3 5 6; 
       6 7 8 5; 
       1 2 8 7; 
       6 7 1 4; 
       2 3 5 8];

Padel.vert=vert/20;
Padel.fac = fac;

% Playground

Playground.vert = [U.bnd(1,1),U.bnd(2,1),0;
                   U.bnd(1,1),U.bnd(2,2),0;
                   U.bnd(1,2),U.bnd(2,2),0;
                   U.bnd(1,2),U.bnd(2,1),0;
                   ];

Playground.fac = [1 2 3 4];

% B_list

Target.vert = [bnd_B(1,1),bnd_B(2,1),h0
    bnd_B(1,1),bnd_B(2,2),h0
    bnd_B(1,2),bnd_B(2,2),h0
    bnd_B(1,2),bnd_B(2,1),h0
    ];
Target.fac = [1,2,3,4];

figure(3);
% axis([x1min-lmax, x1max+lmax, -0.5, 0.5, -0.5, 1.5]); 
% axis equal;
t = 0;
% hold on;


for i = 1:length(Yt_list)
    pause(Yt_list(i)-t);
    t= Yt_list(i);
    hold off;
    % Plot Center of Mass
    surf(CoM.x+Yx_list(1,i),CoM.y+Yx_list(2,i),CoM.z+h0);
    hold on;
    plot3(Yx_list(1,1:i),Yx_list(2,1:i),h0*ones(1,i),'-.','linewidth',1.5);
    % Plot padel
    padel = Padel.vert;
    padel(:,1)=padel(:,1)+Yx_list(5,i);
    padel(:,2)=padel(:,2)+Yx_list(6,i);
    hopping_height = h0/4*abs(sin((3*pi/2/tau)*t));
    padel(:,3)=padel(:,3)+1/20+hopping_height;
    patch('Faces',Padel.fac,'Vertices',padel,'FaceColor','r');  % patch function
    
    % Plot leg
    l_x = [Yx_list(1,i);Yx_list(5,i)];
    l_y = [Yx_list(2,i);Yx_list(6,i)];
    l_z = [h0;2/20+hopping_height];
    
    plot3(l_x,l_y,l_z,'linewidth',3)
    
    rad = linspace(0,2*pi*20,500);
    leg_x = 1/25*sin(rad)+ linspace(l_x(1),l_x(2),500);
    leg_y = 1/25*cos(rad)+ linspace(l_y(1),l_y(2),500);
    leg_z = linspace(l_z(1),l_z(2),500);
    plot3(leg_x,leg_y,leg_z,'linewidth',1)
    
    
    % Playground
    patch('Faces',Playground.fac,'Vertices',Playground.vert,'FaceColor','none');  % patch function
    
    % B_list
    patch('Faces',Target.fac,'Vertices',Target.vert,'FaceColor','none','EdgeColor','red');  % patch function

    % camera configuration
%     axis([x1min-lmax, x1max+lmax, -0.5, 0.5, -0.5, 1.5]); 
    axis equal;
    az = 25;
    el = 15;
    view(az, el);
    drawnow;
end
