function [] = generateDensityConnectomes()

if ~isdeployed
    disp('loading path')

    %for IU HPC
    addpath(genpath('/N/u/brlife/git/jsonlab'))
    addpath(genpath('/N/u/brlife/git/vistasoft'))
end

% Set top directory
topdir = pwd;

% Load configuration file
config = loadjson('config.json');

% load count and length connectomes
count = load(fullfile(topdir,'count.csv'));
length = load(fullfile(topdir,'length.csv'));

% parse number of streamlines to compute density
track = fgRead(config.track);
num_streamlines = length(track.fibers);
clear track

% compute density
count_density = count ./ num_streamlines;
length_density = length ./ num_streamlines;

% output densities
dlmwrite('density.csv',count_density);
dlmwrite('denlen.csv',length_density);

end