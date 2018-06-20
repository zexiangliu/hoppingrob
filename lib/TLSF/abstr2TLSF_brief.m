function abstr2TLSF_brief(filename, ts, A, B, C_list, IC, compr_rate)
% convert specification and abstraction systems bulit using abstr_ref
% toolbox to the TLSF format used by syfco (https://github.com/reactive-systems/syfco)
% Inputs: filename --- name of output file, i.e filename.tlsf
%         ts --- abstraction
%         A, B, C_list --- specify spec []A && <>[]B && []<>(C_list{1} &&
%                          ... && C_list{n})
%         IC --- initial condition of the state
%         compr_rate --- compress the encoding n/log_cr(n) times
% NOTE: assume that all the actions are avaliable at each state, that is
% the dummy state (out degree is zero) should be used in the abstraction.
if(~ischar(filename))
    error('Error: file name must be in class of char.');
end

fileID = fopen([filename,'.tlsf'],'w');
n_s = double(ts.n_s);
n_a = double(ts.n_a);

log_n_s = ceil(log2(n_s));
log_n_a = ceil(log2(n_a));

% Extract action information
stat2act = false(ts.n_s,ts.n_a);
for i = 1:ts.n_a
    stat2act(:,i) = sum(ts.trans_array{i},2)~=0;
end

% INFO
fprintf(fileID, 'INFO{\n');
fprintf(fileID, ['TITLE: "Abstraction based Controller Synthesis"\n']);
fprintf(fileID,['DESCRIPTION:"none"\n']);
% fprintf(fileID,['DESCRIPTION: "Converted from the format emused in' ...
%     'control synthesis toolbox abstr-ref. Abstraction of continuous' ...
%     'system is encoded in this TLSF file.'...
%     'The spec is in the form of []A && <>[] B && []<> (R1 && R2 && ...'...
%     '&& Rn)"\n']);
fprintf(fileID, 'SEMANTICS:   Mealy,Strict\n');
fprintf(fileID, 'TARGET:   Mealy\n');
fprintf(fileID,'}\n');

% GLOBAL
fprintf(fileID,'GLOBAL  {\n');
fprintf(fileID,'DEFINITIONS {\n');
fprintf(fileID,'enum STATE =\n');
for i = 1:n_s
    fprintf(fileID,'s%s: %s\n',dec2az(i,compr_rate),dec2bin(i-1,log_n_s));
end
fprintf(fileID,'}\n');
fprintf(fileID,'DEFINITIONS {\n');
fprintf(fileID,'enum ACTION =\n');
for i = 1:n_a
    fprintf(fileID,'a%s: %s\n',dec2az(i,compr_rate),dec2bin(i-1,log_n_a));
end
fprintf(fileID,'}\n');
fprintf(fileID,'}\n');

% MAIN
fprintf(fileID,'MAIN{\n');
%   INPUTS
fprintf(fileID,['INPUTS {\n'...
    'STATE S;\n'...
    '}\n']);
%   OUTPUTS
fprintf(fileID,['OUTPUTS {\n'...
    'ACTION A;\n'...
    '}\n']);
%   INITIALLY
fprintf(fileID,'INITIALLY{\n');
%     Inforce winning set (or losing set) to be the initial condition
if(~isempty(IC) && length(IC)~=n_s && isempty(A))
    if(length(IC)<=n_s/2)
        fprintf(fileID,['',OR_STATE(IC,compr_rate),';\n']);
    else
        fprintf(fileID,['!(',OR_STATE(setdiff(1:n_s,IC),compr_rate),');\n']);
    end
elseif(~isempty(IC) && length(IC)~=n_s)
    IC = intersect(IC,A);
    if(length(IC)<=n_s/2)
        fprintf(fileID,['',OR_STATE(IC,compr_rate),';\n']);
    else
        fprintf(fileID,['!(',OR_STATE(setdiff(1:n_s,IC),compr_rate),');\n']);
    end
elseif(~isempty(A) && length(A) ~= n_s)
    if(length(A) <= n_s/2)
        fprintf(fileID,['',OR_STATE(A,compr_rate),';\n']);
    else
        fprintf(fileID,['!(',OR_STATE(setdiff(1:n_s,A),compr_rate),');\n']);
    end
end
fprintf(fileID,'}\n');
%   PRESET
fprintf(fileID,'PRESET {\n');
% for i = 1:n_s
%    fprintf(fileID,'STATE[%d] -> (||[0 <= i <m] ACTION[i]);\n',i);
% end
fprintf(fileID,'}\n');
%   REQUIRE
fprintf(fileID,'REQUIRE {\n');
for i = 1:n_a
    for j = 1:n_s
        s2_list = find(ts.trans_array{i}(j,:));
        if(~isempty(s2_list))
            fprintf(fileID,['(S==s%s&&A==a%s)->X(', ...
                OR_STATE(s2_list,compr_rate), ');\n'], dec2az(j,compr_rate), ...
            dec2az(i,compr_rate));
        end
    end
end
fprintf(fileID,'}\n');

%   ASSUME
fprintf(fileID,'ASSUME {\n');
if(~isempty(ts.pg_U))
    for i = 1:length(ts.pg_U)
        u = ts.pg_U{i};
        G = ts.pg_G{i};
        fprintf(fileID,['G F (!(',OR_STATE(G,compr_rate),...
            ')|| !(',OR_ACTION(u,compr_rate),...
            '));\n']);
    end
end
fprintf(fileID,'}\n');

%   ASSERT
fprintf(fileID,'ASSERT {\n');

state_idx = find(sum(stat2act,2)~=n_a)';
for i = state_idx
    act_list = find(stat2act(i,:)==1);
    if(isempty(act_list))
        continue;
    end
    if(length(act_list)<=n_a/2)
        fprintf(fileID,['S==s%s-> (', OR_ACTION(act_list,compr_rate),...
                        ');\n'],dec2az(i,compr_rate));
    else
        act_list = setdiff(1:n_a,act_list);
        fprintf(fileID,['S==s%s-> !(', OR_ACTION(act_list,compr_rate),...
                        ');\n'],dec2az(i,compr_rate));
    end
end

if(~isempty(A) && length(A) ~= n_s)
    if(length(A) <= n_s/2)
        fprintf(fileID,['',OR_STATE(A,compr_rate),';\n']);
    else
        fprintf(fileID,['!(',OR_STATE(setdiff(1:n_s,A),compr_rate),');\n']);
    end
end
fprintf(fileID,'}\n');

%   GUARANTEE
fprintf(fileID,'GUARANTEE {\n');
if(~isempty(B) && length(B) ~= n_s)
    if(length(B)<=n_s/2)
        fprintf(fileID,['F G (',OR_STATE(B,compr_rate),');\n']);
    else
        fprintf(fileID,['F G !(',OR_STATE(setdiff(1:n_s,B),compr_rate),...
            ');\n']);
    end
end
if(~isempty(C_list))
    for i = 1:length(C_list)
        if(length(C_list{i})<=n_s/2)
            fprintf(fileID,['G F (',OR_STATE(C_list{i},compr_rate),...
                ');\n']);
        else
            fprintf(fileID,['G F !(',OR_STATE(...
                setdiff(1:n_s,C_list{i}),compr_rate),');\n']);
        end
    end
end
fprintf(fileID,'}\n');
fprintf(fileID,'}');
fclose(fileID);
end

function char = OR_STATE(states,compr_rate)
    char = sprintf('S==s%s',dec2az(states(1),compr_rate));
    for i = 2:length(states)
        char =  [char,'||',sprintf('S==s%s',...
            dec2az(states(i),compr_rate))];
    end
end
% 
% function char = OR_X_STATE(states)
%     char = sprintf(' X STATE[%d]',states(1)-1);
%     for i = 2:length(states)
%         char =  [char,' || ',sprintf(' X STATE[%d]',states(i)-1)];
%     end
% end

function char = OR_ACTION(actions,compr_rate)
    char = sprintf('A==a%s',dec2az(actions(1),compr_rate));
    for i = 2:length(actions)
        char =  [char,'||',sprintf('A==a%s',dec2az(actions(i),compr_rate))];
    end
end