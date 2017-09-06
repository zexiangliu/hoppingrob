function info = tag()
    info.nametag = '1D_controllers';
    info.description = 'Generate a series of controllers to handle the holes.';
    % Define how to execute the example
    info.run = 'initial;';
    % Define how to execute the example in a fast way, by using abstr. and
    % cont saved previously.
    info.fast = 'initial;';
    if(exist('ts.mat','file')==2)
        info.fast_able = 1;
    else 
        info.fast_able = 0;
    end
end
