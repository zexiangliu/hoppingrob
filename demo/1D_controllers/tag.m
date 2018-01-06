function info = tag()
    info.nametag = '1D_controllers';
    info.description = 'Generate a series of controllers to handle the holes.';
    % Define how to execute the example
    info.run = 'initial;';
    % Define how to execute the example in a fast way, by using abstr. and
    % cont saved previously.
    info.flux = 'initial;flux_test';
    info.fast = 'initial;test4;test3';
    info.fast_able = 1;
end
