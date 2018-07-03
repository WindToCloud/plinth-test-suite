#!/bin/bash

#IN :N/A
#OUT:N/A
function event_counts_judge()
{
    :> ${PERF_TOP_DIR}/data/log/event_judge.txt
    cat ${PERF_TOP_DIR}/data/log/counts.txt | while read mycount
    do
        if [ -n "$(echo $mycount | sed -n "/^[0-9]\+$/p")" ];then 
            if [ $mycount -ge 0 -a $mycount -le 65535 ];then
                echo "$mycount is normal"
                echo 1 > ${PERF_TOP_DIR}/data/log/event_judge.txt
            else
                echo "$mycount : the count is abmormal"
                echo 0 > ${PERF_TOP_DIR}/data/log/event_judge.txt
                break
            fi
        else 
            echo "$mycount : the count is not number!"
            echo 0 > ${PERF_TOP_DIR}/data/log/event_judge.txt
            break
        fi
    done
    if [ `cat ${PERF_TOP_DIR}/data/log/event_judge.txt | grep 0 | wc -l` -eq 0 ];then
        return 1
    else
        return 0
    fi
}

#IN :N/A
#OUT:N/A
function perf_2P_support_function_test()
{
    echo ${Test_Case_Title}
    :> ${PERF_TOP_DIR}/data/log/2P_flag.txt
    perf list | grep $1| awk -F'[ \t]+' '{print $2}' > ${PERF_TOP_DIR}/data/log/pmu_event.txt
    msum=$(cat ${PERF_TOP_DIR}/data/log/pmu_event.txt | grep $1 | wc -l)
    if [ $msum -le 0 ];then
        MESSAGE="Fail\t No $1 Perf Support Event!"
        break
    else
        for i in ${L3C_PERF_EVENT[@]}; do
            sum=`cat ${PERF_TOP_DIR}/data/log/pmu_event.txt | grep write_hit/ | wc -l`
            rand=$(($RANDOM%$sum+1 ))
            case=`cat ${PERF_TOP_DIR}/data/log/pmu_event.txt | grep write_hit/ | sed -n $rand\p`
            perf stat -a -C $MASTER_CPU -A -e $case -I 200 sleep 1s >& ${PERF_TOP_DIR}/data/log/perf_statu.log
            cat ${PERF_TOP_DIR}/data/log/perf_statu.log | awk -F '[ \t]+'  '{print $4}' | sed 's/counts//g' | grep -v "^$" > ${PERF_TOP_DIR}/data/log/counts.txt
            cat ${PERF_TOP_DIR}/data/log/perf_statu.log | awk -F '[ \t]+'  '{print $3}' | sed 's/CPU//g' | grep -v "^$" > ${PERF_TOP_DIR}/data/log/cpu.txt
            event_counts_judge
            if [ $? -eq 1 ];then
                echo 1 > ${PERF_TOP_DIR}/data/log/2P_flag.txt
            else
                echo 0 > ${PERF_TOP_DIR}/data/log/2P_flag.txt
                echo $i fail
                break
            fi
            perf stat -a -C $SLAVE_CPU -A -e $case -I 200 sleep 1s >& ${PERF_TOP_DIR}/data/log/perf_statu.log
            cat ${PERF_TOP_DIR}/data/log/perf_statu.log | awk -F '[ \t]+'  '{print $4}' | sed 's/counts//g' | grep -v "^$" > ${PERF_TOP_DIR}/data/log/counts.txt
            cat ${PERF_TOP_DIR}/data/log/perf_statu.log | awk -F '[ \t]+'  '{print $3}' | sed 's/CPU//g' | grep -v "^$" > ${PERF_TOP_DIR}/data/log/cpu.txt
            event_counts_judge
            if [ $? -eq 1 ];then
                echo 1 > ${PERF_TOP_DIR}/data/log/2P_flag.txt
            else
                echo 0 > ${PERF_TOP_DIR}/data/log/2P_flag.txt
                echo $i fail
                break
            fi
        done
        if [ `cat ${PERF_TOP_DIR}/data/log/2P_flag.txt | grep "0" | wc -l` -le 0 ];then
            MESSAGE="Pass"
            echo ${MESSAGE}
        else
            MESSAGE="Fail\t No $1 Perf 2P Support Event!"
        fi
    fi
}

function l3c_perf_2P_support()
{
    Test_Case_Title="L3C perf 2P support function test"
  
    perf_2P_support_function_test l3c 
}

function ddrc_perf_2P_support()
{
    Test_Case_Title="DDRC perf 2P support function test"
  
    perf_2P_support_function_test ddrc 
}

function hha_perf_2P_support()
{
    Test_Case_Title="HHA perf 2P support function test"
  
    perf_2P_support_function_test hha 
}

function main()
{
    test_case_function_run
}

main
