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
count = load(fullfile(topdir,'connectomes','count.csv'));
length = load(fullfile(topdir,'connectomes','length.csv'));

% parse number of streamlines to compute density
track = fgRead(config.track);
num_streamlines = size(track.fibers,1);
clear track

% compute density
count_density = count ./ num_streamlines;
length_density = length ./ num_streamlines;

% output densities
dlmwrite(fullfile(topdir,'connectomes','density.csv'),count_density);
dlmwrite(fullfile(topdir,'connectomes''denlen.csv'),length_density);

end
