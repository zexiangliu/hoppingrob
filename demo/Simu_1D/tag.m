function info = tag()
    info.nametag = 'Simu_1D';
    info.description = 'Simulation of 1D planning without ground constraints.';
    % Define how to execute the example
    info.run = 'initial;abstraction;simulation;animation';
    % Define how to execute the example in a fast way, by using abstr. and
    % cont saved previously.
    info.fast = 'initial;simulation;animation;';
    if(exist('ts.mat','file')==2)
        info.fast_able = 1;
    else 
        info.fast_able = 0;
    end
end
