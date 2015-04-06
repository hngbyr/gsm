#!/bin/bash

# usage: /home/gsm/typhon-vx/osmocom-bb-sylvain-burst_ind/src/host/layer23/src/misc/cell_log -s /tmp/osmocom_l2_1 -l - 2>&1 | bash gsm_parse_cell_log.sh
CONFIG="$HOME/.ini/config.ini";
if [ ! -f $CONFIG ];then
zenity --info --text="错误代码0x05" --title="配置文件错误";
    echo "error code 0x05,Please contact the system administrator!";
    exit 1;
fi
GSMPATH=`cat "$CONFIG" | grep '^GSMPATH=' | cut -d '=' -f 2`;
GSMNAPALMEXCOCODE=`cat "$CONFIG" | grep '^GSMNAPALMEXCOCODE=' | cut -d '=' -f 2`;
GSMPACHER=`cat "$CONFIG" | wc -l`
if [ "$GSMNAPALMEXCOCODE" -ne "$GSMPACHER" ];then
	zenity --error --text="非注册用户(error code 0x0f)" --title="请注册" --ok-label="关闭";
	echo "error code 0x0f";
	exit 1;
fi

###==================================================================
#maxcells=40
maxcells=`cat "$CONFIG" | grep '^GSMMAXCELLS=' | cut -d '=' -f 2`;
if [ $# -eq 1 ]; then
	maxcells="$1"
fi

curcells=0
echo 
echo -e "    NO.    ARFCN    强度      CID       服务商";
echo "    ------------------------------------------";
while read line; do
	if echo $line|grep -q Cell; then
		op=`echo "$line" | cut -d '(' -f 2 | cut -d ')' -f 1`
		arfcn=`echo "$line" | cut -d '=' -f 2 | cut -d ' ' -f 1`
		mcnc=`echo "$line" | sed -re "s/^.* MCC=([0-9]{3}) MNC=([0-9]{2,3}).*$/\1\2/"`
	fi
	if echo $line|grep -q "^rxlev"; then
		rxlev=`echo "$line" | cut -d " " -f 2`
	fi
	if echo $line|grep -q "^si3"; then
		cid=$(printf "%d\n" 0x`echo "$line" | cut -c 14,15,17,18`)
	fi
	if echo $line|grep -q si4; then
		if [ "$op" = "China, China Unicom" ];then
			mb="联通"
		else
			mb="移动"
		fi
		stdbuf -oL printf " %4d>  |  %3d     %4d   |   %d" "$((curcells+1))" "$arfcn" "$rxlev" "$cid";
		stdbuf -oL printf "%5c $mb \n";
#	echo "$((curcells+1)):     $arfcn     $rxlev   ($mb $mcnc)"
#		echo "$op;$mcnc;$arfcn;$cid;$rxlev"
		let curcells++
		if [ $curcells -ge $maxcells ]; then
			#echo "[!]已超出默认最大显示数量$maxcells，如需要显示更多，请联系系统管理员！"
			killall -TERM cell_log # cell_log does not respond to sigpipe
			exit 0
		fi
	fi
done

