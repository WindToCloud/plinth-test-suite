#!/bin/bash

# File transfer stability test
# IN : N/A
# OUT: N/A
function iozne_file_transfer_stability_test()
{
    Test_Case_Title="iozne_file_transfer_stability_test"

    #find out this test is running on sas or sata

    tmp=`echo ${TEST_CASE_ID} | awk -F'.' '{print $NF}'`
	
    case $tmp in
	'017')
		target_type="HGST"
	;;
	'023')
		target_type="ATA"
	;;
	'031')
		target_type="HGST"
	;;
	'038')
		target_type="ATA"
	;;
	*)
		echo "error,can not get the target disk type!"
		target_type="ATA"
	;;
    esac

    #MESSAGE="PASS"
    MESSAGE="FAIL\ttarget disk type no found "${disk_name}" disk failure."

    #for disk_name in "${ALL_DISK_PART_NAME[@]}"
    for disk_name in "${ALL_DISK_PART_NAME[@]}"
    do

	#check type is correct or not
	tmp=${disk_name%?}
	tmp_type=`lsscsi -d | grep $tmp | awk '{print $3}'`
	if [ x"$tmp_type" != x"$target_type" ];then
		#MESSAGE="FAIL\ttarget disk type no found "${disk_name}" disk failure."
		continue
	fi
        MESSAGE="PASS"

	echo "Running iozone on $tmp_type disk $disk_name"

        mount_disk ${disk_name}
        if [ $? -ne 0 ]
        then
            umount ${disk_name}
            MESSAGE="FAIL\tMount "${disk_name}" disk failure."
            return 1
        fi

        ${SAS_TOP_DIR}/../${COMMON_TOOL_PATH}/iozone -a -n 1g -g 10g -i 0 -i 1 -i 2 -f /mnt/iozone -V 5aa51ff1
        status=$?
        if [ ${status} -ne 0 ]
        then
            umount ${disk_name}
            MESSAGE="FAIL\tFile transfer stability test,IO read and write exception."
            return 1
        fi

        umount ${disk_name}
        rm -f ${ERROR_INFO}

	break
    done
    #MESSAGE="PASS"
}


function main()
{
    # call the implementation of the automation use cases
    test_case_function_run
}

main
