#! /usr/bin/bash

declare -a tmp_list

BIOS_VERSION=''
BOARD_TYPE=''
BOARD_HW=''
BOARD_HW_TYPE=''
BMC_IP=''
BMC_ACCOUNT=''
BMC_PASSWORD=''
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
	-a, --account: the account of BMC
	-p, --password: the password of account before
Example:
	./autoUpdateBios.sh -b D06 -v IT21 -ip 192.168.2.166 \\
		-a root -p root
	./autoUpdateBios.sh -b D06 -v IT22 --bmcip=192.168.2.166\\
		--account=root --password=root \\	
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
		-a | --account) BMC_ACCOUNT=$ac_optarg ;;
		-p | --password) BMC_PASSWORD=$ac_optarg ;;
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
	exit 1
else
	git clone https://github.com/Luojiaxing1991/uefi.git
fi

pushd uefi

##################################################################################
#Check BOARD_TYPE and BIOS_VERSION and BMC_IP and BMC_ACCOUNT and BMC_PASSWORD
#################################################################################

#check if the bios version or board type is empty or not
if [ x"$BIOS_VERSION" = x"" ] || [  x"$BOARD_TYPE" = x"" ]
then
	echo "version and board_type is need!"
	Usage
	exit 1
fi

if [ x"$BMC_IP" = x"" ] || [  x"$BMC_ACCOUNT" = x"" ] || [  x"$BMC_PASSWORD" = x"" ]
then
	echo "BMC info is need!"
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
	echo "Support to update the board of $BOARD_TYPE "
else
	echo "Unsupport board type ! exit !"
	exit 1
fi

##################################################################################
#Check BOARD_HW and BOARD_HW_TYPE
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

which expect

if [ $? -ne 0 ];then
	echo "Unsupported expect cmd! please install it by apt-get install expect and retry."
	exit 1
fi

if [ -f res.log ];then
	rm res.log
	touch res.log
else
	touch res.log
fi

#check if the bmc is support shell cmd or not
expect -c '
	set timeout 120
	set ip '${BMC_IP}'
	set acc '${BMC_ACCOUNT}'
	set pass '${BMC_PASSWORD}'
	spawn ssh $acc@$ip "ls -a"
	expect {
		"password" { send "${pass}\r" }
	} 
	
	expect eof
	exit 0
' | tee res.log

tmp=`cat res.log`

if [[ $tmp =~ "Permission denied" ]];then
	echo "Account or password is not correct!Please check."
	exit 1
fi

if [[ $tmp =~ "command not found" ]];then
	echo "BMC is not support shell! Update the toshell hpm first!"
	
	#update the bmc first to support shell cmd
	pushd ../Prepare
	
	expect -c '
	set timeout 240
	set ip '${BMC_IP}'
	set acc '${BMC_ACCOUNT}'
	set pass '${BMC_PASSWORD}'
	spawn scp  v5_toshell-noroot.hpm ${acc}@${ip}:/tmp/toshell.hpm
	expect {
		"password" { send "${pass}\r" }
	} 
	
	spawn ssh $acc@$ip "/opt/pme/bin/ipmcset -d upgrade -v /tmp/toshell.hpm"
	expect {
		"password" { send "${pass}\r" }
	} 
	
	expect eof
	exit 0
'
	echo "End of toshell update!"
	popd
else
	echo "BMC support shell! Ready to update UEFI...."
fi

#begin to update UEFI
step_num=`ls | cat | grep $target | wc -l `

if [ x"$step_num" = x"1" ];then
	
	echo "only one step to update"
	
	hpm=`ls | cat | grep $target`

	expect -c '
	set timeout 240
	set ip '${BMC_IP}'
	set acc '${BMC_ACCOUNT}'
	set pass '${BMC_PASSWORD}'
	set file '${hpm}'
	spawn scp  ${file} ${acc}@${ip}:/tmp/uefi.hpm
	expect {
		"password" { send "${pass}\r" }
	} 
	
	spawn ssh $acc@$ip "/opt/pme/bin/ipmcset -d upgrade -v /tmp/uefi.hpm"
	expect {
		"password" { send "${pass}\r" }
	} 
	
	expect eof
	exit 0
'

else
	echo "multi step should be take!"
	oldifs="$IFS"
	IFS=$'$\n'
	tmp_list=`ls | cat | grep $target`
	echo -e ${tmp_list[0]}

	IFS=$oldifs
	for ((i=1; i<=${#tmp_list[@]}; i++ ))
	do
		hpm=$target"_"$i".hpm"
		echo "target hpm is $hpm"
	done
fi

popd

popd

if [ -d uefi ];then
	rm -rf uefi
fi


