#!/bin/bash


# config eth0-eth3 ip/mac
# keep the remote diff
# find eth0 ~` eth3 renamed
# -----------start chenjing-------------
declare -A eth_map
declare -A eth_map_ip
eth_map=(
["eth0"]="eth0"
["eth1"]="eth1"
["eth2"]="eth2"
["eth3"]="eth3"
)
eth_map_ip=(
["eth0"]="192.168.11.110"
["eth1"]="192.168.12.120"
["eth2"]="192.168.13.130"
["eth3"]="192.168.50.66"
)
eth3_mac="12:34:56:78:90:22"
#we update the eth rename info to eth_map,then update TP/FIBRE info
ifconfig ${eth_map["eth3"]} ${eth_map_ip["eth3"]}; ifconfig ${eth_map["eth3"]} up

for i in ${!eth_map[*]}
do
    tmp=`dmesg | grep -i "renamed from "${i} -w`
    if [ x"${tmp}" != x"" ]
    then
        tmp=`echo ${tmp%:*}`
        tmp=`echo ${tmp##* }`
        eth_map[${i}]=${tmp}
        # echo "The name of "${i}" is renamed as "${eth_map[${i}]}
    fi
    random_mac=$((RANDOM%99))
    random_mac1=$((RANDOM%99))
    local_mac="12:34:56:78:${random_mac1}:${random_mac}"
    ifconfig ${eth_map[${i}]} hw ether ${local_mac}
done

route add default gw 192.168.50.1

---------end chenjing-------------------
