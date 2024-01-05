#! /bin/sh
source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
MODEL=$(nvram get productid)
DIR=$(cd $(dirname $0); pwd)
touch /tmp/kp_log.txt
if [ "$MODEL" == "GT-AC5300" ] || [ "$MODEL" == "GT-AX11000" ] || [ "$MODEL" == "GT-AC2900" ] || [ "$(nvram get merlinr_rog)" == "1" ];then
	ROG=1
elif [ "$MODEL" == "TUF-AX3000" ] || [ "$(nvram get merlinr_tuf)" == "1" ] ;then
	TUF=1
fi

# 安装插件
cd /tmp
find /jffs/softcenter/init.d/ -name "*my-script*"|xargs rm -rf
cp -rf /tmp/my-script/scripts/* /jffs/softcenter/scripts/
cp -rf /tmp/my-script/webs/* /jffs/softcenter/webs/
#cp -rf /tmp/my-script/res/* /jffs/softcenter/res/
cp -rf /tmp/my-script/uninstall.sh /jffs/softcenter/scripts/uninstall_my-script.sh

chmod 755 /jffs/softcenter/scripts/my-script_conf.sh
ln -sf /jffs/softcenter/scripts/my-script_conf.sh /jffs/softcenter/init.d/N99my-script_conf.sh

# 离线安装用
dbus set my_version="$(cat $DIR/version)"
dbus set softcenter_module_my-script_version="$(cat $DIR/version)"
dbus set softcenter_module_my-script_description="自定义脚本"
dbus set softcenter_module_my-script_install="1"
dbus set softcenter_module_my-script_name="my-script"
dbus set softcenter_module_my-script_title="Wo 的脚本"

# 完成
echo_date "Wo 的脚本插件安装完毕！"
rm -rf /tmp/my-script* >/dev/null 2>&1
exit 0
