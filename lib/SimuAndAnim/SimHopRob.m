classdef SimHopRob < handle
    properties(SetAccess = protected)
        CoM;                 
        Padel;
        Playground;
        PadelHeight;
        CoMRadius;
    end
    
    methods
        function rob = SimHopRob(CoMRadius,PadelHeight,Playground)
            % input: CoMRadius: radius of CoM
            %        PadelHeight: height/width of padel
            %        Playground: paraments passed into 'patch', a struct which
            %        contains 'vert' and 'fac'
            rob.CoMRadius = CoMRadius;
            rob.PadelHeight = PadelHeight;
            
            [x,y,z] = sphere(20);
            CoM.x = x*CoMRadius;
            CoM.y = y*CoMRadius;
            CoM.z = z*CoMRadius;
            rob.CoM = CoM;
            
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

            Padel.vert=vert*PadelHeight/2;
            Padel.fac = fac;
            rob.Padel = Padel;
            
            rob.Playground = Playground;
        end

        function visual(rob,fig,pCoM, pPadel)
            % input: fig    figure handle
            %        pCoM   Position of CoM
            %        pPadel Position of padel
            
            figure(fig);
            
            % Plot Center of Mass
            surf(rob.CoM.x+pCoM(1),rob.CoM.y+pCoM(2),rob.CoM.z+pCoM(3));
            hold on;
            
            % Plot padel
            padel = rob.Padel.vert;
            padel(:,1)=padel(:,1)+pPadel(1);
            padel(:,2)=padel(:,2)+pPadel(2);
            padel(:,3)=padel(:,3)+pPadel(3)+rob.PadelHeight/2;
            patch('Faces',rob.Padel.fac,'Vertices',padel,'FaceColor','r');  % patch function

            % Plot leg
            l_x = [pCoM(1);pPadel(1)];
            l_y = [pCoM(2);pPadel(2)];
            l_z = [pCoM(3);pPadel(3)+rob.PadelHeight];

            plot3(l_x,l_y,l_z,'linewidth',3)

            rad = linspace(0,2*pi*20,500);
            leg_x = 1/25*sin(rad)+ linspace(l_x(1),l_x(2),500);
            leg_y = 1/25*cos(rad)+ linspace(l_y(1),l_y(2),500);
            leg_z = linspace(l_z(1),l_z(2),500);
            plot3(leg_x,leg_y,leg_z,'linewidth',1)


            % Playground
            if(~isempty(rob.Playground))
                patch('Faces',rob.Playground.fac,'Vertices',rob.Playground.vert,'FaceColor','cyan');  % patch function
            end
        end
    end
end