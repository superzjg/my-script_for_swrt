#!/bin/sh

eval `dbus export my_`
source /jffs/softcenter/scripts/base.sh

find /jffs/softcenter/init.d/ -name "*my-script*"|xargs rm -rf
rm -f /jffs/softcenter/scripts/my-script_conf.sh
rm -f /jffs/softcenter/webs/Module_my-script.asp
#rm -f /jffs/softcenter/res/icon-my-script.png
version=${my_version}

values=`dbus list my_ | cut -d "=" -f 1`
for value in $values
do
dbus remove $value 
done
logger "[软件中心]: Wo 的脚本 ${version}已卸载"
rm -f /jffs/softcenter/scripts/uninstall_my-script.sh
