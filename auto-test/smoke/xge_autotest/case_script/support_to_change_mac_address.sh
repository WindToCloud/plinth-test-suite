#!/bin/bash

# Support to change MAC address
# IN :N/A
# OUT:N/A

function ge_mac_address_random_generation()
{
    Test_Case_Title="ge_mac_address_random_generation"
    echo "Begin to run "${Test_Case_Title}
    ifconfig ${local_tp1} up; ifconfig ${local_tp1} ${local_tp1_ip}
    ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ifconfig ${remote_tp1} up; ifconfig ${remote_tp1} ${remote_tp1_ip}; sleep 5;"

    MacAddress1=$(ifconfig ${local_tp1} | grep "HWaddr" | awk '{print $NF}' | tr -d ':')

    ifconfig ${local_tp1} down;sleep 5
    MacAddress2=$(ifconfig ${local_tp1} | grep "HWaddr" | awk '{print $NF}' | tr -d ':')
    ifconfig ${local_tp1} up
    if [ "$MacAddress1" = "$MacAddress2" ];then
        MESSAGE="PASS"
	echo ${MESSAGE}
    else
        MESSAGE="FAIL\t MAC addresses cannot be generated randomly "
	echo ${MESSAGE}
    fi
}

function ge_mac_address_fault_tolerant()
{
    MESSAGE="PASS"

    Test_Case_Title="ge_mac_address_fault_tolerant"
    ifconfig ${local_tp1} up; ifconfig ${local_tp1} ${local_tp1_ip}
    ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ifconfig ${remote_tp1} up; ifconfig ${remote_tp1} ${remote_tp1_ip}; sleep 5;"
    OrgMacAddress1=$(ifconfig ${local_tp1} | grep "HWaddr" | awk '{print $NF}')
    echo ${OrgMacAddress1}
    gemacvalue="1 3 5 7 9"
    for i in $gemacvalue
    do
        NewMacAddress="c$i:a8:01:83:00:04"
        #ifconfig ${local_tp1} hw ether $NewMacAddress | grep "SIOCSIFHWADDR: Cannot assign requested address"
        ifconfig ${local_tp1} hw ether $NewMacAddress 2>/dev/null
        if [ $? -eq 0 ];then
            MESSAGE="FAIL\t The wrong MAC address has been configured  "
        fi
    done

    for x in "00:00:00:00:00:00" "ff:ff:ff:ff:ff:ff" "c1:a8:01:83:00:0418"
    do
        #ifconfig ${local_tp1} hw ether $x | grep "SIOCSIFHWADDR: Cannot assign requested address"
        ifconfig ${local_tp1} hw ether $x 2>/dev/null
        if [ $? -eq 0 ];then
            MESSAGE="FAIL\t The wrong MAC address has been configured  "
        fi
    done
    #MESSAGE="PASS"

    ifconfig ${local_tp1} hw ether ${OrgMacAddress1}
    OrgMacAddress1=$(ifconfig ${local_tp1} | grep "HWaddr" | awk '{print $NF}')
    echo "Recover mac as "${OrgMacAddress1}

}

function ge_set_standard_mac_address()
{
    Test_Case_Title="ge_set_standard_mac_address"
    ifconfig ${local_tp1} up; ifconfig ${local_tp1} ${local_tp1_ip}
    ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ifconfig ${remote_tp1} up; ifconfig ${remote_tp1} ${remote_tp1_ip}; sleep 5"
    MESSAGE="PASS"

    oldMacAddress=$(ifconfig ${local_tp1} | grep "HWaddr" | awk '{print $NF}')
    Random_Mac=$((RANDOM%99))
    Random_Mac1=$((RANDOM%99))
    # if [ ${oldMacAddress:15:2} = "44" ];then
        # newMacAddress=$(echo $oldMacAddress |sed s/"${oldMacAddress:15:2}"/"22"/g)
    # else
        # newMacAddress=$(echo $oldMacAddress |sed s/"${oldMacAddress:15:2}"/"44"/g)
    # fi
    if [ ${Random_Mac} -lt 10 ]
    then
        Random_Mac="0"${Random_Mac}
    fi
    if [ ${Random_Mac1} -lt 10 ]
    then
        Random_Mac1="0"${Random_Mac}
    fi
    newMacAddress=$(echo $oldMacAddress |sed s/"${oldMacAddress:15:2}"/"${Random_Mac}"/g)
    remoteMacAddress=$(ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ifconfig ${local_tp1} | grep "HWaddr"")
    remoteMacAddress=$(echo ${remoteMacAddress} | awk '{print $NF}')
    if [ "${newMacAddress}"x == "${remoteMacAddress}"x ]
    then
        newMacAddress=$(echo $oldMacAddress |sed s/"${oldMacAddress:15:2}"/"${Random_Mac1}"/g)
    fi
    ifconfig ${local_tp1} hw ether ${newMacAddress}
    sleep $ARP_MAC_UPDATE_TIME

    ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ping ${local_tp1_ip} -c 10 &> /dev/null;sleep 5;"
    newMacAddress1=$(ssh -o StrictHostKeyChecking=no root@${BACK_IP} "arp -a | grep -w ${local_tp1_ip}")
    newMacAddress1=$(echo ${newMacAddress1} | awk -F'at' '{print $NF}' | awk '{print $1}')
    echo $newMacAddress1
    echo $newMacAddress
    if [ "$newMacAddress" != "$newMacAddress1" ];then
        #ifconfig ${local_tp1} hw ether ${oldMacAddress}
        MESSAGE="FAIL\t The wrong MAC address set fail "
        echo ${MESSAGE}
    else
        echo "PASS"
    fi
    ifconfig ${local_tp1} hw ether ${oldMacAddress}

}

function ge_set_linear_mac_address()
{
    Test_Case_Title="ge_set_linear_mac_address"
    ifconfig ${local_tp1} up; ifconfig ${local_tp1} ${local_tp1_ip}
    ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ifconfig ${remote_tp1} up; ifconfig ${remote_tp1} ${remote_tp1_ip}; sleep 5"
    MESSAGE="PASS"

    oldMacAddress=$(ifconfig ${local_tp1} | grep "HWaddr" | awk '{print $NF}')
    for linearMacAddress in "22:22:22:22:22:22" "aa:aa:aa:aa:aa:aa"
    do
        ifconfig ${local_tp1} hw ether ${linearMacAddress}
        sleep $ARP_MAC_UPDATE_TIME
        ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ping ${local_tp1_ip} -c 10;sleep 5"
        linearMacAddress1=$(ssh -o StrictHostKeyChecking=no root@${BACK_IP} "arp -a | grep -w ${local_tp1_ip} | awk -F'at' '{print \$NF}' | awk '{print \$1}'")
        if [ "$linearMacAddress" != "$linearMacAddress1" ];then
            #ifconfig ${local_tp1} hw ether ${oldMacAddress}
            MESSAGE="FAIL\t set linear mac address fail "
        fi
    done
    ifconfig ${local_tp1} hw ether ${oldMacAddress}

}



###### XGE Support to change MAC address ######
function xge_mac_address_random_generation()
{
    Test_Case_Title="xge_mac_address_random_generation"
    ifconfig ${local_fibre1} up; ifconfig ${local_fibre1} ${local_fibre1_ip}
    ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ifconfig ${remote_fibre1} up; ifconfig ${remote_fibre1} ${remote_fibre1_ip}; sleep 5;"

    MacAddress1=$(ifconfig ${local_tp1} | grep "HWaddr" | awk '{print $NF}' | tr -d ':')

    ifconfig ${local_fibre1} down;sleep 5
    MacAddress2=$(ifconfig ${local_tp1} | grep "HWaddr" | awk '{print $NF}' | tr -d ':')
    ifconfig ${local_fibre1} up
    if [ "$MacAddress1" = "$MacAddress2" ];then
        MESSAGE="PASS"
    else
        MESSAGE="FAIL\t MAC addresses cannot be generated randomly "
    fi
}

function xge_mac_address_fault_tolerant()
{
    Test_Case_Title="xge_mac_address_fault_tolerant"
    ifconfig ${local_fibre1} up; ifconfig ${local_fibre1} ${local_fibre1_ip}
    ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ifconfig ${remote_fibre1} up; ifconfig ${remote_fibre1} ${remote_fibre1_ip}; sleep 5;"
    xgemacvalue="1 3 5 7 9"
    MESSAGE="PASS"
    for i in $xgemacvalue
    do
        NewMacAddress="c$i:a8:01:83:00:04"
        #ifconfig ${local_fibre1} hw ether $NewMacAddress  | grep "SIOCSIFHWADDR: Cannot assign requested address"
        ifconfig ${local_fibre1} hw ether $NewMacAddress 2>/dev/null
        if [ $? -eq 0 ];then
            MESSAGE="FAIL\t The wrong MAC address has been configured  "
        fi
    done

    for x in "00:00:00:00:00:00" "ff:ff:ff:ff:ff:ff" "c1:a8:01:83:00:0418"
    do
        #ifconfig ${local_fibre1} hw ether $x 2>/dev/null | grep "SIOCSIFHWADDR: Cannot assign requested address"
        ifconfig ${local_fibre1} hw ether $x 2>/dev/null
        if [ $? -eq 0 ];then
            MESSAGE="FAIL\t The wrong MAC address has been configured  "
        fi
    done
}

function xge_set_standard_mac_address()
{
    Test_Case_Title="xge_set_standard_mac_address"
    ifconfig ${local_fibre1} up; ifconfig ${local_fibre1} ${local_fibre1_ip}
    ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ifconfig ${remote_fibre1} up; ifconfig ${remote_fibre1} ${remote_fibre1_ip}; sleep 5"
    MESSAGE="PASS"

    oldMacAddress=$(ifconfig ${local_fibre1} | grep "HWaddr" | awk '{print $NF}')
    # if [ ${oldMacAddress:15:2} = "44" ];then
        # newMacAddress=$(echo $oldMacAddress |sed s/"${oldMacAddress:15:2}"/"22"/g)
    # else
        # newMacAddress=$(echo $oldMacAddress |sed s/"${oldMacAddress:15:2}"/"44"/g)
    # fi
    Random_Mac=$((RANDOM%99))
    Random_Mac1=$((RANDOM%99))
    if [ ${Random_Mac} -lt 10 ]
    then
        Random_Mac="0"${Random_Mac}
    fi
    if [ ${Random_Mac1} -lt 10 ]
    then
        Random_Mac1="0"${Random_Mac}
    fi
    newMacAddress=$(echo $oldMacAddress |sed s/"${oldMacAddress:15:2}"/"${Random_Mac}"/g)
    remoteMacAddress=$(ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ifconfig ${local_fibre1} | grep "HWaddr"")
    remoteMacAddress=$(echo ${remoteMacAddress} | awk '{print $NF}')
    if [ "${newMacAddress}"x == "${remoteMacAddress}"x ]
    then
        newMacAddress=$(echo $oldMacAddress |sed s/"${oldMacAddress:15:2}"/"${Random_Mac1}"/g)
    fi
    ifconfig ${local_fibre1} hw ether ${newMacAddress}
    sleep $ARP_MAC_UPDATE_TIME
    ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ping ${local_fibre1_ip} -c 10;sleep 5"
    newMacAddress1=$(ssh -o StrictHostKeyChecking=no root@${BACK_IP} "arp -a | grep -w ${local_fibre1_ip}")
    newMacAddress1=$(echo ${newMacAddress1} | awk -F'at' '{print $NF}' | awk '{print $1}')

    if [ "$newMacAddress" != "$newMacAddress1" ];then
        ifconfig ${local_fibre1} hw ether ${oldMacAddress}
        MESSAGE="FAIL\t The wrong MAC address set fail "
        echo ${MESSAGE}
    else
        MESSAGE="PASS"
        echo ${MESSAGE}
    fi
}

function xge_set_linear_mac_address()
{
    Test_Case_Title="xge_set_linear_mac_address"
    ifconfig ${local_fibre1} up; ifconfig ${local_fibre1} ${local_fibre1_ip}
    ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ifconfig ${remote_fibre1} up; ifconfig ${remote_fibre1} ${remote_fibre1_ip}; sleep 5"
    MESSAGE="PASS"

    oldMacAddress=$(ifconfig ${local_fibre1} | grep "HWaddr" | awk '{print $NF}')
    for linearMacAddress in "22:22:22:22:22:22" "aa:aa:aa:aa:aa:aa"
    do
        ifconfig ${local_fibre1} hw ether ${linearMacAddress}
        sleep $ARP_MAC_UPDATE_TIME
        ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ping ${local_fibre1_ip} -c 10;sleep 5"
        linearMacAddress1=$(ssh -o StrictHostKeyChecking=no root@${BACK_IP} "arp -a | grep -w ${local_fibre1_ip} | awk -F'at' '{print \$NF}' | awk '{print \$1}'")

        if [ "$linearMacAddress" != "$linearMacAddress1" ];then
            ifconfig ${local_fibre1} hw ether ${oldMacAddress}
            MESSAGE="FAIL\t set linear mac address fail "
        fi
    done
}

function main()
{
    test_case_switch
}
main
