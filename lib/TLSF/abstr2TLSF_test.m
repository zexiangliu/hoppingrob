function abstr2TLSF_test(filename, ts, A, B, C_list, IC)
% convert specification and abstraction systems bulit using abstr_ref
% toolbox to the TLSF format used by syfco (https://github.com/reactive-systems/syfco)
% Inputs: filename --- name of output file, i.e filename.tlsf
%         ts --- abstraction
%         A, B, C_list --- specify spec []A && <>[]B && []<>(C_list{1} &&
%                          ... && C_list{n})
%         IC --- initial condition of the state
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
fprintf(fileID, ['\tTITLE: "Abstraction based Controller Synthesis"\n']);
fprintf(fileID,['\tDESCRIPTION:"none"\n']);
% fprintf(fileID,['\tDESCRIPTION: "Converted from the format emused in' ...
%     'control synthesis toolbox abstr-ref. Abstraction of continuous' ...
%     'system is encoded in this TLSF file.'...
%     'The spec is in the form of []A && <>[] B && []<> (R1 && R2 && ...'...
%     '&& Rn)"\n']);
fprintf(fileID, '\tSEMANTICS:   Mealy,Strict\n');
fprintf(fileID, '\tTARGET:   Mealy\n');
fprintf(fileID,'}\n');

% GLOBAL
fprintf(fileID,'GLOBAL  {\n');
fprintf(fileID,'\tDEFINITIONS {\n');
fprintf(fileID,'\tenum STATE =\n');
for i = 1:n_s
    fprintf(fileID,'\t\ts%d: %s\n',i,dec2bin(i-1,log_n_s));
end
fprintf(fileID,'\t}\n');
fprintf(fileID,'\tDEFINITIONS {\n');
fprintf(fileID,'\tenum ACTION =\n');
for i = 1:n_a
    fprintf(fileID,'\t\ta%d: %s\n',i,dec2bin(i-1,log_n_a));
end
fprintf(fileID,'\t}\n');
fprintf(fileID,'}\n');

% MAIN
fprintf(fileID,'MAIN{\n');
%   INPUTS
fprintf(fileID,['\tINPUTS {\n'...
    '\tSTATE S;\n'...
    '\t}\n']);
%   OUTPUTS
fprintf(fileID,['\tOUTPUTS {\n'...
    '\tACTION A;\n'...
    '\t}\n']);
%   INITIALLY
fprintf(fileID,'\tINITIALLY{\n');
%     Inforce winning set (or losing set) to be the initial condition
if(~isempty(IC) && length(IC)~=n_s && isempty(A))
    if(length(IC)<=n_s/2)
        fprintf(fileID,['\t',OR_STATE(IC),';\n']);
    else
        fprintf(fileID,['\t!(',OR_STATE(setdiff(1:n_s,IC)),');\n']);
    end
elseif(~isempty(IC) && length(IC)~=n_s)
    IC = intersect(IC,A);
    if(length(IC)<=n_s/2)
        fprintf(fileID,['\t',OR_STATE(IC),';\n']);
    else
        fprintf(fileID,['\t!(',OR_STATE(setdiff(1:n_s,IC)),');\n']);
    end
elseif(~isempty(A) && length(A) ~= n_s)
    if(length(A) <= n_s/2)
        fprintf(fileID,['\t',OR_STATE(A),';\n']);
    else
        fprintf(fileID,['\t!(',OR_STATE(setdiff(1:n_s,A)),');\n']);
    end
end
fprintf(fileID,'\t}\n');
%   PRESET
fprintf(fileID,'\tPRESET {\n');
% for i = 1:n_s
%    fprintf(fileID,'\tSTATE[%d] -> (||[0 <= i <m] ACTION[i]);\n',i);
% end
fprintf(fileID,'\t}\n');
%   REQUIRE
fprintf(fileID,'\tREQUIRE {\n');
for i = 1:n_a
    for j = 1:n_s
        s2_list = find(ts.trans_array{i}(j,:));
        if(~isempty(s2_list))
            fprintf(fileID,['\t(S == s%d && A == a%d) -> X (', ...
                OR_STATE(s2_list), ' );\n'], j, i);
        end
    end
end
fprintf(fileID,'\t}\n');

%   ASSUME
fprintf(fileID,'\tASSUME {\n');
if(~isempty(ts.pg_U))
    for i = 1:length(ts.pg_U)
        u = ts.pg_U{i};
        G = ts.pg_G{i};
        fprintf(fileID,['\tG F ( !(',OR_STATE(G),') || !(',OR_ACTION(u),...
            '));\n']);
    end
end
fprintf(fileID,'\t}\n');

%   ASSERT
fprintf(fileID,'\tASSERT {\n');

state_idx = find(sum(stat2act,2)~=n_a)';
for i = state_idx
    act_list = find(stat2act(i,:)==1);
    if(isempty(act_list))
        continue;
    end
    if(length(act_list)<=n_a/2)
        fprintf(fileID,['\tS == s%d -> (', OR_ACTION(act_list),...
                        ');\n'],i);
    else
        act_list = setdiff(1:n_a,act_list);
        fprintf(fileID,['\tS == s%d -> !(', OR_ACTION(act_list),...
                        ');\n'],i);
    end
end

if(~isempty(A) && length(A) ~= n_s)
    if(length(A) <= n_s/2)
        fprintf(fileID,['\t',OR_STATE(A),';\n']);
    else
        fprintf(fileID,['\t!(',OR_STATE(setdiff(1:n_s,A)),');\n']);
    end
end
fprintf(fileID,'\t}\n');

%   GUARANTEE
fprintf(fileID,'\tGUARANTEE {\n');
if(~isempty(B) && length(B) ~= n_s)
    if(length(B)<=n_s/2)
        fprintf(fileID,['\tF G ( ',OR_STATE(B),' );\n']);
    else
        fprintf(fileID,['\tF G !( ',OR_STATE(setdiff(1:n_s,B)),' );\n']);
    end
end
if(~isempty(C_list))
    for i = 1:length(C_list)
        if(length(C_list{i})<=n_s/2)
            fprintf(fileID,['\tG F ( ',OR_STATE(C_list{i}),' );\n']);
        else
            fprintf(fileID,['\tG F !( ',OR_STATE(...
                setdiff(1:n_s,C_list{i})),' );\n']);
        end
    end
end
fprintf(fileID,'\t}\n');
fprintf(fileID,'}');
fclose(fileID);
end

function char = OR_STATE(states)
    char = sprintf('S == s%d',states(1));
    for i = 2:length(states)
        char =  [char,' || ',sprintf('S == s%d',states(i))];
    end
end
% 
% function char = OR_X_STATE(states)
%     char = sprintf(' X STATE[%d]',states(1)-1);
%     for i = 2:length(states)
%         char =  [char,' || ',sprintf(' X STATE[%d]',states(i)-1)];
%     end
% end

function char = OR_ACTION(actions)
    char = sprintf('A == a%d',actions(1));
    for i = 2:length(actions)
        char =  [char,' || ',sprintf('A == a%d',actions(i))];
    end
end