#!/bin/bash
#!/bin/athena/bash

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
function fun_perf_list()
{
    :> ${PERF_TOP_DIR}/data/log/pmu_event.txt
    :> ${PERF_TOP_DIR}/data/log/test_flag.txt
    trap - INT
    perf list | grep $1| awk -F'[ \t]+' '{print $2}' > ${PERF_TOP_DIR}/data/log/pmu_event.txt
    msum=$(cat ${PERF_TOP_DIR}/data/log/pmu_event.txt | grep $1 | wc -l) 
    if [[ $msum -le 0 ]];then
        MESSAGE="Fail\t No $1 Perf Support Event!"
        return 0
    else 
        cat ${PERF_TOP_DIR}/data/log/pmu_event.txt | while read myline
        do
            :> ${PERF_TOP_DIR}/data/log/perf_statu.log
            :> ${PERF_TOP_DIR}/data/log/counts.txt
            echo $myline
            perf stat -a -A -e $myline -I 200 sleep 1s >& ${PERF_TOP_DIR}/data/log/perf_statu.log
            cat ${PERF_TOP_DIR}/data/log/perf_statu.log | awk -F '[ \t]+'  '{print $4}' | sed 's/counts//g' | grep -v "^$" > ${PERF_TOP_DIR}/data/log/counts.txt
            sleep 1
            event_counts_judge
            if [ $? -eq 1 ];then 
      	        echo 1 >> ${PERF_TOP_DIR}/data/log/test_flag.txt
      	        echo pass
      	        # break
            else
                echo 0 >> ${PERF_TOP_DIR}/data/log/test_flag.txt
                echo fail
                MESSAGE="Fail\t $1 Event Run Error!"	
                break
            fi
        done
        if [ `cat ${PERF_TOP_DIR}/data/log/test_flag.txt | grep "0" | wc -l` -le 0 ];then
            MESSAGE="Pass"
        fi
    fi
}

function l3c_perf_stat_function()
{
    Test_Case_Title="L3C perf stat function test"

    fun_perf_list l3c
}

function ddrc_perf_stat_function()
{
    Test_Case_Title="DDRC perf stat function test"

    fun_perf_list ddrc
}

function hha_perf_stat_function()
{
    Test_Case_Title="HHA perf stat function test"

    fun_perf_list hha
}

function mn_perf_stat_function()
{
    Test_Case_Title="MN perf stat function test"

    fun_perf_list mn
}

function main()
{
    test_case_function_run
}

main
