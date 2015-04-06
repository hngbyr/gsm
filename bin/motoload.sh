#/bin/sh

# motoload.sh
# moded by 0x7678
# Under GNU GPL 

# get config settings
CONFIG="$HOME/.ini/config.ini";
GSMAPPATH=`cat "$CONFIG" | grep '^GSMAPATH=' | cut -d '=' -f 2`;
if [ ! -f $CONFIG ];then
zenity --info --text="错误代码0x05" --title="程序错误";
    echo "error code 0x05,Please contact the system administrator!";
    exit 1;
fi
if [ -z "$1" ]; then 
#	echo "usage: $0 \"phone type\" [serial line] [l2_socket] [loader]";
#	echo "suppoted phones:  C115/C117/C123/C121/C118/C139/C140/C155"
#	echo "example: $0 C139 /dev/ttyUSB2 /tmp/testsocket /tmp/testloader"
#	exit 0;
	mobile=C123;
else 
	mobile="$1"
fi

if [ -z "$2" ]; then 
	stty=/dev/ttyUSB0; 
else 
	stty="$2";
fi

if [ -z "$3" ]; then 
	l2socket=""; 
else 
	l2socket=" -s $3";
fi

if [ -z "$4" ]; then 
	loader=""; 
else 
	loader=" -l $4";
fi
id=`echo "$stty" | cut -b 12-`
case "$mobile" in 
	C115|C117|C118|C119|C121|C123)
		# e88 
		# this is not ideal for C115 and C117,
		# but they seems to work..
		echo -n "Loading , press button on a phone...";
		xterm -T "AC-GSM Channel [ $((id+1)) ] Data Windows" -e "$GSMAPPATH"/osmocon $l2socket $loader -p "$stty" -m c123xor "$GSMAPPATH"/layer1.compalram.bin &
		;;
	*)
		echo "Unknown phone $1."
		;;
esac
