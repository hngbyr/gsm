#!/bin/bash
CONFIG="$HOME/.ini/config.ini";
if [ ! -f $CONFIG ];then
zenity --info --text="错误代码0x05" --title="配置文件错误";
    echo "error code 0x05,Please contact the system administrator!";
    exit 1;
fi
GSMPATH=`cat "$CONFIG" | grep '^GSMPATH=' | cut -d '=' -f 2`;
GSMAPPATH=`cat "$CONFIG" | grep '^GSMAPATH=' | cut -d '=' -f 2`;
GSMNUM=`cat "$CONFIG" | grep '^GSMNUM=' | cut -d '=' -f 2`;
MOBILE=`cat "$CONFIG" | grep '^MOBILE=' | cut -d '=' -f 2`;
GSMDEFSESSION=`cat "$CONFIG" | grep '^GSMDEFSESSION=' | cut -d '=' -f 2`;
GSMSESSION=`cat "$CONFIG" | grep '^GSMSESSION=' | cut -d '=' -f 2`;
GSMBRMBORACTL=`cat "$CONFIG" | grep '^GSMBRMBORACTL=' | cut -d '=' -f 2`;
network_name=`cat "$CONFIG" | grep '^GSMLOCALHOST=' | cut -d '=' -f 2`;
GSMKRAKENHOST=`cat "$CONFIG" | grep '^GSMKRAKENHOST=' | cut -d '=' -f 2`;
GSMNAPALMEXCOCODE=`cat "$CONFIG" | grep '^GSMNAPALMEXCOCODE=' | cut -d '=' -f 2`;
phone=`cat "$CONFIG" | grep '^MOBILE=' | cut -d '=' -f 2`;
GSMPACHER=`cat "$CONFIG" | wc -l`;
num=`lsusb |grep FT232 | wc -l`;
# 检查配置文件
if [ "$num" = "0" ];then
	zenity --warning --text="没有发现硬件[Error code:0x0e]" --title="AC-GSM 0x0e" --ok-label="退出";
exit
fi
if [ "$GSMNAPALMEXCOCODE" -ne "$GSMPACHER" ];then
	zenity --error --text="非注册用户(error code 0x0f)" --title="请注册" --ok-label="关闭";
	echo "error code 0x0f";
	exit 1;
fi
if [ -z "$GSMBRMBORACTL" ]; then
	if [ $num -le 3 ];then ##lt< le<= eg=
	GSMNUM=$num;
	else
	GSMNUM=3;
	fi
fi


if [ ! -d $GSMSESSION ];then
	mkdir -p $GSMSESSION ;
fi
sudo=""
# 检查是否是root用户执行 
if [ $(id -u) != "0" ]; then
#zenity --error --text="非ROOT用户：[Error code:0x00]" --title="非ROOT用户" --ok-label="退出";
#    echo -e "Error code 0x00: Run this script using the root user！\nUsage:sudo bash $0";
#    exit 1;
sudo="sudo";
fi
# 清理运行环境
killall ccch_scan cell_log osmocon 2>/dev/null;
cd $GSMSESSION && rm -rf *.dat;

#echo $GSMAPPATH
#sleep 5
# 检查osmocombb程序
if [ ! -f $GSMAPPATH/osmocon ];then
	zenity --error --text="错误代码[Error code:0x01]" --title="AC-GSM 程序错误" --ok-label="退出";
	echo "error code 0x01,Please contact the system administrator!";
    exit 1
elif [ ! -f $GSMAPPATH/layer1.compalram.bin ];then
	zenity --error --text="错误代码[Error code:0x02]" --title="AC-GSM 程序错误" --ok-label="退出";
    echo "error code 0x02,Please contact the system administrator!";
    exit 1;
elif [ ! -f $GSMAPPATH/cell_log ];then
	zenity --error --text="错误代码[Error code:0x03]" --title="AC-GSM 程序错误" --ok-label="退出";
    echo "error code 0x03,Please contact the system administrator!";
    exit 1;
elif [ ! -f $GSMAPPATH/ccch_scan ];then
	zenity --error --text="错误代码[Error code:0x04]" --title="AC-GSM 程序错误" --ok-label="退出";
    echo "error code 0x04,Please contact the system administrator!";
    exit 1
fi
echo 
#echo 程序路径为:$GSMAPPATH

echo "[-]你是[ $GSMNUM ]信道用户，检测到通道数量:[ $num ] ";
echo "[-]你是[ $GSMNUM ]信道用户!";
i=0
echo
Cell_log()
{
#	echo "DBG: $GSMAPPATH/cell_log -s /tmp/osmocom_l2_$i -l - 2>&1 | bash $GSMPATH/cell_log.sh $cell_num | tee "$GSMSESSION"/scan.current";
	$sudo $GSMAPPATH/cell_log -s /tmp/osmocom_l2_$i -l - 2>&1 | bash $GSMPATH/cell_log.sh $cell_num | tee "$GSMSESSION"/scan.current
echo "PID: $$"
}

while [ $i -lt $GSMNUM ];do
	serial="/dev/ttyUSB$i";
	echo "[*]开始对第【$((i+1))/$GSMNUM 】信道启动和设置------------";
	echo "[*]加载信道【$((i+1)) 】固件,打开电源按红色按钮...";
#	echo "DBG: $GSMPATH/motoload.sh $phone $serial  /tmp/osmocom_l2_$i /tmp/osmocom_loader_$i";
	$sudo $GSMPATH/motoload.sh $phone $serial /tmp/osmocom_l2_$i /tmp/osmocom_loader_$i > /tmp/log_l1_$$_$i 2>&1 &
	echo "PID: $$"
#	xterm -T "AC-GSM Channel [ $((i+1)) ] Data Windows" -e "$GSMAPPATH"/osmocon -m c123xor -s "$GSMDEFSESSION"/osmocom_l2_$((i+1)) -l "$GSMDEFSESSION"/osmocom_loader_$((i+1)) -p /dev/ttyUSB"$i" "$GSMAPPATH"/layer1.compalram.bin &
	ifconfig $network_name:$((i+1)) down 2>/dev/null
	ifconfig $network_name:$((i+1)) $GSMKRAKENHOST$((i+1))
	if [ "$i" -eq 0 ]; then # backwards compatibility
		rm -f /tmp/osmocom_l2;
		ln -s /tmp/osmocom_l2_0 /tmp/osmocom_l2;
		rm -f /tmp/osmocom_loader;
		ln -s /tmp/osmocom_loader_0 /tmp/osmocom_loader;
	fi
	read -p "[*]信道启动完成?(Y/N)";
	if [ -z $arfcn_num ] ;then
		read -p "[!]是否需要扫描频段Arfcn[默认回车:是]:" abc
		if [ -z $abc ];then
			if [ -z $arfcn_num ];then
			read -p "[!]输入扫描频段显示数量[默认回车:all]:" cell_num;
				if [ X"$cell_num" == X"" ];then
				cell_numl=""
				fi
			fi
		Cell_log
		fi
	fi
#		xterm -T "AC-GSM Channel [ $((i+1)) ] Cell Windows" -e $GSMAPPATH/cell_log -s $GSMDEFSESSION/osmocom_l2_$((i+1)) 2>/dev/null &
	#sleep 1;
#	if [ ! -z "${array[@]:0}" ] ;then
#	echo "已经扫描的频段ARFCN: ${array[@]:0} "
#	fi
	read -p "[*]请输入频段ARFCN：" arfcn_num;
#echo `stty -F /dev/ttyUSB0`
	echo -e '\n';
	array[i]="$arfcn_num ";
#echo "DBG:xterm -T "AC-GSM Channel [ $((i+1)) ] Scan Windows" -e "$GSMAPPATH"/ccch_scan -s "$GSMDEFSESSION"/osmocom_l2_$i -i "$GSMKRAKENHOST""$((i+1))" -a "$arfcn_num" "
	$sudo xterm -T "AC-GSM Channel [ $((i+1)) ] Scan Windows" -e "$GSMAPPATH"/ccch_scan -s "$GSMDEFSESSION"/osmocom_l2_$i -i "$GSMKRAKENHOST""$((i+1))" -a "$arfcn_num" &
	i=$((i+1));
#echo `stty -F /dev/ttyUSB0`
sleep 1
arfcn_num=""
done
read -p "[!]是否窗口显示[默认回车:是]:" YN
	if [ X"$YN" == X"" ];then
	sudo $GSMPATH/wireshark.sh &
	fi
clear
#time=`echo `date +%Y/%m/%d` `date +%H:%M``;
LOGFILE=`date +%m%d%H%M`;

echo "........................................";
#echo 程序路径为:$GSMAPPATH
echo "[+]信道数量:$GSMNUM";
echo [*]开始时间：`date +%Y/%m/%d` `date +%H:%M`;
#echo "[*]开始时间：$time";
echo "[*]ARFCN : ${array[@]:0}";
echo "[-]Press 'Ctrl+C' 关闭全部程序!.";
echo "[*]收到的信息稍后会显示在下面，并有铃声提醒.";
echo "........................................";
$sudo bash "$GSMPATH"/show.sh | tee "$GSMAPPATH"/"$LOGFILE".current;
rm -rf $GSMDEFSESSION/osmocom* $GSMSESSION;
#sudo $GSMPATH/wireshark.sh
read IGNORE
