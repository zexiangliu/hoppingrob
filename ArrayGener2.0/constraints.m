function y = constraints(coord,ConsConfig)
    persistent angle_ref bias rotat
    if(isempty(angle_ref))
        angle_ref = ConsConfig.angle;
        bias = ConsConfig.bias;
        rotat = ConsConfig.rotat; % the rotation of the anti-cone region from y=0 CCW
    end
    y = false;
    coord_x = coord(1:2)-bias; % move the vector to origin
    direct = sign(coord_x(1)); % direction of the region
    coord_x = direct*coord_x;
    angle_x = atan2(coord_x(2),coord_x(1))*180/pi-rotat;
    if(abs(angle_x)<=angle_ref)
        y = true;
    end
end