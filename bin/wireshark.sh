#!/bin/bash
CONFIG="$HOME/.ini/config.ini";
if [ ! -f $CONFIG ];then
zenity --info --text="错误代码0x05" --title="配置文件错误";
    echo "error code 0x05,Please contact the system administrator!";
    exit 1;
fi
WPATH=`cat "$CONFIG" | grep '^WHIRESHARK=' | cut -d '=' -f 2`;
sudo=""
if [ $(id -u) != "0" ]; then
sudo="sudo";
echo -n "请输入运行密码:";
fi
$sudo iptables -A INPUT -p UDP --dport 4729 -j DROP && $sudo $WPATH/wireshark -k -i lo -f 'port 4729'
