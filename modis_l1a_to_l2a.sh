#!/bin/bash

# create by jingning lv	2024-04-15
# modify by shuhui zhao	2024-05-07
# use to process modis_aqua L1A_LAC.bz2 to L2A_LAC
# you need have parfile and L1B_replace_satuated_rrs2.py in this folder



inpath=$1
outpath=$2
filename=$3

# if don't have result folder create one
if [ -d "./result" ]; then
    mkdir ./result

# create tmp fold in ./
temp_dir=$(mktemp -d -p .)
# echo "Created temporary directory: $temp_dir"

# mv bz2file to temp_dir to process
mv $filename $temp_dir

# move to temp_dir process
cd $temp_dir

filename=$(find . -name "*.bz2")

temp_name=$(basename $filename)
year="${temp_name:1:4}"
julianday="${temp_name:5:3}"
hour="${temp_name:8:2}"

file1_hour=0
file2_hour=0
if [ $hour -ge 22 ]; then
	julianday2=$((10#$julianday + 1))
    if [ $julianday2 -eq 366 ]; then
        if [ $((year % 4)) -eq 0 ] && [ $((year % 100)) -ne 0 ] || [ $((year % 400)) -eq 0 ]; then
            # leapyear
            year2=$((10#$year))
        else
            julianday2=1
            year2=$((10#$year +1))
        fi
    elif [ $julianday2 -eq 367 ]; then
        julianday2=1
        year2=$((10#$year +1))
    else
        year2=$((10#$year))
    fi
	file1_hour=$(( $hour / 2 * 2))
	file2_hour=0
else
	julianday2=$julianday
    year2=$((10#$year))
	file1_hour=$(( $hour / 2 * 2))
	file2_hour=$(( $file1_hour + 2))
fi

ephday=0
if [ $hour -ge 12 ]; then
	ephday=$((10#$julianday))
    year1=$((10#$year))
else
	ephday=$((10#$julianday - 1))
    if [ $ephday -eq 0 ]; then
        year1=$((10#$year -1))
        if [ $((year1 % 4)) -eq 0 ] && [ $((year1 % 100)) -ne 0 ] || [ $((year1 % 400)) -eq 0 ]; then
            # leapyear
            ephday=366
        else
            ephday=365
        fi
    else
        year1=$((10#$year))
    fi
    
fi

echo $temp_name

filename="./$temp_name"

l1afiles=${filename%.*}
geofiles=${l1afiles%.*}".GEO"
l1bfiles=${l1afiles%.*}".L1B_LAC"
l1bfiles_qkm=${l1afiles%.*}".L1B_QKM"
l1bfiles_hkm=${l1afiles%.*}".L1B_HKM"
l2afiles=${l1afiles%.*}".L2A_LAC_ZD_-3"
parfile=../1km_Rrs_global_proc_nir.par

ocsswhome=/home/nkd/software/SeaDAS_8.3.0/ocssw
att1file="$ocsswhome/var/anc/${year}/${julianday}/PM1ATTNR.P${year}${julianday}.$(printf "%02d" $file1_hour)00.003"
if [ ! -f $att1file ]; then
	att1file="$ocsswhome/var/anc/${year}/${julianday}/PM1ATTNR.P${year}${julianday}.$(printf "%02d" $file1_hour)00.002"
    if [ ! -f $att1file ]; then
        att1file="$ocsswhome/var/anc/${year}/${julianday}/PM1ATTNR.P${year}${julianday}.$(printf "%02d" $file1_hour)00.001"
        if [ ! -f $att1file ]; then
            echo "error: $att1file not exist! ---"
        fi
    fi
fi
att2file="$ocsswhome/var/anc/${year2}/$(printf "%03d" $julianday2)/PM1ATTNR.P${year2}$(printf "%03d" $julianday2).$(printf "%02d" $file2_hour)00.003"
if [ ! -f $att2file ]; then
	att2file="$ocsswhome/var/anc/${year2}/$(printf "%03d" $julianday2)/PM1ATTNR.P${year2}$(printf "%03d" $julianday2).$(printf "%02d" $file2_hour)00.002"
    if [ ! -f $att2file ]; then
        att2file="$ocsswhome/var/anc/${year2}/$(printf "%03d" $julianday2)/PM1ATTNR.P${year2}$(printf "%03d" $julianday2).$(printf "%02d" $file2_hour)00.001"
        if [ ! -f $att2file ]; then
            echo "error: $att2file not exist! ---"
        fi
    fi
fi
eph1file="$ocsswhome/var/anc/${year1}/$(printf "%03d" $ephday)/PM1EPHND.P${year1}$(printf "%03d" $ephday).1200.001"
if [ ! -f $eph1file ]; then
	eph1file="$ocsswhome/var/anc/${year1}/$(printf "%03d" $ephday)/PM1EPHND.P${year1}$(printf "%03d" $ephday).1200.003"
    if [ ! -f $eph1file ]; then
        eph1file="$ocsswhome/var/anc/${year1}/$(printf "%03d" $ephday)/PM1EPHND.P${year1}$(printf "%03d" $ephday).1200.002"
        if [ ! -f $eph1file ]; then
            echo "error: $eph1file not exist! ---"
        fi
    fi
fi
#echo $att1file
#echo $att2file
#echo $eph1file

bzip2 -dk ${filename}
if [ ! -e $l1afiles ]; then
    echo "$filename" >> ../l1acorrupted.txt
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
	# l2gen ifile=$l1bfiles geofile=$geofiles ofile=$l2afiles par=$parfile
	/home/lvjn/get_l2gen/bin/test ifile=$l1bfiles geofile=$geofiles ofile=$l2afiles par=$parfile
	if [ ! -e $l2afiles ]; then
		echo $l2afiles >> ../error.log
		echo "$filename" >> ../error_v2.log
	fi
fi

# mv l2afile to result_file
if [ ! -d ../result/ ]; then
    mkdir ../result/
fi
mv $l2afiles ../result/

cd ../
rm -rf $temp_dir
