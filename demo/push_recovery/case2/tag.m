function info = tag()
    info.nametag = 'push_rec_case2';
    info.description = 'Even ground with holes. Do 1D planning given positions and size of the holes in the line where it moves.';
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
