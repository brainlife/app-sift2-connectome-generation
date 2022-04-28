#!/bin/bash

set -x
set -e

mkdir -p connectomes labels raw

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
label=`jq -r '.label' config.json`
weights=`jq -r '.weights' config.json`
labels=`jq -r '.labels' config.json`
assignment_radial_search=`jq -r '.assignment_radial_search' config.json` # numerical: default is 4mm
assignment_reverse_search=`jq -r '.assignment_reverse_search' config.json` # numerical
assignment_forward_search=`jq -r '.assignment_forward_search' config.json` # numerical
ncores=8

#### copy and subsample tractogram if labels available, else use weights
if [[ ! ${labels} == null ]] && [[ ${weights} == null ]]; then
	cp ${labels} ./labels.csv
	weights=./labels.csv

	# subsample tractogram based on labels datatype. assumes labels.csv is purely just binary assignment of streamlines (one value per row, len(streamlines) rows)
	connectome2tck ${track} ${weights} ./filtered_ -nodes 1 -exclusive -keep_self -nthreads 8 && mv ./filtered_* ./track.tck
	track=./track.tck
elif [[ ${labels} == null ]] && [[ ! ${weights} == null ]]; then
	cp ${weights} ./weights.csv
	weights=./weights.csv
elif [[ ${labels} == null ]] && [[ ${weights} == null ]]; then
	tckinfo ${track} -count > ./tmp.txt
	num_tracks=`cat test.txt | sed 's/actual count in file: //' | grep -oi "[0-9].*" | tail -1`
	for (( i=0; i<${num_tracks}; i++ ))
	do
		echo "1" >> ./weights/weights.csv
	done
	weights=./weights.csv
else
	cp ${weights} ./weights.csv
	weights=./weights.csv
fi

#### set up input argument commands
cmd=""
if [[ ! ${assignment_radial_search} == "4" ]]; then
	cmd=$cmd" -assignment_radial_search ${assignment_radial_search}"
fi

if [[ ! ${assignment_reverse_search} == "" ]]; then
	cmd=$cmd" -assignment_reverse_search ${assignment_reverse_search}"
fi

if [[ ! ${assignment_forward_search} == "" ]]; then
	cmd=$cmd" -assignment_forward_search ${assignment_forward_search}"
fi

#### set up measures variable if diffusion measures included. if not, measures is null and bypasses diffusion measures lines ####
if [ -f ${fa} ] && [ -f ${ndi} ] && [ ! -f ${ga} ]; then
	measures="ad fa md rd ndi odi isovf"
elif [ ! -f ${ndi} ] && [ ! -f ${fa} ]; then
	echo "missing measures. skipping diffusion model matrix generation"
	measures=""
elif [ ! -f ${ndi} ] && [ -f ${fa} ] && [ ! -f ${ga} ]; then
	measures="ad fa md rd"
elif [ -f ${ndi} ] && [ -f ${fa} ] && [ -f ${ga} ]; then
	measures="ad fa md rd ga ak mk rk ndi odi isovf"
elif [ ! -f ${ndi} ] && [ -f ${ga} ]; then
	measures="ad fa md rd ga ak mk rk"
else
	measures="ndi odi isovf"
fi

#### conmat measures ####
conmat_measures="count density length denlen"

for i in ${conmat_measures}
do
	mkdir -p ${i}_out ${i}_out/csv
done

#### convert data to mif ####
# parcellation
if [ ! -f parc.mif ]; then
	echo "converting parcellation"
	mrconvert ${parc} parc.mif -force -nthreads ${ncores} -quiet
fi

# diffusion measures (if inputted)
if [[ ! -z ${measures} ]]; then
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
fi

#### generate connectomes ####
# microstructure networks (if inputted)
for MEAS in ${measures}
do
	if [ ! -f ./connectomes/${MEAS}_mean.csv ]; then
		echo "creating connectome for diffusion measure ${MEAS}"
		# sample the measure for each streamline
		tcksample ${track} ${MEAS}.mif mean_${MEAS}_per_streamline.csv -stat_tck mean -use_tdi_fraction -nthreads ${ncores} -force

		# generate mean measure connectome
		tck2connectome ${track} parc.mif ./connectomes/${MEAS}_mean.csv -scale_file mean_${MEAS}_per_streamline.csv -stat_edge mean -tck_weights_in ${weights} ${cmd} -symmetric -zero_diagonal -nthreads ${ncores} -force

		# generate mean measure connectome weighted by density
		tck2connectome ${track} parc.mif ./connectomes/${MEAS}_mean_density.csv -scale_file mean_${MEAS}_per_streamline.csv -scale_invnodevol -stat_edge mean -tck_weights_in ${weights} ${cmd} -symmetric -zero_diagonal -nthreads ${ncores} -force

		# generate mean measure connectome weighted by streamline length
		tck2connectome ${track} parc.mif ./connectomes/${MEAS}_mean_length.csv -scale_file mean_${MEAS}_per_streamline.csv -scale_invlength -stat_edge mean -tck_weights_in ${weights} ${cmd} -symmetric -zero_diagonal -nthreads ${ncores} -force

		# generate mean measure connectome weighted by density and streamline length
		tck2connectome ${track} parc.mif ./connectomes/${MEAS}_mean_denlen.csv -scale_file mean_${MEAS}_per_streamline.csv -scale_invnodevol -scale_invlength -stat_edge mean -tck_weights_in ${weights} ${cmd} -symmetric -zero_diagonal -nthreads ${ncores} -force
	fi
done

# count network
if [ ! -f ./connectomes/count.csv ]; then
	echo "creating connectome for streamline count"
	tck2connectome ${track} parc.mif ./connectomes/count.csv -out_assignments assignments.csv -tck_weights_in ${weights} ${cmd} -symmetric -zero_diagonal -force -nthreads ${ncores}

	cp ./connectomes/count.csv ./count_out/csv/correlation.csv
	cp ${label} ./count_out/
	cp ./templates/index.json ./count_out/
fi

# count density network
if [ ! -f ./connectomes/density.csv ]; then
	echo "creating connectome for streamline count"
	tck2connectome ${track} parc.mif ./connectomes/density.csv -scale_invnodevol -out_assignments assignments.csv -tck_weights_in ${weights} ${cmd} -symmetric -zero_diagonal -force -nthreads ${ncores}

	cp ./connectomes/density.csv ./density_out/csv/correlation.csv
	cp ${label} ./density_out/
	cp ./templates/index.json ./density_out/
fi

# length network
if [ ! -f ./connectomes/length.csv ]; then
	echo "creating connectome for streamline length"
	tck2connectome ${track} parc.mif ./connectomes/length.csv -scale_invlength -stat_edge mean -tck_weights_in ${weights} ${cmd} -symmetric -zero_diagonal -force -nthreads ${ncores}

	cp ./connectomes/length.csv ./length_out/csv/correlation.csv
	cp ${label} ./length_out/
	cp ./templates/index.json ./length_out/
fi

# density of length network
if [ ! -f ./connectomes/denlen.csv ]; then
	echo "creating connectome for streamline length"
	tck2connectome ${track} parc.mif ./connectomes/denlen.csv -scale_invlength -stat_edge mean -scale_invnodevol -tck_weights_in ${weights} ${cmd} -symmetric -zero_diagonal -force -nthreads ${ncores}

	cp ./connectomes/denlen.csv ./denlen_out/csv/correlation.csv
	cp ${label} ./denlen_out/
	cp ./templates/index.json ./denlen_out/
fi

# generate centers csv
if [ ! -f ./connectomes/centers.csv ]; then
	echo "creating csv for centers of nodes"
	labelstats parc.mif -output centre | sed 's/^[[:space:]]*//' | tr -s '[:blank:]' ',' > ./connectomes/centers.csv
fi

if [ -f ./connectomes/count.csv ] && [ -f ./connectomes/length.csv ]; then
	echo "generation of connectomes is complete!"
	mv weights.csv assignments.csv ./connectomes/

	# need to convert csvs to actually csv and not space delimited
	for csvs in ./connectomes/*.csv
	do
		if [[ ! ${csvs} == './connectomes/centers.csv' ]]; then
			if [[ ${csvs} == './connectomes/assignments.csv' ]]; then
				sed 1,1d ${csvs} > tmp.csv
				cat tmp.csv > ${csvs}
				rm -rf tmp.csv
			fi
			sed -e 's/\s\+/,/g' ${csvs} > tmp.csv
			cat tmp.csv > ${csvs}
			rm -rf tmp.csv
		fi
	done
	for conmats in ${conmat_measures}
	do
		sed -e 's/\s\+/,/g' ./${conmats}_out/csv/correlation.csv > ./${conmats}_out/csv/tmp.csv
		cat ./${conmats}_out/csv/tmp.csv > ./${conmats}_out/csv/correlation.csv
		rm -rf ./${conmats}_out/csv/tmp.csv
	done
else
	echo "something went wrong"
fi

[ ! -f ./labels/labels.csv ]
