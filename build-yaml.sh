#!/bin/bash

debug=0

if ((! -z $VARIATIONS_ON_A_K_DEBUG)); 
then
	debug=1
	echo "Starting build-yaml.sh" > debug.log
	echo "======================" >> debug.log
fi


function debug() {
	if (($debug)); then
		echo "$1" >> debug.log
	fi
}


debug "given kustomization location: $1" 
start="${1%/}"
if [[ start != $(pwd)* ]]; then
	start="$(pwd)/$start"
fi


function path_relative_to() {
	debug "will now find path: $2, relative to: $1"
	full_first_path="$(readlink -e $1)"
	debug "full-path: $full_first_path"
	echo $(cd "$full_first_path" && cd "$(readlink -e $2)" && pwd)
}

function resources_from_kustomization() {
	debug "stat resources: $1"
	local kustomization_file="$1/kustomization.y*ml"
	if [ -f $1/kustomization.y*ml ]; 
	then
		local resources bases_str bases
		local replacement="$(echo "$1" | sed 's/\//\\\//g')\/"
		debug "replacement text: $replacement"
		resources="$(yq r $kustomization_file resources | sed -En "s/- /$replacement/p")"
		bases_str="$(yq r $kustomization_file bases | sed -En 's/- //p')"
		bases=($bases_str)
		debug "- bases: $bases_str"
		for base in "${bases[@]}"; do
			base="${base%/}"
			debug "-- base: $base"
			resources="$resources $(resources_from_kustomization $(path_relative_to $1 $base))"	
		done
		echo "$resources"
	else
		debug "no such file: $kustomization_file"
	fi
}


function remove_semicolon(){
	echo "$(echo "$1" | sed 's/;//g')"
}

function extract_header_from() {
	echo "$(remove_semicolon $(head -1 "$1"))"
}


resource_str=$(resources_from_kustomization "$start")
resources_list=($resource_str)
echo $resource_str

for resource in "${resources_list[@]}"; do
	resource_name=${resource%.*}
	if [ -f $resource_name.csv ]; then
		debug "backing up resource $resource, read csv"
		mv "$resource" "$resource.bak"
		rm -rf "$resource"
		touch "$resource"
		IFS="${VARIATIONS_ON_A_K_DELIMITER:,}"
		head=($(extract_header_from "$resource_name.csv"))
		sed 1d "$resource_name.csv" | while read line
		do
			values=($(remove_semicolon "$line"))
			for ((i = 0; i < ${#head[@]}; ++i)); do
				export "${head[$i]}"="${values[$i]}"
			done 
			envsubst < "$resource.bak" >> "$resource"
			echo "" >> "$resource"
			echo "---" >> "$resource"
		done
	  	sed -i '$d' "$resource" 
	fi	
done

kubectl kustomize $1
