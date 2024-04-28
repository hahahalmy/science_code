#!/bin/bash

inpath=$1
outpath=$2
filename=$3

# create tmp fold in ./
temp_dir=$(mktemp -d -p .)
# echo "Created temporary directory: $temp_dir"

# mv bz2file to temp_dir to process
mv $filename $temp_dir

# move to temp_dir process
cd $temp_dir

temp_name=$(basename $filename)
year="${temp_name:1:4}"
julianday="${temp_name:5:3}"
hour="${temp_name:8:2}"

file1_hour=0
file2_hour=0
if [ $hour -ge 22 ]; then
	julianday2=$((10#$julianday + 1))
	file1_hour=$(( $hour / 2 * 2))
	file2_hour=0
else
	julianday2=$julianday
	file1_hour=$(( $hour / 2 * 2))
	file2_hour=$(( $file1_hour + 2))
fi

ephday=0
if [ $hour -ge 12 ]; then
	ephday=$((10#$julianday))
else
	ephday=$((10#$julianday - 1))
fi

echo $temp_name

filename="./$temp_name"

l1afiles=${filename%.*}
geofiles=${l1afiles%.*}".GEO"
l1bfiles=${l1afiles%.*}".L1B_LAC"
l1bfiles_qkm=${l1afiles%.*}".L1B_QKM"
l1bfiles_hkm=${l1afiles%.*}".L1B_HKM"
l2afiles=${l1afiles%.*}".L2A_LAC_ZD_-3"
parfile=../hkm_Rrs_global_proc.par

att1file="/home/software/SeaDAS/ocssw/var/anc/${year}/${julianday}/PM1ATTNR.P${year}${julianday}.$(printf "%02d" $file1_hour)00.003"
att2file="/home/software/SeaDAS/ocssw/var/anc/${year}/${julianday2}/PM1ATTNR.P${year}${julianday2}.$(printf "%02d" $file2_hour)00.003"
eph1file="/home/software/SeaDAS/ocssw/var/anc/${year}/$(printf "%03d" $ephday)/PM1EPHND.P${year}$(printf "%03d" $ephday).1200.001"
if [ ! -f $eph1file ]; then
	eph1file="/home/software/SeaDAS/ocssw/var/anc/${year}/$(printf "%03d" $ephday)/PM1EPHND.P${year}$(printf "%03d" $ephday).1200.003"
fi

#echo $att1file
#echo $att2file
#echo $eph1file

bzip2 -dk ${filename}
if [ ! -e $l1afiles ]; then
	echo "$l1afiles" >> ../error.log
	echo "$filename" >> ../error_v2.log
	exit
fi

# generate GEO file
modis_GEO --att1 $att1file --att2 $att2file --eph1 $eph1file -o $geofiles $l1afiles
if [ ! -e $geofiles ]; then
	echo "$geofiles" >> ../error.log
	echo "$filename" >> ../error_v2.log
	exit
fi

modis_L1B -o $l1bfiles -q $l1bfiles_qkm -k $l1bfiles_hkm $l1afiles $geofiles
if [ ! -e $l1bfiles ]; then
	echo "$l1bfiles" >> ../error.log
	echo "$filename" >> ../error_v2.log
 	exit
else
	# back upper dir
	python ../L1B_replace_satuated_rrs2.py $l1bfiles
	
	/home/lvjn/get_l2gen/bin/test ifile=$l1bfiles geofile=$geofiles ofile=$l2afiles par=$parfile
	if [ ! -e $l2afiles ]; then
		echo $l2afiles >> ../error.log
		echo "$filename" >> ../error_v2.log
	fi
fi

# mv l2afile to result_file
mv $l2afiles ../result/

cd ../
rm -rf $temp_dir
