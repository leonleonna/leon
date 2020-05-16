#!/bin/bash

echo -e "\e[1;36m-->  Change Your hostname!\e[0m"
while true
    read -p 'Please input your hostname:' hn
do 
    if [[ ${hn} != ''  ]];then
       hostnamectl set-hostname ${hn}
       echo 'Now Hostname:' $HOSTNAME
       echo 'Need exit then continued!'
       break
    else
       echo "Please check input! Don't null!"
    fi
done


read -p 'Need to change network static?(y/n)' choise
if [[ ${choise} = 'y' ]];then
  echo -e "\e[1;36m-->  Change Your network model is static!\e[0m"
  gw=`ip r s| grep via| awk '{print $3}'`
  ns=`ip r s| grep '24'| awk '{print $1}'`
  ip=`ip r s| grep '24'| awk '{print $9}'`
  echo "GW-> ${gw}| NS-> ${ns} | IP-> ${ip}"
  read -p 'Message is OK?(y/n) ' choise2
    if [[ ${choise2} = 'y' ]];then 
        netpath=/etc/sysconfig/network-scripts/ifcfg-ens32
        echo 'DEVICE="ens32"' > ${netpath}
	echo 'ONBOOT="yes"' >> ${netpath}
        echo 'BOOTPROTO=none' >> ${netpath}
        echo "IPADDR=${ip}" >> ${netpath}
        echo "GATEWAY=${gw}" >> ${netpath}
        echo 'PRIFIX=24' >> ${netpath}
        echo "DNS1=${gw}" >> ${netpath}
        systemctl restart network
	ip a |grep 'inet ' && ping -c 1 www.baidu.com
    else
        echo 'if your want set network,please once again'
    fi
fi
        
echo -e "\e[1;36m-->  Change Your Hosts!\e[0m"
echo "127.0.0.1 ${hn}" > /etc/hosts

exit
