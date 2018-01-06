function info = tag()
    info.nametag = 'nonuniformpart';
    info.description = 'Use nonuniform partitions.';
    % Define how to execute the example
    info.run = 'initial;hop_rob';
    % Define how to execute the example in a fast way, by using abstr. and
    % cont saved previously.
    info.flux = 'initial;hop_rob';
    info.fast = 'initial;hop_rob';
    info.fast_able = 1;
end
