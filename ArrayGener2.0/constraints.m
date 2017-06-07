function y = constraints(coord,ConsConfig)
    persistent angle_ref bias rotat
    if(isempty(angle_ref))
        angle_ref = ConsConfig.angle;
        bias = ConsConfig.bias;
        rotat = ConsConfig.rotat; % the rotation of the anti-cone region from y=0 CCW
    end
    y = false;
    coord_x = coord(1:2)-bias; % move the vector to origin
    if(coord_x(1)~=0)
        direct = sign(coord_x(1)); % direction of the region
    else
        direct = sign(coord_x(2));
    end
    coord_x = direct*coord_x;
    angle_x1 = atan2(coord_x(2),coord_x(1))*180/pi-rotat;
    coord_x2 = coord_x;
    coord_x2(2) = coord_x2(2)-sign(coord_x(2))*0.6;
    angle_x2 = atan2(coord_x2(2),coord_x2(1))*180/pi-rotat;
    if(abs(angle_x1)<=angle_ref||abs(angle_x2)<=angle_ref||norm(coord_x(2))<=0.6)
        y = true;
    end
end