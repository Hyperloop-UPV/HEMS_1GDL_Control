%BUILDCODEGEN  Generate C++ from MATLAB entry points and Simulink models.
%
%   BUILDCODEGEN reads two manifests:
%
%     codegen/matlab/entries.txt     MATLAB Coder entry points
%     codegen/simulink/entries.txt   Simulink models to compile
%
%   Each manifest has one entry per non-comment line. MATLAB Coder entries
%   are function names; the script invokes them with `codercfg.m` from the
%   same folder. Simulink entries are model names; the model's active
%   configuration set is used.
%
%   The script prints a summary table and exits with status 0 on full
%   success, 1 if any entry failed. Designed to be called from
%   `scripts/build_codegen.sh` via `matlab -batch`, but also runnable
%   interactively:
%
%       >> setup
%       >> build_codegen
%
%   See ../docs/codegen.md for the broader workflow.

function status = build_codegen()
repoRoot = fileparts(fileparts(mfilename('fullpath')));

matlabManifest = fullfile(repoRoot, 'codegen', 'matlab', 'entries.txt');
simulinkManifest = fullfile(repoRoot, 'codegen', 'simulink', 'entries.txt');

matlabEntries = readEntries(matlabManifest);
simulinkEntries = readEntries(simulinkManifest);

results = struct('tool', {}, 'name', {}, 'ok', {}, 'message', {});

for k = 1:numel(matlabEntries)
    [ok, msg] = runMatlabCoder(repoRoot, matlabEntries{k});
    results(end+1) = struct('tool', 'matlab-coder', 'name', matlabEntries{k}, ...
        'ok', ok, 'message', msg); %#ok<AGROW>
end

for k = 1:numel(simulinkEntries)
    [ok, msg] = runSlbuild(simulinkEntries{k});
    results(end+1) = struct('tool', 'slbuild', 'name', simulinkEntries{k}, ...
        'ok', ok, 'message', msg); %#ok<AGROW>
end

printSummary(results);

status = all([results.ok]);
if ~status && ~isempty(results)
    fprintf('codegen: %d/%d entries failed.\n', ...
        sum(~[results.ok]), numel(results));
end

if ~usejava('desktop')
    if status
        exit(0);
    else
        exit(1);
    end
else
    if ~status
        error('build_codegen:failed', ...
            'One or more codegen entries failed; see summary above.');
    end
end
end

function entries = readEntries(path)
entries = {};
if ~isfile(path)
    return;
end
raw = fileread(path);
lines = regexp(strtrim(raw), '\r?\n', 'split');
for k = 1:numel(lines)
    line = strtrim(lines{k});
    if isempty(line) || startsWith(line, '#')
        continue;
    end
    entries{end+1} = line; %#ok<AGROW>
end
end

function [ok, msg] = runMatlabCoder(repoRoot, entry)
cfgPath = fullfile(repoRoot, 'codegen', 'matlab');
cfg = fullfile(cfgPath, 'codercfg.m');
if ~isfile(cfg)
    ok = false;
    msg = sprintf('missing %s — copy codercfg.m.example to codercfg.m', cfg);
    return;
end
try
    cd(cfgPath);
    coder('-config', 'codercfg', entry);
    ok = true;
    msg = 'ok';
catch err
    ok = false;
    msg = err.message;
end
end

function [ok, msg] = runSlbuild(model)
try
    load_system(model);
    slbuild(model);
    ok = true;
    msg = 'ok';
catch err
    ok = false;
    msg = err.message;
end
end

function printSummary(results)
fprintf('\n========== codegen summary ==========\n');
if isempty(results)
    fprintf('  (no entries — nothing to do)\n');
    fprintf('=====================================\n');
    return;
end
fprintf('  %-14s %-32s %-6s  %s\n', 'tool', 'entry', 'status', 'message');
fprintf('  %s\n', repmat('-', 1, 80));
for k = 1:numel(results)
    statusStr = tern(results(k).ok, 'OK', 'FAIL');
    msg = results(k).message;
    if numel(msg) > 60
        msg = [msg(1:57), '...'];
    end
    fprintf('  %-14s %-32s %-6s  %s\n', ...
        results(k).tool, results(k).name, statusStr, msg);
end
fprintf('=====================================\n');
end

function out = tern(cond, a, b)
if cond
    out = a;
else
    out = b;
end
end
