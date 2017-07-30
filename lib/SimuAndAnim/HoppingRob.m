classdef (Abstract) HoppingRob < handle
    properties (Abstract)
        CoM;
        Padel;
        Playground;
    end
    
    methods (Abstract)
        draw_CoM(obj);
        draw_pedal(obj);
        draw_leg(obj);
        draw_Playground(obj);
        visual(obj);
    end
end