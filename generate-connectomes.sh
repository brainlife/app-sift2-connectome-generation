#!/bin/bash

set -x
set -e

mkdir -p connectomes

#### configurable parameters ####
ad=`jq -r '.ad' config.json`
fa=`jq -r '.fa' config.json`
md=`jq -r '.md' config.json`
rd=`jq -r '.rd' config.json`
ga=`jq -r '.ga' config.json`
ak=`jq -r '.ak' config.json`
mk=`jq -r '.mk' config.json`
rk=`jq -r '.rk' config.json`
ndi=`jq -r '.ndi' config.json`
odi=`jq -r '.odi' config.json`
isovf=`jq -r '.isovf' config.json`
track=`jq -r '.track' config.json`
parc=`jq -r '.parc' config.json`
#inflate=`jq -r '.lmax2' config.json`
ncores=8

#### set up measures variable if diffusion measures included. if not, measures is null and bypasses diffusion measures lines ####
if [[ ! ${fa} == 'null' ]] && [[ ! ${ndi} == 'null' ]] && [[ ${ga} == 'null' ]]; then
	measures="ad fa md rd ndi odi isovf"
elif [[ ${ndi} == 'null' ]] && [[ ${fa} == 'null' ]]; then
	measures='null'
elif [[ ${ndi} == 'null' ]] && [[ ! ${fa} == 'null' ]]; then
	measures="ad fa md rd"
elif [[ ! ${ndi} == 'null' ]] && [[ ! ${fa} == 'null' ]] && [[ ! ${ga} == 'null' ]]; then
	measures="ad fa md rd ga ak mk rk ndi odi isovf"
elif [[ ${ndi} == 'null' ]] && [[ ! ${ga} == 'null' ]]; then
	measures="ad fa md rd ga ak mk rk"
else
	measures="ndi odi isovf"
fi

#### convert data to mif ####
# parcellation
if [ ! -f parc.mif ]; then
	echo "converting parcellation"
	mrconvert ${parc} parc.mif -force -nthreads ${ncores} -quiet
fi

# diffusion measures (if inputted)
for MEAS in ${measures}
do
	if [[ ! ${MEAS} == 'null' ]]; then 
		if [ ! -f ${MEAS}.mif ]; then
			echo "converting ${MEAS}"
			measure=$(eval "echo \$${MEAS}")
			mrconvert ${measure} ${MEAS}.mif -force -nthreads ${ncores} -force -quiet
		fi
	fi
done

#### generate connectomes ####
# microstructure networks (if inputted)
for MEAS in ${measures}
do
	if [ ! -f ./connectomes/${MEAS}_mean.csv ]; then
		echo "creating connectome for diffusion measure ${MEAS}"
		tcksample ${track} ${MEAS}.mif mean_${MEAS}_per_streamline.csv -stat_tck mean -use_tdi_fraction -nthreads ${ncores} -force
		tck2connectome ${track} parc.mif ./connectomes/${MEAS}_mean.csv -scale_file mean_${MEAS}_per_streamline.csv -stat_edge mean -symmetric -zero_diagonal -nthreads ${ncores} -force
		tck2connectome ${track} parc.mif ./connectomes/${MEAS}_mean_density.csv -scale_file mean_${MEAS}_per_streamline.csv -stat_edge mean -scale_invnodevol -symmetric -zero_diagonal -nthreads ${ncores} -force
	fi
done

# count network
if [ ! -f ./connectomes/count.csv ]; then
	echo "creating connectome for streamline count"
	tck2connectome ${track} parc.mif ./connectomes/count.csv -out_assignments assignments.csv -symmetric -zero_diagonal -force -nthreads ${ncores}
fi

# count density
if [ ! -f ./connectomes/density.csv ]; then
	echo "creating connectome for streamline count"
	tck2connectome ${track} parc.mif ./connectomes/density.csv -out_assignments assignments.csv -scale_invnodevol -symmetric -zero_diagonal -force -nthreads ${ncores}
fi

# length network
if [ ! -f ./connectomes/length.csv ]; then
	echo "creating connectome for streamline length"
	tck2connectome ${track} parc.mif ./connectomes/length.csv -scale_length -stat_edge mean -symmetric -zero_diagonal -force -nthreads ${ncores}
fi

# length density network
if [ ! -f ./connectomes/denlen.csv ]; then
	echo "creating connectome for streamline length"
	tck2connectome ${track} parc.mif ./connectomes/denlen.csv -scale_length -stat_edge mean -scale_invnodevol -symmetric -zero_diagonal -force -nthreads ${ncores}
fi

if [ -f ./connectomes/count.csv ] && [ -f ./connectomes/length.csv ]; then
	echo "generation of connectomes is complete!"
	mv assignments.csv ./connectomes/
	
	# need to convert csvs to actually csv and not space delimited
	for csvs in ./connectomes/*.csv
	do
		sed -e 's/\s\+/,/g' ${csvs} > tmp.csv
		cat tmp.csv > ${csvs}
		rm -rf tmp.csv
	done
else
	echo "something went wrong"
fi
