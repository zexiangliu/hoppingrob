function manual_mode()
% Welcome to manual mode of run_example
% The commands available:
%     q/quit         ---- quit
%     h/help         ---- show the help document
%     l/list         ---- list all the demos
%     demotag + option -- execute the demo, option: -f fast -p profile on
%     doc + demotag  ---- show the description of the demo
%     cmd            ---- command window (return manual mode by typing 'dbcont')
%     clc            ---- clear screen
% Note: (1) tag.m in each demo's directory is necessary for manual_mode
% discovering the demos.
%  (2) If you want to skip the process of calculation, you can use previous
%  result by using fast mode, e.g. 'demo -f'
%  (3) You can set profiler for abstraction part by using p mode, e.g.
%  'demo -p'
    disp('Initialize environment...');
    [cmd_dict,demo,doc] = initial();
    disp(' ');
    disp('Please type ''h'' for help information.')
    disp(' ');
    
    while(1)
        cmd = input('manual$ ','s');
        if(strcmp(cmd,'q')||strcmp(cmd,'quit'))
            disp(' ');
            disp('Quit manual mode...');
            disp(' ');
            break;
        end
        keywords = split(lower(cmd));
        key = keywords{1};
        if(length(keywords)>1)
            value = keywords{2};
        else
            value = '';
        end
        
        if(cmd_dict.isKey(key))
            eval(cmd_dict(key));
        elseif(demo.isKey(key))
            KeyCallback('reset');
            try
                run_example(demo(key),value);
            catch EM
                rethrow(EM);
            end

        end
    end
end


function [cmd_dict,demo,doc] = initial()
    cmd_dict = containers.Map;
    cmd_dict('h')='help manual_mode;';
    cmd_dict('help')='help manual_mode;';
    cmd_dict('l') = 'list(doc,value)';
    cmd_dict('list') = 'list(doc,value)';
    cmd_dict('doc') = 'if(doc.isKey(value)) disp(doc(value)); end';
    cmd_dict('exec') = 'if(demo.isKey(value)) run_example(demo(value)); end';
    cmd_dict('cmd') = 'keyboard();';
    cmd_dict('clc') = 'clc';
    % search examples
    demo = containers.Map;
    doc = containers.Map;
    tags = dir('**/tag.m');
    PATH = pwd;
    for i = 1:length(tags)
        cd(tags(i).folder);
        info = tag();
        demo(lower(info.nametag)) = tags(i).folder;
        doc(lower(info.nametag)) = info.description;
    end
    cd(PATH);
    
    % Preparation for key callback
    SetKeyCallback();
end

function list(doc,type)
    disp(' ');
    disp('The list of demonstrations:');
    disp(' ');
    nametags = doc.keys;
    descriptions = doc.values;

    for i = 1:doc.Count
        if(strcmp(type,'-a'))
            disp(['  ',nametags{i},': ',descriptions{i}]);
        else
            disp(['  ',nametags{i}]);
        end
    end

    disp(' ');
end
