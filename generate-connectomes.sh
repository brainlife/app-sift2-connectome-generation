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
t1_map=`jq -r '.T1map' config.json`
r1_map=`jq -r '.R1map' config.json`
m0_map=`jq -r '.M0map' config.json`
pd_map=`jq -r '.PD' config.json`
mtv_map=`jq -r '.MTV' config.json`
vip_map=`jq -r '.VIP' config.json`
sir_map=`jq -r '.SIR' config.json`
wf_map=`jq -r '.WF' config.json`
myelin_map=`jq -r '.myelin_map' config.json`
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
if [ -f ${labels} ] && [ ! -f ${weights} ]; then
	weights=""

	# subsample tractogram based on labels datatype. assumes labels.csv is purely just binary assignment of streamlines (one value per row, len(streamlines) rows)
	connectome2tck ${track} ${labels} ./filtered_ -nodes 1 -exclusive -keep_self -nthreads 8 && mv ./filtered_* ./track.tck
	track=./track.tck
elif [ ! -f ${labels} ] && [ -f ${weights} ]; then
	cp ${weights} ./weights.csv
	weights="-tck_weights_in ./weights.csv"
elif [ ! -f ${labels} ] && [ ! -f ${weights} ]; then
	weights=""
else # this condition is where both labels and weights are inputted. need to subselect the appropriate weights and subsample the tractogram

	# subsample tractogram
	connectome2tck ${track} ${labels} ./filtered_ -nodes 1 -exclusive -keep_self -nthreads 8 && mv ./filtered_* ./track.tck
	track=./track.tck

	# grab labels and weights data
	tmp_labels=(`cat ${labels}`)
	tmp_weights=(`cat ${weights}`)

	# for each streamline, identify ones where labels == 1. echo the weight for that streamline to ./weights.csv
	for (( i=0; i<${#tmp_labels[*]}; i++ ))
	do
		if [[ ${tmp_labels[${i}]} -eq 1 ]]; then
			echo ${weights[${i}]} >> ./weights.csv
		fi
	done

	# set weights to the new csv file generated
	weights="-tck_weights_in ./weights.csv"
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
measures_to_loop="ad fa md rd ga ak mk rk ndi odi isovf t1_map r1_map m0_map pd_map mtv_map vip_map sir_map wf_map myelin_map"

measures=""
for i in ${measures_to_loop}
do
	tmp=$(eval "echo \$${i}")

	if [ -f ${tmp} ]; then
		measures=$measures"${i} "
	fi
done

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

#### generate connectomes ####
## microstructural networks from diffusion data
# diffusion measures (if inputted)
if [[ ! -z ${measures} ]]; then
	for MEAS in ${measures}
	do
		if [ ! -f ${MEAS}.mif ]; then
			echo "converting ${MEAS}"
			measure=$(eval "echo \$${MEAS}")
			mrconvert ${measure} ${MEAS}.mif -force -nthreads ${ncores} -force -quiet
		fi

		if [ ! -f ./connectomes/${MEAS}_mean.csv ]; then
			echo "creating connectome for diffusion measure ${MEAS}"
			# sample the measure for each streamline
			tcksample ${track} ${MEAS}.mif mean_${MEAS}_per_streamline.csv -stat_tck mean -use_tdi_fraction -nthreads ${ncores} -force

			# generate mean measure connectome
			tck2connectome ${track} parc.mif ./connectomes/${MEAS}_mean.csv -scale_file mean_${MEAS}_per_streamline.csv -stat_edge mean ${weights} ${cmd} -symmetric -zero_diagonal -nthreads ${ncores} -force

			# generate mean measure connectome weighted by density
			tck2connectome ${track} parc.mif ./connectomes/${MEAS}_mean_density.csv -scale_file mean_${MEAS}_per_streamline.csv -scale_invnodevol -stat_edge mean ${weights} ${cmd} -symmetric -zero_diagonal -nthreads ${ncores} -force

			# generate mean measure connectome weighted by streamline length
			tck2connectome ${track} parc.mif ./connectomes/${MEAS}_mean_length.csv -scale_file mean_${MEAS}_per_streamline.csv -scale_invlength -stat_edge mean ${weights} ${cmd} -symmetric -zero_diagonal -nthreads ${ncores} -force

			# generate mean measure connectome weighted by density and streamline length
			tck2connectome ${track} parc.mif ./connectomes/${MEAS}_mean_denlen.csv -scale_file mean_${MEAS}_per_streamline.csv -scale_invnodevol -scale_invlength -stat_edge mean ${weights} ${cmd} -symmetric -zero_diagonal -nthreads ${ncores} -force
		fi
	done
fi

# count network
if [ ! -f ./connectomes/count.csv ]; then
	echo "creating connectome for streamline count"
	tck2connectome ${track} parc.mif ./connectomes/count.csv -out_assignments assignments.csv ${weights} ${cmd} -symmetric -zero_diagonal -force -nthreads ${ncores}

	cp ./connectomes/count.csv ./count_out/csv/correlation.csv
	cp ${label} ./count_out/
	cp ./templates/index.json ./count_out/
fi

# count density network
if [ ! -f ./connectomes/density.csv ]; then
	echo "creating connectome for streamline density"
	tck2connectome ${track} parc.mif ./connectomes/density.csv -scale_invnodevol -out_assignments assignments.csv ${weights} ${cmd} -symmetric -zero_diagonal -force -nthreads ${ncores}

	cp ./connectomes/density.csv ./density_out/csv/correlation.csv
	cp ${label} ./density_out/
	cp ./templates/index.json ./density_out/
fi

# length network
if [ ! -f ./connectomes/length.csv ]; then
	echo "creating connectome for streamline length"
	tck2connectome ${track} parc.mif ./connectomes/length.csv -scale_invlength -stat_edge mean ${weights} ${cmd} -symmetric -zero_diagonal -force -nthreads ${ncores}

	cp ./connectomes/length.csv ./length_out/csv/correlation.csv
	cp ${label} ./length_out/
	cp ./templates/index.json ./length_out/
fi

# density of length network
if [ ! -f ./connectomes/denlen.csv ]; then
	echo "creating connectome for streamline length"
	tck2connectome ${track} parc.mif ./connectomes/denlen.csv -scale_invlength -stat_edge mean -scale_invnodevol ${weights} ${cmd} -symmetric -zero_diagonal -force -nthreads ${ncores}

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
	mv assignments.csv ./connectomes/

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
