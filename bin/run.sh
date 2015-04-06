#!/bin/bash

# 检查是否是root用户执行 
sudo=""
if [ $(id -u) != "0" ]; then
sudo="sudo";
echo -n "请输入运行密码:";
fi
#echo "请输入运行密码:"
$sudo bash /root/gsm/bin/gsm.sh
#bash /root/gsm/bin/gsm.sh
