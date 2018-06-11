#! /usr/bin/bash

BIOS_VERSION=''
BOARD_TYPE=''
BOARD_HW=''
BOARD_HW_TYPE=''
BMC_IP=''

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
	-ip, --bmcip: ip of target bmc 
Example:
	./autoUpdateBios.sh -b D06 -v IT21 -ip 192.168.2.166
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
		-b | --boardtype) BOARD_TYPE=$ac_optarg ;;	
		-hw | --hardware) BOARD_HW=$ac_optarg ;;
		-t | --type) BOARD_HW_TYPE=$ac_optarg ;;
		-ip | --bmcip) BMC_IP=$ac_optarg ;;
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
#Check BORAD_TYPE and BIOS_VERSION and BMC_IP
#################################################################################

#check if the bios version or board type is empty or not
if [ x"$BIOS_VERSION" = x"" ] && [ x"$BORAD_TYPE" = x"" ] && [ x"$BMC_IP" = x"" ];then
	Usage
	exit 1
fi

#check the bmc is online or not
if [ x"$BMC_IP" = x"" ];then
	echo "BMC ip is not set! exit. "
	exit 1
else
	ping $BMC_IP -c 5 | grep " 0% packet loss"
	
	if [ $? -eq 0 ];then
		echo "BMC is online! Support UEFI auto-update!"
	else
		echo "BMC is offline! Check if the script is running on Board server or not!"
		exit 1
	fi
	
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
if [[ $board_list =~ $BOARD_TYPE ]];then
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
hpm_list=`ls | cat | grep $BOARD_TYPE`

echo -e ${hpm_list[0]}

IFS=$oldifs

first_hpm=`echo ${hpm_list[0]} | awk -F'.' '{print $1}'`
first_hpm=${first_hpm%_*}

echo $first_hpm

#check the board bios have mutil version or not
hpm_num=`ls | cat | grep $BOARD_TYPE | wc -l`
first_num=`ls | cat | grep $first_hpm | wc -l`

if [ "$hpm_num"x = "$first_num"x ];then
	target=$first_hpm
	echo "Target hpm is only one! Mask as $target"
else
	#check the para hw and t is input or not
	if [ x"${BOARD_HW}" = x"" ] && [ x"${BOARD_HW_TYPE}" = x"" ]
	then
		echo "The traget multi exist! Please input -hw and -t to define it! Use -h to see more."
		exit 1
	fi

	target=$BOARD_TYPE"_"$BOARD_HW"_"${BOARD_HW_TYPE}
	tmp=`ls -a`
	if [[ $tmp =~ $target ]];then
		echo "Target lock! Mask as $target"
	else
		echo "Target loss!Pre set is $target !Please check -hw and -t! Use -h to see more."
	fi
fi

##################################################################################
#Update the UEFI through BMC
#################################################################################

#check if the bmc is support shell cmd or not


popd

popd
