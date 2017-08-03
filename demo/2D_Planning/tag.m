function info = tag()
    info.nametag = '2D_Planning';
    info.description = 'Generate controller in a 2D plane instead of one line. Use restricted 2D region. The calculation is very slow.';
    info.run = 'initial;test;test_flux;test_flux2;';
    % Define how to execute the example in a fast way, by using abstr. and
    % cont saved previously.
    info.fast = 'initial;test_flux;test_flux2;';
    if(exist('test.mat','file')==2&&exist('rt_ts.mat','file')==2)
        info.fast_able = 1;
    else 
        info.fast_able = 0;
    end
end
