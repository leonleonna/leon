#!/bin/bash

# Env Set
#export LANG=zh_CN.utf-8
source .bash_profile
source /etc/rc.d/init.d/functions

# Var Set


# Show Start 
echo -e "\e[36m  +-----------------------------------+ \e[0m"
echo -e "\e[36m  |   Start initial system env  now   | \e[0m"
echo -e "\e[36m  |   Please Interaction start        | \e[0m"
echo -e "\e[36m  |   Version 1.0 Author leon         | \e[0m"
echo -e "\e[36m  +-----------------------------------+ \e[0m"

# Server status
function serverStatus(){
    if [[ $# -ne 2 ]];then 
        echo -e "\e[31m Insufficient parameters  \e[0m"
        exit
    fi
    systemctl $2 $1 &> /dev/null
    if [[ $? -eq 0 ]];then
	action "Server $1 $2: " /bin/true
    else
        action "Server $1 $2: " /bin/false
        read -n 1 -t 5 -ep "Installation required $1(y/n):" choise
	    if [[ ${choise} = 'y' ]];then 
		installServer $1
		serverStatus  $1 status
	    fi
    fi
}

# Set Network
function netSet(){
    echo -e "\e[36m  -->  Set network now \e[0m"
    netPath=/etc/sysconfig/network-scripts/ifcfg-
    getWay=`ip r s | egrep default |awk '{print $3}'`
    ipAdd=`ip a | grep 'inet 192' | awk '{print $2}'`
    echo " GW:${getWay}  IP:${ipAdd}"
    read -n 1 -ep 'Use Message Set Static model？(y/n): ' confirm
    if [[ ${confirm} = 'y' ]];then
        read -t 5 -ep 'Please input your netName？[ens32]: ' netName
	    netName=${netName:-ens32}
            netPath=${netPath}${netName}
    	    while true
	    do
                read -n 17 -ep "Please Input Your Address[${ipAdd}]: " ipNet
                ipNet=${ipNet:-${ipAdd}}
                read -n 17 -ep "Please Input Your GateWay[${getWay}]: " gwNet
                gwNet=${gwNet:-${getWay}}
                read -n 1 -ep "Ipaddress:${ipNet} GateWay:${gwNet} (y/n): " confirmNet
	    	if [[ ${confirmNet} = 'y' ]];then
			    IPA=`ip a | grep 'inet 192' | awk '{print $2}' |awk -F '/' '{print $1}'`
			    PRI=`ip a | grep 'inet 192' | awk '{print $2}' |awk -F '/' '{print $2}'`
			    read -n 17 -ep "Please input your DNS[8.8.8.8]: " confirmDns
				confirmDns=${confirmDns:-'8.8.8.8'}
	    	            echo "DEVICE="${netName}"" > ${netPath}
	    		    echo 'ONBOOT="yes"' >> ${netPath}
	    	 	    echo 'BOOTPROTO=none' >> ${netPath}
			    echo "IPADDR=${IPA}" >> ${netPath}
			    echo "GATEWAY=${getWay}" >> ${netPath}
			    echo "PRIFIX=${PRI}" >> ${netPath}
			    echo "DNS1=${confirmDns}" >> ${netPath}
			    serverStatus network restart
			    break
	    	fi
            done
    else
        echo -e "\e[36m  If you want to make service suggestions, modify the static mode of the network! \e[0m"
    fi
}

# Install Server
function installServer(){
    if [[ $# -eq 1 ]] &&  [[ $1 != 'ceph' ]] && [[ $1 != 'redis'  ]];then 
        if [[ -e /etc/yum.repos.d/163.repo ]] && [[ -f /etc/yum.repos.d/163.repo ]];then
            yum -y install $1 &> /dev/null
            serverStatus $1 restart
        else   
            curl http://mirrors.163.com/.help/CentOS7-Base-163.repo > /etc/yum.repos.d/163.repo
            yum clean all && yum makecache
            yum -y install $1 &> /dev/null
            serverStatus $1 restart
        fi
    elif [[ $# -ne 1 ]];then
        echo 'Input Args too many!'
    else
        echo -e "\e[36m  Install $1 now! \e[0m"
    fi
}

installServer redis

















netSet
