#!/bin/bash
#sudo /home/gsm/wireshark-master/tshark -l $options -R gsm_sms -T fields -e gsmtap.uplink -e gsm_sms.tp-oa -e gsm_sms.tp-da -e gsm_sms.sms_text -e gsmtap.arfcn -e frame.time -e gsm_a.dtap.cld_party_bcd_num
# $1 - input file, if empty
CONFIG="$HOME/.ini/config.ini";
if [ ! -f $CONFIG ];then
zenity --info --text="错误代码0x05" --title="配置文件错误";
    echo "error code 0x05,Please contact the system administrator!";
    exit 1;
fi
TSHPATH=`cat "$CONFIG" | grep '^WHIRESHARK=' | cut -d '=' -f 2`;
GSMPATH=`cat "$CONFIG" | grep '^GSMPATH=' | cut -d '=' -f 2`;
nu=1
if [ ! -z "$1" ]; then
	options="-r $1";
#	sudo="";
else
	options="-i lo";
#	sudo="sudo";	#ble
fi

# -e gsm_a.cld_party_bcd_num 
# this seems to be addr of sms gateway... not interesting with downlink
sudo=""
# 检查是否是root用户执行 
if [ $(id -u) != "0" ]; then
sudo="sudo";
fi
$sudo $TSHPATH/tshark -l $options -R gsm_sms -T fields \
 -e gsmtap.uplink -e gsm_sms.tp-oa -e gsm_sms.tp-da\
 -e gsm_sms.sms_text\
 -e gsmtap.arfcn -e frame.time -e gsm_a.dtap.cld_party_bcd_num 2>/dev/null \
| while read -r i; do
	link=`echo "$i" | cut -c 1`;
	from=`echo "$i" | cut -d '	' -f 2`;
	to=`echo "$i" | cut -d '	' -f 3`;
	text=`echo "$i" | cut -d '	' -f 4`;
	arfcn=`echo "$i" | cut -d '	' -f 5`;
	time_=`echo "$i" | cut -d '	' -f 6 | cut -c 14-22`;
	dtap=`echo "$i" | cut -d '	' -f 7`;
	if [ "$link" == 1 ]; then
		link='U';
	else
		link='D';
	fi
	if [ "$text" == "" ]; then
		text="Invalid MSG!!"；
	fi
#	mplayer -really-quiet /home/gsm/bin/a.wav 2>/dev/null &
	if [ "$from" != "" ] || [ "$to" != "" ]; then
		if [ "$link" == 'U' ]; then
		echo " ==============================[$nu]=================================";
		stdbuf -oL printf "[!]TIME:%s ARFCN:%3d TEL:%13s CenTel:%13s UP \n" "$time_" "$arfcn" "$to" "$dtap";
#		printf "MSG:%c $text\n";
		((nu++));
		stdbuf -oL printf "[!]Msg:%c $text \n"
#		echo -e "Msg:"$text;
		mplayer -really-quiet $GSMPATH/a.wav 2>/dev/null &
	else
		echo " ============================[$nu]===================================";
		stdbuf -oL printf "[*]Time:%s Arfcn:%3d Tel:%13s CenTel:%13s DOWN \n" "$time_" "$arfcn" "$from" "$dtap";
		((nu++));
		stdbuf -oL printf "[*]Msg:%c $text \n"
#		echo -e "Msg:"$text;
#		sleep 0.5;
		mplayer -really-quiet $GSMPATH/a.wav 2>/dev/null &
		fi
	fi
done
