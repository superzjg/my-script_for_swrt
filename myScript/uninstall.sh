#!/bin/sh

eval `dbus export myScript_`
source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

find /jffs/softcenter/init.d/ -name "*myScript*"|xargs rm -rf
rm -f /jffs/softcenter/scripts/myScript_config.sh
rm -f /jffs/softcenter/webs/Module_myScript.asp
#rm -f /jffs/softcenter/res/icon-myScript.png
version=${myScript_version}

values=`dbus list myScript_ | cut -d "=" -f 1`
for value in $values
do
dbus remove $value 
done
echo_date "myScript(我的脚本)插件 ${version}已卸载"
rm -f /jffs/softcenter/scripts/uninstall_myScript.sh
