%SETUP  Add this repository's folders to the MATLAB search path.
%
%   SETUP adds the canonical project folders (src/, models/, scripts/,
%   tests/, config/) to MATLAB's path for the current session and prints a
%   short summary so you can verify nothing is missing.
%
%   Run this once per MATLAB session, from the repository root:
%
%       >> setup
%
%   The script intentionally does NOT save the path to disk. Persisting a
%   repository-relative path globally can break MATLAB for other projects.

repoRoot = fileparts(mfilename('fullpath'));

folders = { ...
    fullfile(repoRoot, 'src'), ...
    fullfile(repoRoot, 'models'), ...
    fullfile(repoRoot, 'scripts'), ...
    fullfile(repoRoot, 'tests'), ...
    fullfile(repoRoot, 'config'), ...
    fullfile(repoRoot, 'codegen', 'matlab'), ...
    fullfile(repoRoot, 'codegen', 'simulink') ...
};

for k = 1:numel(folders)
    if isfolder(folders{k})
        addpath(folders{k});
    else
        warning('setup:missingFolder', ...
            'Expected folder not found, skipped: %s', folders{k});
    end
end

fprintf('setup.m: added %d folders to the path.\n', numel(folders));
