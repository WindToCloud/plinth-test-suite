#!/bin/bash

# support_of_mtu_setting
# IN :N/A
# OUT:N/A

function ge_set_mtu_value()
{
    Test_Case_Title="ge_set_mtu_value"
    echo ${Test_Case_Title}
    valuelist="68 1500 1501 9706"
    MESSAGE="PASS"

    for value in $valuelist
    do
        echo $value
        ifconfig ${local_tp1} mtu $value
        NewMtuValue=$(ifconfig ${local_tp1} | grep "MTU" | awk '{print $(NF-1)}' | awk -F':' '{print $NF}')
        if [ $value -ne $NewMtuValue ];then
            MESSAGE="FAIL\t MTU value set fail "
	    echo ${MESSAGE}
        fi
    done
    #MESSAGE="PASS"
    echo ${MESSAGE}
}

function ge_set_fail_mtu_value()
{
    Test_Case_Title="ge_set_fail_mtu_value"
    echo ${Test_Case_Title}
    MESSAGE="PASS"

    valuelist="67 9707"
    for value in $valuelist
    do
        echo $value
        ifconfig ${local_tp1} mtu $value 2>/dev/null
        if [ $? -ne 1 ];then
            MESSAGE="FAIL\t MTU Incoming error parameters set fail "
	    echo ${MESSAGE}
        fi
    done
    #MESSAGE="PASS"
    echo $MESSAGE
}

function ge_iperf_set_mtu_value()
{
    Test_Case_Title="ge_iperf_set_mtu_value"
    echo ${Test_Case_Title}
    #MESSAGE="PASS"
    iperf_killer
    ifconfig ${local_tp1} up; ifconfig ${local_tp1} ${local_tp1_ip}
    #??iperf????
    determine_iperf_exists
    if [ $? -eq 1 ];then
        MESSAGE="FAIL\t Iperf tools are not installed "
	echo ${MESSAGE}
        return 1
    fi
    MESSAGE="PASS"
    ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ifconfig ${remote_tp1} up; ifconfig ${remote_tp1} ${remote_tp1_ip}; sleep 5;iperf -s >/dev/null 2>&1 &"
    iperf -c ${remote_tp1_ip} -t 3600 -i 1 -P 3 > ${BaseDir}/log/iperf_set_mtu_value.txt &
    sleep 3
    valuelist="68 1500 9706"
    for ((i=1;i<=20;i++));
    do
        echo $i
        for value in $valuelist
        do
            ifconfig ${local_tp1} mtu $value;sleep 10
            NewMtuValue=$(ifconfig ${local_tp1} | grep "MTU" | awk '{print $(NF-1)}' | awk -F':' '{print $NF}')
            bandwidth=$(cat ${BaseDir}/log/iperf_set_mtu_value.txt | tail -1 | awk '{print $(NF-1)}')
            tmp=`awk -v a=$bandwidth -v b=0 'BEGIN{print(a>b)?"0":"1"}'`
            if [ $value -ne $NewMtuValue ] || [ $tmp -ne 0 ];then
                killall iperf
                ssh -o StrictHostKeyChecking=no root@${BACK_IP} "killall iperf"
                MESSAGE="FAIL\t ge Runing iperf, MTU value set fail "
                break
	#	echo ${MESSAGE}
            fi
        done
        if [ x"$MESSAGE" = x"PASS" ];then
            echo "continue to run...."
        else
            break
        fi

    done
    #killall iperf
    iperf_killer
    #ssh -o StrictHostKeyChecking=no root@${BACK_IP} "killall iperf"
    #MESSAGE="PASS"
    echo ${MESSAGE}
}


###### XGE support_of_mtu_setting ######
function xge_set_mtu_value()
{
    Test_Case_Title="xge_set_mtu_value"
    MESSAGE="PASS"

    echo ${Test_Case_Title}
    valuelist="68 1500 1501 9706"
    for value in $valuelist
    do
        echo $value
        ifconfig ${local_fibre1} mtu $value
        NewMtuValue=$(ifconfig ${local_fibre1} | grep "MTU" | awk '{print $(NF-1)}' | awk -F':' '{print $NF}')
        if [ $value -ne $NewMtuValue ];then
            MESSAGE="FAIL\t MTU value set fail "
	    echo ${MESSAGE}
        fi
    done
    #MESSAGE="PASS"
    echo ${MESSAGE}
}

function xge_set_fail_mtu_value()
{
    Test_Case_Title="xge_set_fail_mtu_value"
    valuelist="67 9707"
    MESSAGE="PASS"

    for value in $valuelist
    do
        #echo $value
        ifconfig ${local_fibre1} mtu $value 2>/dev/null
        if [ $? -ne 1 ];then
            MESSAGE="FAIL\t MTU Incoming error parameters set fail "
        fi
    done
    #MESSAGE="PASS"
}

function xge_iperf_set_mtu_value()
{
    Test_Case_Title="xge_iperf_set_mtu_value"
    ifconfig ${local_fibre1} up; ifconfig ${local_fibre1} ${local_fibre1_ip}
    MESSAGE="PASS"
    iperf_killer
    #??iperf????
    determine_iperf_exists
    if [ $? -eq 1 ];then
        MESSAGE="FAIL\t Iperf tools are not installed "
        return 1
    fi
    ssh -o StrictHostKeyChecking=no root@${BACK_IP} "ifconfig ${remote_fibre1} up; ifconfig ${remote_fibre1} ${remote_fibre1_ip}; sleep 5;iperf -s >/dev/null 2>&1 &"
    iperf -c ${remote_fibre1_ip} -t 3600 -i 1 -P 3 > ${BaseDir}/log/iperf_set_mtu_value.txt &
    sleep 3
    valuelist="68 1500 9706"
    for ((i=1;i<=20;i++));
    do
	echo $i
        for value in $valuelist
        do
            echo $i
            echo $value
            ifconfig ${local_fibre1} mtu $value;sleep 10
            NewMtuValue=$(ifconfig ${local_fibre1} | grep "MTU" | awk '{print $(NF-1)}' | awk -F':' '{print $NF}')
            bandwidth=$(cat ${BaseDir}/log/iperf_set_mtu_value.txt | tail -1 | awk '{print $(NF-1)}')
            tmp=`awk -v a=$bandwidth -v b=0 'BEGIN{print(a>b)?"0":"1"}'`

            if [ $value -ne $NewMtuValue ] || [ $tmp -ne 0 ];then
                killall iperf
                ssh -o StrictHostKeyChecking=no root@${BACK_IP} "killall iperf"
                MESSAGE="FAIL\t xge Runing iperf, MTU value set fail "
                break
            fi
        done
        if [ x"$MESSAGE" = x"PASS" ];then
            echo "continue to run...."
        else
            break
        fi
    done
   # killall iperf
    iperf_killer
    #ssh -o StrictHostKeyChecking=no root@${BACK_IP} "killall iperf"
    #MESSAGE="PASS"
}

function main()
{
    test_case_switch
}
main
