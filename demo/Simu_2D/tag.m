function info = tag()
    info.nametag = 'Simu_2D';
    info.description = 'Simulation of 2D case where the planning is decomposed into two dimension.';
    info.run = 'initial;test;test_control;animation';
    % Define how to execute the example in a fast way, by using abstr. and
    % cont saved previously.
    info.fast = 'initial;test_control;animation;';
    if(exist('ts.mat','file')==2)
        info.fast_able = 1;
    else 
        info.fast_able = 0;
    end
end
