#!/bin/bash
module load matlab/2017a
mkdir -p compiled

cat > build.m <<END
addpath(genpath('/N/u/brainlife/git/vistasoft'))
addpath(genpath('/N/u/brlife/git/jsonlab'))
mcc -m -R -nodisplay -d compiled generateDensityConnectomes
exit
END
matlab -nodisplay -nosplash -r build
