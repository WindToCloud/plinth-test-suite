#! /usr/bin/bash

BIOS_VERSION=''
BOARD_TYPE=''
BOARD_HW=''
BOARD_HW_TYPE=''

###################################################################################
#Usage
###################################################################################

Usage()
{
cat << EOF
Usage: ./estuary/build.sh [options]
Options:
	-h, --help: Display this information
	-b, --boardtype: Select which board to be update
		* supported board: D06
	-v, --version: Select the version of bios to be update
		* supported bios version: IT22
	-hw, --hardware: hard to descripte this option,see blow
		* supported hw: Pre_EC,Aft_EC,default is none
	-t, --type: hard to descript too,see blow
		* supported type: TA,TB,default is none
Example:
	./autoUpdateBios.sh -b D06 -v IT21 
	./autoUpdateBios.sh -b D06 -v IT22 \\	
		--hardware=Pre_EC --type=TA

EOF
}

##################################################################################
#Get all args
###################################################################################
while test $# != 0
do
	case $1 in
		--*=*) ac_option=`expr "X$1" : 'X\([^=]*\)='` ; ac_optarg=`expr "X$1" : 'X[^=]*=\(.*\)'` ; ac_shift=: ;;
		-*) ac_option=$1 ; ac_optarg=$2; ac_shift=shift ;;
		*) ac_option=$1 ; ac_shift=: ;;
	esac

	case $ac_option in
		-h | --help) Usage ; exit 0 ;;	
		-v | --version) BIOS_VERSION=$ac_optarg ;;
		-b | --boardtype) BORAD_TYPE=$ac_optarg ;;	
		-hw | --hardware) BOARD_HW=$ac_optarg ;;
		-t | --type) BOARD_HW_TYPE=$ac_optarg ;;
		*) Usage ; echo "Unknown option $1" ; exit 1 ;;
	esac

	$ac_shift
	shift
done

#################################################################################
#Clone the bios rep0
#################################################################################
if [ -d uefi ];then
	echo "The same name of dir is exist as uefi!Delete or rename it before running bios auto update scripts!"
	#exit 1
else
	git clone https://github.com/Luojiaxing1991/uefi.git
fi

pushd uefi

##################################################################################
#Check BORAD_TYPE and BIOS_VERSION
#################################################################################

#check if the bios version or board type is empty or not
if [ x"$BIOS_VERSION" = x"" ] && [ x"$BORAD_TYPE" = x"" ];then
	Usage
	exit 1
fi

#check the bios version is supported or not
version_list=`ls -a`
echo "The version supported is as "$version_list

if [[ $version_list =~ $BIOS_VERSION ]];then
	echo "Support to update the Version of $BIOS_VERSION "
else
	echo "Unsupport version ! exit !"
	exit 1
fi

#check the board is supported update or not
pushd $BIOS_VERSION

board_list=`ls -a`
echo "Supported hpm file is as "$version_list
if [[ $board_list =~ $BORAD_TYPE ]];then
	echo "Support to update the board of $BORAD_TYPE "
else
	echo "Unsupport board type ! exit !"
	exit 1
fi

##################################################################################
#Check BORAD_HW and BORAD_HW_TYPE
#################################################################################
declare -a hpm_list

oldifs="$IFS"
IFS=$'$\n'
hpm_list=`ls | cat | grep $BORAD_TYPE`

echo -e ${hpm_list[0]}

IFS=$oldifs

popd

popd
