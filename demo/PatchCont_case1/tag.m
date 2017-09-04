function info = tag()
    info.nametag = 'patchcont_case1';
    info.description = 'Test PatchCont lib using the code in push_recovery/case1 ';
    % Define how to execute the example
    info.run = 'initial;abstraction;test;test2';
    % Define how to execute the example in a fast way, by using abstr. and
    % cont saved previously.
    info.fast = 'initial;test;test2;';
    if(exist('ts_ref.mat','file')==2)
        info.fast_able = 1;
    else 
        info.fast_able = 0;
    end
end
