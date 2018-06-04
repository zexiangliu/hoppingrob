function abstr2TLSF(filename, ts, A, B, C_list, IC)
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

% INFO
fprintf(fileID, 'INFO{\n');
fprintf(fileID, ['\tTITLE: "Controller synthesis for continuous' ...
               'dynamical systems"\n']);
fprintf(fileID,['\tDESCRIPTION: "Converted from the format used in' ...
    'control synthesis toolbox abstr-ref. Abstraction of continuous' ...
    'system is encoded in this TLSF file.'...
    'The spec is in the form of []A && <>[] B && []<> (R1 && R2 && ...'...
    '&& Rn)"\n']);
fprintf(fileID, '\tSEMANTICS:   Mealy,Strict\n');
fprintf(fileID, '\tTARGET:   Mealy\n');
fprintf(fileID,'}\n');

% GLOBAL
fprintf(fileID,'GLOBAL  {\n');
fprintf(fileID,'\tPARAMETERS {\n');
fprintf(fileID,'\t\tn = %u; //num of states\n', ts.n_s);
fprintf(fileID,'\t\tm = %u; //num of actions\n', ts.n_a);
fprintf(fileID,'\t}\n');
fprintf(fileID,'\tDEFINITIONS {\n');
fprintf(fileID,['\tmutual(b) =\n'...
                '\t||[i IN {0, 1 .. (SIZEOF b) -1}]\n'...
                '\t&&[j IN {0,1 .. (SIZEOF b) -1} (\\) {i}]\n'...
                '\t!(b[i] && b[j]);\n']);
fprintf(fileID,'\t}\n');
fprintf(fileID,'}\n');

% MAIN
fprintf(fileID,'MAIN{\n');
%   INPUTS
fprintf(fileID,['\tINPUTS {\n'...
    '\tSTATE[n];\n'...
    '\t}']);
%   OUTPUTS
fprintf(fileID,['\tOUTPUTS {\n'...
    '\tACTION[m];\n'...
    '\t}\n']);
%   INITIALLY
fprintf(fileID,'\tINITIALLY{\n');
%     Inforce winning set (or losing set) to be the initial condition
if(~isempty(IC) && length(IC)~=ts.n_s-1)
    fprintf(fileID,['\t',OR_STATE(IC),';\n']);
end
fprintf(fileID,'\tmutual(STATE) && (||[0 <= i <n] STATE[i]);\n');
fprintf(fileID,'\t}\n');
%   PRESET
fprintf(fileID,'\tPRESET {\n');
fprintf(fileID,'\tmutual(ACTION) && (||[0 <= i < m] ACTION[i]);\n');
fprintf(fileID,'\t}\n');
%   REQUIRE
fprintf(fileID,'\tREQUIRE {\n');
fprintf(fileID,'\tmutual(STATE) && (||[0 <= i < n] STATE[i]);\n');
for i = 1:ts.n_a
    for j = 1:ts.n_s
        s2_list = find(ts.trans_array{i}(j,:));
        fprintf(fileID,['\t(STATE[%d] && ACTION[%d]) -> (', ...
            OR_X_STATE(s2_list), ' );\n'], j-1, i-1);
    end
end
fprintf(fileID,'\t}\n');
% ASSERT
fprintf(fileID,'\tASSERT {\n');
fprintf(fileID,'\tmutual(ACTION) && (||[0 <= i < m] ACTION[i]);\n');
if(~isempty(A) && length(A) ~= ts.n_s)
    fprintf(fileID,['\t',OR_STATE(A),';\n']);
end
fprintf(fileID,'\t}\n');
% GUARANTEE
fprintf(fileID,'\tGUARANTEE {\n');
if(~isempty(B) && length(B) ~= ts.n_s)
    fprintf(fileID,['\tF G ( ',OR_STATE(B),' );\n']);
end
if(~isempty(C_list))
    for i = 1:length(C_list)
        fprintf(fileID,['\tG F ( ',OR_STATE(C_list{i}),' );\n']);
    end
end
fprintf(fileID,'\t}\n');
fprintf(fileID,'}');
fclose(fileID);
end

function char = OR_STATE(states)
    char = sprintf('STATE[%d]',states(1)-1);
    for i = 2:length(states)
        char =  [char,' || ',sprintf('STATE[%d]',states(i)-1)];
    end
end

function char = OR_X_STATE(states)
    char = sprintf(' X STATE[%d]',states(1)-1);
    for i = 2:length(states)
        char =  [char,' || ',sprintf(' X STATE[%d]',states(i)-1)];
    end
end