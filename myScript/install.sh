#! /bin/sh
source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
# MODEL=$(nvram get productid)
DIR=$(cd $(dirname $0); pwd)

# 安装插件
cd $DIR
find /jffs/softcenter/init.d/ -name "*myScript*"|xargs rm -rf
cp -rf $DIR/scripts/* /jffs/softcenter/scripts/
cp -rf $DIR/webs/* /jffs/softcenter/webs/
# cp -rf $DIR/res/* /jffs/softcenter/res/
cp -f $DIR/uninstall.sh /jffs/softcenter/scripts/uninstall_myScript.sh

chmod 755 /jffs/softcenter/scripts/myScript_config.sh
chmod 755 /jffs/softcenter/scripts/uninstall_myScript.sh
ln -sf /jffs/softcenter/scripts/myScript_config.sh /jffs/softcenter/init.d/N99myScript.sh

# 离线安装用
dbus set myScript_version="$(cat $DIR/version)"
dbus set softcenter_module_myScript_version="$(cat $DIR/version)"
dbus set softcenter_module_myScript_description="自定义脚本"
dbus set softcenter_module_myScript_install="1"
dbus set softcenter_module_myScript_name="myScript"
dbus set softcenter_module_myScript_title="我的脚本"

# 完成
echo_date "myScript(我的脚本)插件安装完毕！"
rm -rf $DIR/* >/dev/null 2>&1
exit 0
