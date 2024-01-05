#!/bin/sh

# 引用环境变量
script_dir=/jffs/softcenter/scripts
init_dir=/jffs/softcenter/init.d
source $script_dir/base.sh
# 导入skipd数据。（会合并连续的空格，有时要注意，比如del_cru）
eval `dbus export myScript_`

LOG_FILE=/tmp/upload/myScript_log.log
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
mkdir -p /tmp/upload
user=`nvram get http_username`
[ "${myScript_script_ap}" == "1" ] && scr_file=/jffs/scripts/"${myScript_script_name}" || scr_file=$script_dir/"${myScript_script_name}"

if [ ! -L "/tmp/upload/myScript_cru_l_lnk.txt" ]; then
	ln -sf /var/spool/cron/crontabs/"$user" /tmp/upload/myScript_cru_l_lnk.txt
	echo_date "添加定时任务查看链接" | tee -a $LOG_FILE
fi
if [ ! -L "$init_dir/N99myScript.sh" ];then
	echo_date "添加nat-start触发" | tee -a $LOG_FILE
	ln -sf $script_dir/myScript_config.sh $init_dir/N99myScript.sh
fi
# 端口查询
check_port(){
	local Type=$1
	local Port=$2
	local Comment=$3
	local IPv=$4
	[ -z "${IPv}" ] && iptables -t filter -S INPUT | grep dport | grep -w "${Comment}" | grep "${Type}" | grep -w "${Port}"
	[ "${IPv}" == "6" ] && ip6tables -t filter -S INPUT | grep dport | grep -w "${Comment}" | grep "${Type}" | grep -w "${Port}"
}
# 写规则，参数有空格传递需加双引号
write_ipt(){
	local TP=$1
	local Pt=$2
	local Cm=$3
	local IP=$4
	[ -z "${IP}" ] && IP=iptables
	[ "${IP}" == "6" ] && IP=ip6tables
	if [ -n "${Cm}" ];then
	    ${IP} -I INPUT -p ${TP} --dport ${Pt} -m comment --comment "${Cm}" -j ACCEPT >/dev/null 2>&1
	else
	    ${IP} -I INPUT -p ${TP} --dport ${Pt} -j ACCEPT >/dev/null 2>&1
    fi
}
# # 判断端口合法性，非整数和负数在插件网页输入时已被限制
Port_validate(){
	if [ "$port" -gt 65535 ] || [ "$port" -lt 1 ];then
		echo_date "--->错误：端口 $port 非法"
		continue
	fi
	[ "${port:0:1}" == "0" ] && port=$(expr "$port" + 0)
}
# 使iptables能作备注
load_xt_comment(){
    local CM=$(lsmod | grep xt_comment)
	local OS=$(uname -r)
	if [ -z "${CM}" -a -f "/lib/modules/"${OS}"/kernel/net/netfilter/xt_comment.ko" ];then
		insmod /lib/modules/"${OS}"/kernel/net/netfilter/xt_comment.ko
		echo_date "已加载xt_comment.ko内核模块"
	fi
}
# 修复开启IPv6防火墙（关闭IPv4防火墙），v6的INPUT规则（B5.2.2 B5.2.3）
fix_v6_rules(){
    local _fw_enable_x=`nvram get fw_enable_x`
    local _ipv6_fw_enable=`nvram get ipv6_fw_enable`
    local Flag
    if [ "${_fw_enable_x}" == "0" ] && [ "${_ipv6_fw_enable}" == "1" ]; then
        local _buildno=`nvram get buildno`
        local M1 M2 M3 M4 M5 M6
		local tmp_file=/tmp/myScript_IP6IN_rules.txt
        ip6tables -t filter -S INPUT > "$tmp_file"
        M1=$(cat "$tmp_file" | grep "state RELATED,ESTABLISHED -j ACCEPT")
        M2=$(cat "$tmp_file" | grep -w "br0" | grep "state NEW -j ACCEPT")
        M3=$(cat "$tmp_file" | grep -w "lo" | grep "state NEW -j ACCEPT")
        M4=$(cat "$tmp_file" | grep "state INVALID -j DROP")
        M5=$(cat "$tmp_file" | grep -e "-j WGSI")
        M6=$(cat "$tmp_file" | grep -e "-j OVPNSI")
        if [ -z "$M6" ]; then
            ip6tables -I INPUT -j OVPNCI
            ip6tables -I INPUT -j OVPNSI
            Flag=1
        fi
        if [ -z "$M5" ] && [ "$_buildno" -ge "388" ]; then
            ip6tables -I INPUT -j WGCI
            ip6tables -I INPUT -j WGSI
            Flag=1
        fi
        [ -z "$M4" ] && ip6tables -I INPUT -m state --state INVALID -j DROP && Flag=1
        [ -z "$M3" ] && ip6tables -I INPUT -i lo -m state --state NEW -j ACCEPT && Flag=1
        [ -z "$M2" ] && ip6tables -I INPUT -i br0 -m state --state NEW -j ACCEPT && Flag=1
        [ -z "$M1" ] && ip6tables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT && Flag=1
        rm -f "$tmp_file"
    fi
    [ "$Flag" == "1" ] && echo_date "修复ipv6 INPUT规则完成" || echo_date "无需修复ipv6 INPUT规则"
}
# 打开端口
open_port(){
    [ "${myScript_fix_v6}" == "1" ] && fix_v6_rules
    
    [ -z "${myScript_v4tcp}" ] && [ -z "${myScript_v4udp}" ] && [ -z "${myScript_v6tcp}" ] && [ -z "${myScript_v6udp}" ] && return 1
    load_xt_comment
    local port
	if [ -n "${myScript_v4tcp}" ]; then
		local t_port
        for port in ${myScript_v4tcp}
        do
        Port_validate
        if [ -z "$(check_port tcp ${port})" ]; then
            write_ipt tcp ${port} "${myScript_ipt_comment}"
            [ -n "${t_port}" ] && t_port="${t_port},"
            t_port="${t_port}${port}"
        fi
        done
        [ -n "${t_port}" ] && echo_date "开启IPv4 TCP端口：${t_port}"
    fi
    if [ -n "${myScript_v4udp}" ]; then
        local u_port
        for port in ${myScript_v4udp}
        do
        Port_validate
        if [ -z "$(check_port udp ${port})" ]; then
            write_ipt udp ${port} "${myScript_ipt_comment}"
            [ -n "${u_port}" ] && u_port="${u_port},"
            u_port="${u_port}${port}"
        fi
        done
        [ -n "${u_port}" ] && echo_date "开启IPv4 UDP端口：${u_port}"
    fi

    if [ -n "${myScript_v6tcp}" ]; then
        local t_port_v6
        for port in ${myScript_v6tcp}
        do
        Port_validate
        if [ -z "$(check_port tcp ${port} "" 6)" ]; then
            write_ipt tcp ${port} "${myScript_ipt_comment}" 6
            [ -n "${t_port_v6}" ] && t_port_v6="${t_port_v6},"
            t_port_v6="${t_port_v6}${port}"
        fi
        done
        [ -n "${t_port_v6}" ] && echo_date "开启IPv6 TCP端口：${t_port_v6}"
    fi
    if [ -n "${myScript_v6udp}" ]; then
        local u_port_v6
        for port in ${myScript_v6udp}
        do
        Port_validate
        if [ -z "$(check_port udp ${port} "" 6)" ]; then
            write_ipt udp ${port} "${myScript_ipt_comment}" 6
            [ -n "${u_port_v6}" ] && u_port_v6="${u_port_v6},"
            u_port_v6="${u_port_v6}${port}"
        fi
        done
        [ -n "${u_port_v6}" ] && echo_date "开启IPv6 UDP端口：${u_port_v6}"
    fi
}
# 关闭端口
close_port(){
    load_xt_comment
    local port CHK FLAG
	local tmp_file=/tmp/clean_my-script_rule.sh
	if [ -n "${myScript_v4tcp}" ]; then
        local t_port
        for port in ${myScript_v4tcp}
        do
        Port_validate
        CHK=`check_port tcp ${port} "${myScript_ipt_comment}"`
        [ -n "${CHK}" ] && echo "${CHK}" >> "$tmp_file" || continue
        [ -n "${t_port}" ] && t_port="${t_port},"
        t_port="${t_port}${port}"
        done
        [ -n "${t_port}" ] && echo_date "关闭IPv4 TCP端口：${t_port}"
    fi
    if [ -n "${myScript_v4udp}" ]; then
        local u_port
        for port in ${myScript_v4udp}
        do
        Port_validate
        CHK=`check_port udp ${port} "${myScript_ipt_comment}"`
        [ -n "${CHK}" ] && echo "${CHK}" >> "$tmp_file" || continue
        [ -n "${u_port}" ] && u_port="${u_port},"
        u_port="${u_port}${port}"
        done
        [ -n "${u_port}" ] && echo_date "关闭IPv4 UDP端口：${u_port}"
    fi
    sed -i 's/-A/iptables -D/g' "$tmp_file"

    if [ -n "${myScript_v6tcp}" ]; then
        local t_port_v6
        for port in ${myScript_v6tcp}
        do
        Port_validate
        CHK=`check_port tcp ${port} "${myScript_ipt_comment}" 6`
        [ -n "${CHK}" ] && echo "${CHK}" >> "$tmp_file" || continue
        [ -n "${t_port_v6}" ] && t_port_v6="${t_port_v6},"
        t_port_v6="${t_port_v6}${port}"
        done
        [ -n "${t_port_v6}" ] && echo_date "关闭IPv6 TCP端口：${t_port_v6}"
    fi
    if [ -n "${myScript_v6udp}" ]; then
        local u_port_v6
        for port in ${myScript_v6udp}
        do
        Port_validate
        CHK=`check_port udp ${port} "${myScript_ipt_comment}" 6`
        [ -n "${CHK}" ] && echo "${CHK}" >> "$tmp_file" || continue
        [ -n "${u_port_v6}" ] && u_port_v6="${u_port_v6},"
        u_port_v6="${u_port_v6}${port}"
        done
        [ -n "${u_port_v6}" ] && echo_date "关闭IPv6 UDP端口：${u_port_v6}"
    fi
    sed -i 's/-A/ip6tables -D/g' "$tmp_file"
	if [ -z "${myScript_v4tcp}" ] && [ -z "${myScript_v4udp}" ] && [ -z "${myScript_v6tcp}" ] && [ -z "${myScript_v6udp}" ] && [ -n "${myScript_ipt_comment}" ];then
		CHK=`check_port "" "" "${myScript_ipt_comment}"`
        [ -n "${CHK}" ] && echo "${CHK}" >> "$tmp_file" && FLAG=1
		sed -i 's/-A/iptables -D/g' "$tmp_file"
		CHK=`check_port "" "" "${myScript_ipt_comment}" 6`
        [ -n "${CHK}" ] && echo "${CHK}" >> "$tmp_file" && FLAG=1
		sed -i 's/-A/ip6tables -D/g' "$tmp_file"
		[ "$FLAG" == "1" ] && echo_date "关闭所有备注为 ${myScript_ipt_comment} 的端口号" || echo_date "没有备注为 ${myScript_ipt_comment} 的端口号可关闭"
	fi	
    chmod +x "$tmp_file"
    /bin/sh "$tmp_file" >/dev/null 2>&1
    rm -f "$tmp_file"
}
# 查询端口
query_port(){
    local port t_port u_port t_port_v6 u_port_v6
	local port_l_file=/tmp/upload/myScript_iptables_l.txt
	echo_date "查询输入的端口号，已打开的有：" > ${port_l_file}
	if [ -n "${myScript_v4tcp}" ]; then
        for port in ${myScript_v4tcp}
        do
		Port_validate
        if [ -n "$(check_port tcp ${port})" ]; then
            [ -n "${t_port}" ] && t_port="${t_port},"
            t_port="${t_port}${port}"
        fi
        done
        [ -n "${t_port}" ] && echo "IPV4 TCP：${t_port}" >> ${port_l_file}
    fi
    if [ -n "${myScript_v4udp}" ]; then
        for port in ${myScript_v4udp}
        do
		Port_validate
        if [ -n "$(check_port udp ${port})" ]; then
            [ -n "${u_port}" ] && u_port="${u_port},"
            u_port="${u_port}${port}"
        fi
        done
        [ -n "${u_port}" ] && echo "IPV4 UDP：${u_port}" >> ${port_l_file}
    fi

    if [ -n "${myScript_v6tcp}" ]; then
        for port in ${myScript_v6tcp}
        do
		Port_validate
        if [ -n "$(check_port tcp ${port} "" 6)" ]; then
            [ -n "${t_port_v6}" ] && t_port_v6="${t_port_v6},"
            t_port_v6="${t_port_v6}${port}"
        fi
        done
        [ -n "${t_port_v6}" ] && echo "IPV6 TCP：${t_port_v6}" >> ${port_l_file}
    fi
    if [ -n "${myScript_v6udp}" ]; then
        for port in ${myScript_v6udp}
        do
		Port_validate
        if [ -n "$(check_port udp ${port} "" 6)" ]; then
            [ -n "${u_port_v6}" ] && u_port_v6="${u_port_v6},"
            u_port_v6="${u_port_v6}${port}"
        fi
        done
        [ -n "${u_port_v6}" ] && echo "IPV6 UDP：${u_port_v6}" >> ${port_l_file}
    fi
    [ -z "${t_port}" ] && [ -z "${u_port}" ] && [ -z "${t_port_v6}" ] && [ -z "${u_port_v6}" ] && echo "（无）" >> ${port_l_file}

	query_IPT >> ${port_l_file}
	echo_date "查询端口打开状态"
}
query_IPT(){    
    echo ""
    echo "下面显示INPUT链具体状态："
    echo "【IPV4)】："
    iptables -L INPUT
    echo ""
    echo "【IPV6】："
    ip6tables -L INPUT
}
# 添加定时(踩坑：获得commd时要操作带双引号变量，否则星号出现异常)
add_cru(){
    [ -z "${myScript_cru_all}" ] && echo_date "自动创建定时任务：内容为空" && return 1
    local _myScript_cru_all=`dbus get myScript_cru_all | base64_decode` 
    local tmp id commd
    local i=0
    cat > /tmp/myScript_cru_all.txt<<-EOF
				${_myScript_cru_all}
				EOF
    while read -r line
    do
        i=$(($i+1))
        [ -z "`echo "$line" | grep "#"`" ] && echo_date "未创建定时：第$i行，无#" && continue
        # 截取第一个#前面的内容，去除首尾空格
        commd=`echo "${line%%#*}" | sed -e 's/^[ ]*//g' -e 's/[ ]*$//g'`
        # 截取第一个#后面的内容，查找#，若无跳出
        tmp=`echo "${line#*#}" | grep "#"`
        [ -z "${tmp}" ] && echo_date "未创建定时：第$i行，仅一个#" && continue
        # 截取tmp第一个#前面的内容，当line有连续#时致tmp首字符为#，id为空
        id=`echo "${tmp%%#*}"`
        [ -z "${id}" -o -z "${commd}" ] && echo_date "未创建定时：第$i行，空内容" && continue
        if [ -z "$(cru l | grep -w "#${id}#")" ]; then
            cru a "${id}" "${commd}"
            echo_date "创建第$i行定时任务${id}"
        else
            echo_date "未创建定时：第$i行，识别码存在"
        fi
    done < /tmp/myScript_cru_all.txt
    rm -f /tmp/myScript_cru_all.txt
}
del_cru(){
    # 在add时，id可能有连续空格，此处重新get与之匹配
	myScript_cru_id=$(dbus get myScript_cru_id)
	if [ -n "$(cru l | grep -w "#${myScript_cru_id}#")" ]; then
        cru d "${myScript_cru_id}"
        echo_date "删除定时任务${myScript_cru_id}"
    else
        echo_date "删除失败：无定时任务${myScript_cru_id}"
    fi
}
# 添加脚本
add_script(){
    local _myScript_script=`dbus get myScript_script | base64_decode`
	if [ "${myScript_script_overwrite}" == "0" ] && [ -f "${scr_file}" ]; then
        echo_date "文件${scr_file}已存在，无法添加，退出" 
        return 1
    fi
	cat > "${scr_file}"<<-EOF
			${_myScript_script}
			EOF
	echo_date "添加脚本 ${scr_file}"
	chmod +x "${scr_file}"

    [ "${myScript_script_ap}" == "1" ] && return 1
    if [ "${myScript_script_autotype}" == "N" -o "${myScript_script_autotype}" == "NS" ]; then
        ln -sf "${scr_file}" $init_dir/N${myScript_script_autolevel}"${myScript_script_name}"
        echo_date "添加启动链接 N${myScript_script_autolevel}${myScript_script_name}"
    fi
    if [ "${myScript_script_autotype}" == "S" -o "${myScript_script_autotype}" == "NS" ]; then
        ln -sf "${scr_file}" $init_dir/S${myScript_script_autolevel}"${myScript_script_name}"
        echo_date "添加启动链接 S${myScript_script_autolevel}${myScript_script_name}"
    fi
}
del_script(){
    if  [ -f "${scr_file}" ]; then
        rm -f "${scr_file}"
        echo_date "删除脚本 ${scr_file}"
        [ "${myScript_script_ap}" == "1" ] && return 1
		rm -f $init_dir/*"${myScript_script_name}"
        echo_date "发送指令：删除 ${myScript_script_name}的启动链接"
    else
        echo_date "删除失败: 无文件${scr_file}"
    fi
}
query_script(){
    true > /tmp/upload/myScript_script_l.txt
    query_script_com >> /tmp/upload/myScript_script_l.txt
    echo_date "查询文件列表"
}
query_script_com(){
    echo_date "查询/jffs/scripts/目录文件："
    ls -lt /jffs/scripts/
    echo ""
    echo_date "查询$script_dir/目录文件："
    ls -lt $script_dir/
    echo ""
    echo_date "查询$init_dir/目录文件："
    ls -lt $init_dir/
}
# 运行脚本
run_script(){
    echo_date "运行${scr_file} ${myScript_script_runparam}" | tee -a /tmp/upload/myScript_script_echo.txt
    /bin/sh "${scr_file}" ${myScript_script_runparam} >>/tmp/upload/myScript_script_echo.txt 2>&1
}
kill_script(){
    # killall和pidof貌似对脚本无效，对bin文件有效
    local _pid=$(ps -w | grep -w "${myScript_script_name}" | grep -v grep | awk '{print $1}')
    if [ -n "${_pid}" ]; then
        kill -9 "${_pid}" >/dev/null 2>&1
        echo_date "关闭${myScript_script_name}进程:${_pid}"
	fi
}
query_script_content(){
    rm -f /tmp/upload/myScript_script_c_lnk.txt
    echo_date "发送指令：查看脚本文件内容"
    [ -f "${scr_file}" ] && ln -sf "${scr_file}" /tmp/upload/myScript_script_c_lnk.txt || echo_date "查看${scr_file}内容失败，无此文件"
}

case $ACTION in
openport)
	open_port | tee -a $LOG_FILE
	;;
closeport)
	close_port | tee -a $LOG_FILE
	;;
queryport)
	query_port | tee -a $LOG_FILE
	;;
addcru)
	add_cru | tee -a $LOG_FILE
	;;
delcru)
	del_cru | tee -a $LOG_FILE
	;;
addscript)
	add_script | tee -a $LOG_FILE
	;;
delscript)
	del_script | tee -a $LOG_FILE
	;;
queryscript)
	query_script | tee -a $LOG_FILE
	;;
clearlog)
	true > $LOG_FILE
	;;
runscript)
	run_script | tee -a $LOG_FILE
	;;
killscript)
	kill_script | tee -a $LOG_FILE
	;;
clearecho)
	true > /tmp/upload/myScript_script_echo.txt
	;;
scriptcontent)
	query_script_content | tee -a $LOG_FILE
	;;
start_nat)
    [ "${myScript_openport_auto}" == "1" ] && open_port | tee -a $LOG_FILE
    [ "${myScript_cru_auto}" == "1" ] && add_cru | tee -a $LOG_FILE
	;;
esac
