function info = tag()
    info.nametag = 'nonlinear1';
    info.description = 'Test nonlinear approximation method with model 1 in candidates.';
    info.run = 'initial;abstraction;';
    % Define how to execute the example in a fast way, by using abstr. and
    % cont saved previously.
    info.fast = 'initial;abstraction;';
    info.flux = 'initial;test_flux;test_flux2;';
    if(exist('test.mat','file')==2&&exist('rt_ts.mat','file')==2)
        info.fast_able = 1;
    else 
        info.fast_able = 0;
    end
end
