function info = tag()
    info.nametag = 'push_rec_case3';
    info.description = 'Uneven ground without holes. DO 1D planning given maximum height difference hlim.';
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
