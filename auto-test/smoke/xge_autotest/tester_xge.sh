#!/bin/bash

TESTER_HNS_TOP_DIR=$(cd "`dirname $0`" ; pwd)

# Load common function
#. ${TESTER_HNS_TOP_DIR}/config/xge_test_config
#. ${TESTER_HNS_TOP_DIR}/config/xge_test_lib

# Load the public configuration library
#. ${TESTER_HNS_TOP_DIR}/../config/common_config

T_SERVER_IP=''
T_CLIENT_IP=''
T_CTRL_NIC=''
###################################################################################
#Usage
###################################################################################

Usage()
{
cat << EOF
Usage: ./xge_autotest/tester_hns.sh [options]
Options:
	-h, --help: Display this information
	-s, --sip: Server IP: this ip used to ssh with client
	-c, --cip: Client IP: this ip is client ip connect with server
	-n, --ctrlNIC: the network card used to control client
Example:
	bash tester_hns.sh -s "192.168.3.152" -c "192.168.3.153" -n "eth3"
	
	bash tester_hns.sh # if no para , scripts will fix the config with default value

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
		-s | --sip) T_SERVER_IP=$ac_optarg ;;
		-c | --cip) T_CLIENT_IP=$ac_optarg ;;
        -n | --ctrlNIC) T_CTRL_NIC=$ac_optarg ;;
		*) Usage ; echo "Unknown option $1"; exit 1 ;;
	esac

	$ac_shift
	shift
done

##################################################################################
#input the parameter
###################################################################################

. ${TESTER_HNS_TOP_DIR}/../config/common_config


g_server_ip=$T_SERVER_IP
g_ctrlNIC=$T_CTRL_NIC
g_client_ip=$T_CLIENT_IP
COM="true"
source ${TESTER_HNS_TOP_DIR}/xge_main.sh

#COM="true"

# clean exit so lava-test can trust the results
exit 0

