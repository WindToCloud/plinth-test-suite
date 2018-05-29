#!/bin/bash

#this file is test socket back


function roce_v1_tp_send() {
    Title="Begin to test roce_v1_tp_send"
    echo ${Title}
    clear_send_read_write_envir
    ifconfig ${local_tp} ${local_tp_ip}; ifconfig ${local_tp} up
    sleep 3
    ib_send_bw -d ${tp_name} -x 2 -i 1 -c RC &
    sleep 2
    ib_send_bw -d ${tp_name} -x 2 -i 1 -c RC ${local_tp_ip} | grep "65536"
    if [ $? -eq 0 ]
    then
        MESSAGE="PASS"
    else
        echo "FAIL"
    fi
}


function roce_v2_tp_send() {
    Title="Begin to test roce_v2_tp_send"
    echo ${Title}
    clear_send_read_write_envir
    ifconfig ${local_tp} ${local_tp_ip}; ifconfig ${local_tp} up
    sleep 3
    ib_send_bw -d ${tp_name} -x 3 -i 1 -c RC &
    sleep 2
    ib_send_bw -d ${tp_name} -x 3 -i 1 -c RC ${local_tp_ip} | grep "65536"
    if [ $? -eq 0 ]
    then
        MESSAGE="PASS"
    else
        echo "FAIL"
    fi

    Title="Begin to test roce_v2_tp_ipv6_send"
    echo ${Title}
    clear_send_read_write_envir
    ifconfig ${local_tp} ${local_tp_ip}; ifconfig ${local_tp} up
    sleep 3
    ib_send_bw -d ${tp_name} -x 1 -i 1 -c RC &
    sleep 2
    ib_send_bw -d ${tp_name} -x 1 -i 1 -c RC ${local_tp_ip} | grep "65536"
    if [ $? -eq 0 ]
    then
        MESSAGE="PASS"
    else
        echo "FAIL"
    fi

}


function roce_v1_tp_read() {
    Title="Begin to test roce_v1_tp_read"
    echo ${Title}
    clear_send_read_write_envir
    ifconfig ${local_tp} ${local_tp_ip}; ifconfig ${local_tp} up
    sleep 3
    ib_read_bw -d ${tp_name} -x 2 -i 1 -a -c RC &
    sleep 2
    ib_read_bw -d ${tp_name} -x 2 -i 1 -a -c RC ${local_tp_ip} | grep "65536"
    if [ $? -eq 0 ]
    then
        MESSAGE="PASS"
    else
        echo "FAIL"
    fi

}


function roce_v2_tp_read() {
    Title="Begin to test roce_v2_tp_read"
    echo ${Title}
    clear_send_read_write_envir
    ifconfig ${local_tp} ${local_tp_ip}; ifconfig ${local_tp} up
    sleep 3
    ib_read_bw -d ${tp_name} -x 3 -i 1 -c RC &
    sleep 2
    ib_read_bw -d ${tp_name} -x 3 -i 1 -c RC ${local_tp_ip} | grep "65536"
    if [ $? -eq 0 ]
    then
        MESSAGE="PASS"
    else
        echo "FAIL"
    fi

    Title="Begin to test roce_v2_tp_ipv6_read"
    echo ${Title}
    clear_send_read_write_envir
    ifconfig ${local_tp} ${local_tp_ip}; ifconfig ${local_tp} up
    sleep 3
    ib_read_bw -d ${tp_name} -x 1 -i 1 -c RC &
    sleep 2
    ib_read_bw -d ${tp_name} -x 1 -i 1 -c RC ${local_tp_ip} | grep "65536"
    if [ $? -eq 0 ]
    then
        MESSAGE="PASS"
    else
        echo "FAIL"
    fi

}


function roce_v1_tp_write() {
    Title="Begin to test roce_v1_tp_write"
    echo ${Title}
    clear_send_read_write_envir
    ifconfig ${local_tp} ${local_tp_ip}; ifconfig ${local_tp} up
    sleep 3
    ib_write_bw -d ${tp_name} -x 2 -i 1 -c RC &
    sleep 2
    ib_write_bw -d ${tp_name} -x 2 -i 1 -c RC ${local_tp_ip} | grep "65536"
    if [ $? -eq 0 ]
    then
        MESSAGE="PASS"
    else
        echo "FAIL"
    fi

}


function roce_v2_tp_write() {
    Title="Begin to test roce_v2_tp_write"
    echo ${Title}
    clear_send_read_write_envir
    ifconfig ${local_tp} ${local_tp_ip}; ifconfig ${local_tp} up
    sleep 3
    ib_write_bw -d ${tp_name} -x 3 -i 1 -c RC &
    sleep 2
    ib_write_bw -d ${tp_name} -x 3 -i 1 -c RC ${local_tp_ip} | grep "65536"
    if [ $? -eq 0 ]
    then
        MESSAGE="PASS"
    else
        echo "FAIL"
    fi

    Title="Begin to test roce_v2_tp_ipv6_write"
    echo ${Title}
    clear_send_read_write_envir
    ifconfig ${local_tp} ${local_tp_ip}; ifconfig ${local_tp} up
    sleep 3
    ib_write_bw -d ${tp_name} -x 1 -i 1 -c RC &
    sleep 2
    ib_write_bw -d ${tp_name} -x 1 -i 1 -c RC ${local_tp_ip} | grep "65536"
    if [ $? -eq 0 ]
    then
        MESSAGE="PASS"
    else
        echo "FAIL"
    fi

}

function main()
{
    test_case_function_run
}

main
