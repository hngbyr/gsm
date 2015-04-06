GSM SMS Sniffer
===========

GSMSniffer 借助 Osmocom-BB 平台,对2G网络短信嗅探抓取的一个Demo
实现自动载入系统/扫描基站与抓取短信并存入数据库的过程
项目公开代码为Python处理部分,完整框架演示可参考:

### 文件说明
=======
```
.
├── bin(核心代码)
│   ├── gsm.sh(主程序)
│   ├── cell_log.sh(调用OsmocomBB扫描基站)
│   ├── motoload.sh(调用OsmocomBB载入系统)
│   ├── scan.sh(调用OsmocomBB扫描基站)
│   ├── show.sh(调用OsmocomBB嗅探基站短信)
│   ├── wireshark.sh(调用wireshark显示短信)
├── gsmapp
│   ├──cell_log (调用OsmocomBB扫描基站)
│   ├── ccch_scan (调用OsmocomBB嗅探基站短信)
│   ├── osmocom OsmocomBB载入系统)
│   └── ini
│          ├── .config.ini(app 配置文件)
│          └── .wireshark(wireshark配置文件 Version 1.9.0 (SVN Rev Unknown from unknown))
└── readme.md(项目说明)

### 工具使用
解压
1. 用ln将需要的so文件链接到/usr/lib或者/lib这两个默认的目录下边 
ln -s /home/bin/wrieshark/lib/*.so /usr/lib 
sudo ldconfig 
2. 修改LD_LIBRARY_PATH 
export LD_LIBRARY_PATH=/home/bin/wrieshark/lib:$LD_LIBRARY_PATH 
sudo ldconfig 
3. 修改/etc/ld.so.conf，然后刷新/etc/ld.so.conf 
vim /etc/ld.so.conf 
add /home/bin/wrieshark/lib
sudo ldconfig 
4. 修改 .ini 文件 到 /home/.ini

