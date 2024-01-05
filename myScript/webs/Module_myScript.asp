<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
<meta HTTP-EQUIV="Expires" CONTENT="-1"/>
<link rel="shortcut icon" href="images/favicon.png"/>
<link rel="icon" href="images/favicon.png"/>
<title>软件中心 - wo的脚本</title>
<link rel="stylesheet" type="text/css" href="index_style.css" />
<link rel="stylesheet" type="text/css" href="form_style.css" />
<link rel="stylesheet" type="text/css" href="usp_style.css" />
<link rel="stylesheet" type="text/css" href="ParentalControl.css">
<link rel="stylesheet" type="text/css" href="css/icon.css">
<link rel="stylesheet" type="text/css" href="css/element.css">
<link rel="stylesheet" type="text/css" href="/res/layer/theme/default/layer.css">
<link rel="stylesheet" type="text/css" href="res/softcenter.css">
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/validator.js"></script>
<script type="text/javascript" src="/js/jquery.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
<script type="text/javascript" src="/res/softcenter.js"></script>
<style type="text/css">
.close {
    background: red;
    color: black;
    border-radius: 12px;
    line-height: 18px;
    text-align: center;
    height: 18px;
    width: 18px;
    font-size: 16px;
    padding: 1px;
    top: -10px;
    right: -10px;
    position: absolute;
}
/* use cross as close button */
.close::before {
    content: "\2716";
}
.contentM_qis {
    position: fixed;
    -webkit-border-radius: 5px;
    -moz-border-radius: 5px;
    border-radius:10px;
    z-index: 10;
    background-color:#2B373B;
    /*margin-left: -100px;*/
    top: 100px;
    width:755px;
    return height:auto;
    box-shadow: 3px 3px 10px #000;
    background: rgba(0,0,0,0.85);
    display:none;
}
.user_title{
    text-align:center;
    font-size:18px;
    color:#99FF00;
    padding:10px;
    font-weight:bold;
}
.frpc_btn {
    border: 1px solid #222;
    background: linear-gradient(to bottom, #003333  0%, #000000 100%); /* W3C */
    font-size:10pt;
    color: #fff;
    padding: 5px 5px;
    border-radius: 5px 5px 5px 5px;
    width:16%;
}
.frpc_btn:hover {
    border: 1px solid #222;
    background: linear-gradient(to bottom, #27c9c9  0%, #279fd9 100%); /* W3C */
    font-size:10pt;
    color: #fff;
    padding: 5px 5px;
    border-radius: 5px 5px 5px 5px;
    width:16%;
}
.formbottomdesc {
    margin-top:10px;
    margin-left:10px;
}
input[type=button]:focus {
    outline: none;
}
</style>
<script>
var db_my = {};
var params_input = ["my_ipt_comment", "my_v4tcp", "my_v4udp", "my_v6tcp", "my_v6udp", "my_cru_id", "my_script_name", "my_script_autotype", "my_script_autolevel", "my_script_runparam"]
var params_check = ["my_openport_auto", "my_cru_auto", "my_script_ap", "my_script_overwrite", "my_fix_v6"]
var params_base64 = ["my_cru_all", "my_script"]
function initial() {
	show_menu(menu_hook);
	get_dbus_data();
	conf2obj();
}
function get_dbus_data() {
	$.ajax({
		type: "GET",
		url: "/_api/my",
		dataType: "json",
		async: false,
		success: function(data) {
			db_my = data.result[0];
			conf2obj();
			$("#my_version_show").html("版本：" + db_my["my_version"]);
		}
	});
}
function conf2obj() {
	//input
	for (var i = 0; i < params_input.length; i++) {
		if(db_my[params_input[i]]){
			E(params_input[i]).value = db_my[params_input[i]];
		}
	}
	// checkbox
	for (var i = 0; i < params_check.length; i++) {
		if(db_my[params_check[i]]){
			E(params_check[i]).checked = db_my[params_check[i]] == 1 ? true : false
		}
	}
	//base64
	for (var i = 0; i < params_base64.length; i++) {
		if(db_my[params_base64[i]]){
			E(params_base64[i]).value = Base64.decode(db_my[params_base64[i]]);
		}
	}
}
function save() {
	//input
	for (var i = 0; i < params_input.length; i++) {
		if (trim(E(params_input[i]).value) && trim(E(params_input[i]).value) != db_my[params_input[i]] ) {
			db_my[params_input[i]] = trim(E(params_input[i]).value);
		}else if (!trim(E(params_input[i]).value) && db_my[params_input[i]]) {
			db_my[params_input[i]] = "";
            }
	}
	// checkbox
	for (var i = 0; i < params_check.length; i++) {
        if (E(params_check[i]).checked != db_my[params_check[i]]){
            db_my[params_check[i]] = E(params_check[i]).checked ? '1' : '0';
        }
	}
	//base64
	for (var i = 0; i < params_base64.length; i++) {
		if (E(params_base64[i]).value && Base64.encode(E(params_base64[i]).value) != db_my[params_base64[i]]) {
            db_my[params_base64[i]] = Base64.encode(E(params_base64[i]).value);
		} else if (!E(params_base64[i]).value && db_my[params_base64[i]]) {
			db_my[params_base64[i]] = "";
            }
	}
}
function post_alone() {
	$.ajax({
		url: "/applydb.cgi?p=my",
		cache: false,
		type: "POST",
		dataType: "html",
		data: $.param(db_my)
	});
}
function open_port() {
		if (!trim(E("my_v4tcp").value) && !trim(E("my_v4udp").value) && !trim(E("my_v6tcp").value) && !trim(E("my_v6udp").value) && !E("my_fix_v6").checked) {
			alert("无法继续！空内容！");
			return false;
		}
	save();
	
	// post data
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "my-script_conf.sh", "params": ["openport"], "fields": db_my };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
	alert("已完成");
}
function close_port() {
	if (!trim(E("my_v4tcp").value) && !trim(E("my_v4udp").value) && !trim(E("my_v6tcp").value) && !trim(E("my_v6udp").value) && !trim(E("my_ipt_comment").value)) {
		alert("无法继续！备注名 或 端口号 为空！");
		return false;
	}
	if (trim(E("my_ipt_comment").value) != "My-script_rule") {
		alert("执行中。规则备注名非默认值！谨慎填写其他插件自动生成的备注名或端口号！");
	}
	if (confirm('确定关闭吗？')){
	save();
	
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "my-script_conf.sh", "params": ["closeport"], "fields": db_my };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
	}
}
function query_port() {
	save();
	
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "my-script_conf.sh", "params": ["queryport"], "fields": db_my };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
}
function add_cru() {
		if (!trim(E("my_cru_all").value)) {
			alert("无法继续！定时任务内容为空!");
			return false;
		}
	save();
	
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "my-script_conf.sh", "params": ["addcru"], "fields": db_my };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
	alert("已发送指令，请查看是否生成？");
}
function del_cru() {
		if (!trim(E("my_cru_id").value)) {
			alert("无法继续！识别码 为空!");
			return false;
		}
	save();
	
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "my-script_conf.sh", "params": ["delcru"], "fields": db_my };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
	alert("已完成");
}
function add_script() {
		if (!trim(E("my_script").value) || !trim(E("my_script_name").value)) {
			alert("无法继续！脚本文件名和内容 为空!");
			return false;
		}
		if (E("my_script_autotype").value && !trim(E("my_script_autolevel").value)) {
			alert("无法继续！自启打开后，优先级数值为空！");
			return false;
		}
	save();
	
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "my-script_conf.sh", "params": ["addscript"], "fields": db_my };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
	alert("已发送指令，请查看文件是否生成或查阅插件日志。");
}
function del_script() {
		if (!trim(E("my_script_name").value)) {
			alert("无法继续！文件名 为空!");
			return false;
		}
		if (confirm('确定删除吗.?')){
	save();
	
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "my-script_conf.sh", "params": ["delscript"], "fields": db_my };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
    }
}
function query_script() {
 	save();
	
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "my-script_conf.sh", "params": ["queryscript"], "fields": db_my };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
}
function query_script_content() {
    if (!trim(E("my_script_name").value)) {
			alert("无法继续！文件名 为空!");
			return false;
		}
 	save();
	
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "my-script_conf.sh", "params": ["scriptcontent"], "fields": db_my };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
}
function run_script() {
    if (!trim(E("my_script_name").value)) {
			alert("无法继续！文件名 为空!");
			return false;
		}
 	save();
	
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "my-script_conf.sh", "params": ["runscript"], "fields": db_my };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
	alert("已开始运行，是否完成视脚本运行情况。");
}
function kill_script() {
    if (!trim(E("my_script_name").value)) {
			alert("无法继续！文件名 为空!");
			return false;
		}
 	save();
	
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "my-script_conf.sh", "params": ["killscript"], "fields": db_my };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
	alert("已发送强停指令");
}
function clear_log() {
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "my-script_conf.sh", "params": ["clearlog"], "fields": db_my };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
}
function clear_echo() {
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "my-script_conf.sh", "params": ["clearecho"], "fields": db_my };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
			}
		}
	});
}
function menu_hook(title, tab) {
	tabtitle[tabtitle.length - 1] = new Array("", "软件中心", "Wo 的脚本");
	tablink[tablink.length - 1] = new Array("", "Main_Soft_center.asp", "Module_my-script.asp");
}

function get_log() {
	$.ajax({
		url: '/_temp/my_log.log',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
			$('#logtxt').val(res);
		}
	});
}
function get_iptables() {
	$.ajax({
		url: '/_temp/my_iptables_l.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
			$('#IPTtxt').val(res);
		}
	});
}
function get_cru() {
	$.ajax({
		url: '/_temp/my_cru_l_lnk.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
			$('#crutxt').val(res);
		}
	});
}
function get_script() {
	$.ajax({
		url: '/_temp/my_script_l.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
			$('#scripttxt').val(res);
		}
	});
}
function get_script_content() {
	$.ajax({
		url: '/_temp/my_script_c_lnk.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
			$('#contenttxt').val(res);
		}
	});
}
function get_script_echo() {
	$.ajax({
		url: '/_temp/my_script_echo.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
			$('#echotxt').val(res);
		}
	});
}
function open_conf(open_conf) {
	if (open_conf == "my_log") {
	    save();
	    post_alone();
		get_log();
	}
	if (open_conf == "my_iptables_l") {
	    setTimeout("get_iptables()", 1000); 
	}
	if (open_conf == "my_cru_l_lnk") {
	    save();
	    post_alone();
		get_cru();
	}
	if (open_conf == "my_script_l") {
	    setTimeout("get_script()", 1000); 
	}
	if (open_conf == "my_script_echo") {
	    save();
	    post_alone();
		get_script_echo();
	}
	if (open_conf == "my_script_c_lnk") {
	    if (!trim(E("my_script_name").value)) {
			return false;
		}
		setTimeout("get_script_content()", 1000); 
	}
	$("#" + open_conf).fadeIn(0);
}
function close_conf(close_conf) {
	$("#" + close_conf).fadeOut(0);
}

</script>
</head>
<body onload="initial();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
<form method="POST" name="form" action="/applydb.cgi?p=frpc" target="hidden_frame">
<input type="hidden" name="current_page" value="Module_my-script.asp"/>
<input type="hidden" name="next_page" value="Module_my-script.asp"/>
<input type="hidden" name="group_id" value=""/>
<input type="hidden" name="modified" value="0"/>
<input type="hidden" name="action_mode" value=""/>
<input type="hidden" name="action_script" value=""/>
<input type="hidden" name="action_wait" value="5"/>
<input type="hidden" name="first_time" value=""/>
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>"/>
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>"/>
<table class="content" align="center" cellpadding="0" cellspacing="0">
    <tr>
        <td width="17">&nbsp;</td>
        <td valign="top" width="202">
            <div id="mainMenu"></div>
            <div id="subMenu"></div>
        </td>
        <td valign="top">
            <div id="tabMenu" class="submenuBlock"></div>
            <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
                <tr>
                    <td align="left" valign="top">
                        <table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3"  class="FormTitle" id="FormTitle">
                            <tr>
                                <td bgcolor="#4D595D" colspan="3" valign="top">
                                    <div>&nbsp;</div>
                                    <div style="float:left;" class="formfonttitle">软件中心 - Wo 的脚本</div>
                                    <div style="float:right; width:15px; height:25px;margin-top:10px"><img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img></div>
                                    <div style="margin:30px 0 10px 5px;" class="splitLine"></div>
                                    <div class="formfontdesc">【用于打开自定义端口，设置定时任务，自定义脚本】by: superzjg@qq.com<br><i>注：主界面所有按钮都可保存数据。</i></div>
                                    <div id="frpc_switch_show">
                                    <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                        <tr id="switch_tr">
                                            <th>
                                                <label><a class="hintstyle"><i><strong>插件日志</strong></i></a></label>
                                            </th>
                                            <td colspan="2">
                                                <div id="my_version_show" style="padding-top:5px;margin-left:30px;margin-top:0px;float: left;"></div>
                                                &nbsp;&nbsp;&nbsp;<a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="open_conf('my_log');" >查看插件日志</a>
                                            </td>
                                        </tr>
                                    </table>
                                    </div>
                                    <div id="simple_table">
                                    <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="box-shadow: 3px 3px 10px #000;margin-top: 0px;">
                                        <thead>
                                            <tr>
                                            <td colspan="2">打开端口INPUT</td>
                                            </tr>
                                        </thead>
                                        <tr>
                                              <th>
                                                <label><a class="hintstyle">自动执行任务（NAT模式）</a></label>
                                            </th>
                                                <td colspan="2">
                                                <div class="switch_field" style="display:table-cell;float: left;">
                                                    <label for="my_openport_auto">
                                                        <input id="my_openport_auto" class="switch" type="checkbox" style="display: none;">
                                                        <div class="switch_container" >
                                                            <div class="switch_bar"></div>
                                                            <div class="switch_circle transition_style">
                                                                <div></div>
                                                            </div>
                                                        </div>
                                                    </label>
                                                </div>
                                            </td>
                                            </tr>
                                        <th>
                                                <label><a class="hintstyle">手动操作</a></label>
                                            </th>
                                                <td colspan="2">
                                                <a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="open_port();" >打开端口</a>
                                                &nbsp;<a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="close_port();" >关闭端口</a>
                                                &nbsp;<a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="query_port();open_conf('my_iptables_l');" >查看端口状态</a>
                                            </td>
                                            <tr>
                                            <th width="20%"><a class="hintstyle">规则备注名</a></th>
                                            <td>
                                                <input type="text" class="input_ss_table" id="my_ipt_comment" name="my_ipt_comment" maxlength="100" value="My-script_rule" placeholder="My-script_rule"/>&nbsp;&nbsp;&nbsp;设为空可忽略此项
                                            </td>
                                            </tr>
                                            <tr>
                                            <th width="20%"><a class="hintstyle">TCP端口（IPv4）</a></th>
                                            <td>
                                                <input type="text" oninput="this.value=this.value.replace(/[^\d ]/g, '')" class="input_ss_table" id="my_v4tcp" name="my_v4tcp" maxlength="100" value="" placeholder="空格隔开端口号"/>&nbsp;&nbsp;&nbsp;多个端口用空格隔开（下同）
                                            </td>
                                        </tr>

                                         <tr>
                                            <th width="20%"><a class="hintstyle">UDP端口（IPv4）</a></th>
                                            <td>
                                                <input type="text" oninput="this.value=this.value.replace(/[^\d ]/g, '')" class="input_ss_table" id="my_v4udp" name="my_v4udp" maxlength="100" value="" placeholder="空格隔开端口号"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th width="20%"><a class="hintstyle">TCP端口（IPv6）</a></th>
                                            <td>
                                                <input type="text" oninput="this.value=this.value.replace(/[^\d ]/g, '')" class="input_ss_table" id="my_v6tcp" name="my_v6tcp" maxlength="100" value="" placeholder="空格隔开端口号"/>
                                            </td>
                                        </tr>

                                         <tr>
                                            <th width="20%"><a class="hintstyle">UDP端口（IPv6）</a></th>
                                            <td>
                                                <input type="text" oninput="this.value=this.value.replace(/[^\d ]/g, '')" class="input_ss_table" id="my_v6udp" name="my_v6udp" maxlength="100" value="" placeholder="空格隔开端口号"/>
                                            </td>
                                        </tr>
                                        <tr>
                                              <th>
                                                <label><a class="hintstyle">附带修复IPv6规则（测试）</a></label>
                                            </th>
                                                <td colspan="2">
                                                <div class="switch_field" style="display:table-cell;float: left;">
                                                    <label for="my_fix_v6">
                                                        <input id="my_fix_v6" class="switch" type="checkbox" style="display: none;">
                                                        <div class="switch_container" >
                                                            <div class="switch_bar"></div>
                                                            <div class="switch_circle transition_style">
                                                                <div></div>
                                                            </div>
                                                        </div>
                                                    </label>
                                                </div>某些版本，开启ipv6防火墙（同时关闭ipv4防火墙）时，INPUT可能缺失规则，导致对外建立的连接被拦截，或OpenVPN、WireGuard异常
                                            </td>
                                            </tr>
                                        <thead>
                                            <tr>
                                            <td colspan="2">创建定时任务</td>
                                            </tr>
                                        </thead>
                                         <tr>
                                              <th>
                                                <label><a class="hintstyle">自动创建任务（NAT模式）</a></label>
                                            </th>
                                                <td colspan="2">
                                                <div class="switch_field" style="display:table-cell;float: left;">
                                                    <label for="my_cru_auto">
                                                        <input id="my_cru_auto" class="switch" type="checkbox" style="display: none;">
                                                        <div class="switch_container" >
                                                            <div class="switch_bar"></div>
                                                            <div class="switch_circle transition_style">
                                                                <div></div>
                                                            </div>
                                                        </div>
                                                    </label>
                                                </div>
                                            </td>
                                            </tr>
                                            <th>
                                                <label><a class="hintstyle">手动添加</a></label>
                                            </th>
                                                <td colspan="2">
                                                <a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="add_cru();" >手动添加</a>
                                                &nbsp;<a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="open_conf('my_cru_l_lnk');" >查看当前</a>&nbsp;&nbsp;&nbsp;若某识别码已注册，将不会覆盖
                                            </td>
                                            <tr>
                                            <th width="20%"><a class="hintstyle">手动删除（输入识别码）</a></th>
                                            <td>
                                                <input type="text" class="input_ss_table" id="my_cru_id" name="my_cru_id" maxlength="100" value="" placeholder="识别码"/>
                                                <a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="del_cru();" >删除此项</a>
                                            </td>
                                            </tr>
                                            <tr>
                                                <th style="width:20%;"><a class="hintstyle">追加定时内容</a><br>
                                                </th>
                                                <td>
                                                    <textarea cols="63" rows="4" wrap="off" id="my_cru_all" name="my_cru_all" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" style="font-size:11px;background:#475A5F;color:#FFFFFF" placeholder="格式：<分 时 日 月 周 指令 #识别码#>&#13;举例,每分钟在系统记录打印Hello，识别码test1：&#10;*/1 * * * * logger Hello #test1#" ></textarea>
                                                </td>
                                            </tr>
                                        <thead>
                                            <tr>
                                                <td colspan="2"><a class="hintstyle"> 自定义脚本</a></td>
                                            </tr>
                                        </thead>
                                            <tr>
                                              <th>
                                                <label><a class="hintstyle">操作</a></label>
                                            </th>
                                            <td colspan="2">
                                                <a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="add_script();" >添加脚本</a>
                                                &nbsp;<a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="del_script();" >删除脚本</a>
                                                &nbsp;<a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="query_script_content();open_conf('my_script_c_lnk');" >查看脚本内容</a>
                                                &nbsp;<a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="query_script();open_conf('my_script_l');" >查看文件列表</a>
                                            </td>
                                            </tr>
                                            <tr>
                                              <th>
                                                <label><a class="hintstyle">脚本文件名</a></label>
                                            </th>
                                            <td>
                                                <input type="text" class="input_ss_table" id="my_script_name" name="my_script_name" maxlength="100" value="" placeholder="NAT模式建议加sh扩展名"/>
                                                <label><input type="checkbox" id="my_script_overwrite" name="my_script_overwrite"><i>覆盖同名文件</i>
                                            </td>
                                            </tr>
                                            <tr>
                                              <th>
                                                <label><a class="hintstyle">同时添加自动启动（NAT模式）</a></label>
                                            </th>
                                            <td>
                                                <select id="my_script_autotype" name="my_script_autotype" style="width:100px;margin:0px 0px 0px 2px;" class="input_option" >
                                                    <option value="">不添加</option>
                                                    <option value="N">N 型</option>
                                                    <option value="S">S 型</option>
                                                    <option value="NS">N+S 型</option>
                                                </select>
                                                <input type="text" oninput="this.value=this.value.replace(/[^\d]/g, '').replace(/^0{1,}/g,'')" class="input_ss_table" style="width:100px;"id="my_script_autolevel" name="my_script_autolevel" maxlength="2" value="99" placeholder="优先值默认99"/>&nbsp;&nbsp;&nbsp;AP模式此方式无效
                                            </td>
                                            </tr>
                                            <tr>
                                              <th>
                                                <label><a class="hintstyle">脚本运行参数</a></label>
                                            </th>
                                            <td>
                                                <input type="text" class="input_ss_table" id="my_script_runparam" name="my_script_runparam" maxlength="100" value="" placeholder="空参数用双引号并转义"/>
                                                <a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="run_script();" >开始运行</a>
                                                &nbsp;<a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="open_conf('my_script_echo');" >查看输出</a>
                                                &nbsp;<a type="button" class="frpc_btn" style="cursor:pointer" href="javascript:void(0);" onclick="kill_script();" >强制停止</a>
                                            </td>
                                            </tr>
                                            <tr>
                                              <th>
                                                <label><a class="hintstyle">切换AP模式（自动启动）</a></label>
                                            </th>
                                                <td colspan="2">
                                                <div class="switch_field" style="display:table-cell;float: left;">
                                                    <label for="my_script_ap">
                                                        <input id="my_script_ap" class="switch" type="checkbox" style="display: none;">
                                                        <div class="switch_container" >
                                                            <div class="switch_bar"></div>
                                                            <div class="switch_circle transition_style">
                                                            </div>
                                                        </div>
                                                    </label>
                                                </div><p>注：/jffs/scripts/目录，脚本文件名可能有要求，如：services-start等。<a href="https://github.com/RMerl/asuswrt-merlin.ng/wiki/User-scripts" target="_blank"><em>参考梅林固件</em></a></p>
                                            </td>
                                            </tr>
                                            <tr>
                                                <th style="width:20%;"><a class="hintstyle">脚本内容</a><br>
                                                </th>
                                                <td>
                                                    <textarea cols="63" rows="20" wrap="off" id="my_script" name="my_script" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" style="font-size:11px;background:#475A5F;color:#FFFFFF" placeholder="# 输入完整内容" ></textarea>
                                                </td>
                                            </tr>
                                    </table>
                                    </div>

                                    <div style="margin:30px 0 10px 5px;" class="splitLine"></div>
                                    <div class="formbottomdesc" id="cmdDesc">
                                        * 注意事项：<br>
                                        1、路由器NAT模式，依托软件中心/jffs/softcenter/init.d/目录启动脚本；<br>
                                        2、路由器AP模式，依托/jffs/scripts/目录启动脚本；<br>
                                        3、定时任务格式：<分 时 日 月 周 指令 #识别码#>。
                                    </div>
                                </td>
                            </tr>
                        </table>
                                    <!-- this is the popup area for user rules -->
                                    <div id="my_log"  class="contentM_qis" style="box-shadow: 3px 3px 10px #000;margin-top: 70px;">
                                        <div class="user_title">插件日志&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0)" onclick="close_conf('my_log');" value="关闭"><span class="close"></span></a></div>
                                        <div style="margin-left:15px"><i>文本不会自动刷新，读取文件【/tmp/upload/my_log.log】。</i></div>
                                        <div style="margin: 10px 10px 10px 10px;width:98%;text-align:center;">
                                            <textarea cols="50" rows="20" wrap="off" id="logtxt" style="width:97%;padding-left:10px;padding-right:10px;border:1px solid #222;font-family:'Courier New', Courier, mono; font-size:11px;background:#475A5F;color:#FFFFFF;outline: none;" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
                                        </div>
                                        <div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
                                            <input id="edit_node1" class="button_gen" type="button" onclick="close_conf('my_log');" value="返回主界面">
                                            &nbsp;&nbsp;<input id="edit_node1_1" class="button_gen" type="button" onclick="close_conf('my_log');clear_log();" value="清空日志">
                                        </div>
                                    </div>
                                    
                                    <div id="my_iptables_l"  class="contentM_qis" style="box-shadow: 3px 3px 10px #000;margin-top: 70px;">
                                        <div class="user_title">查询INPUT链规则&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0)" onclick="close_conf('my_iptables_l');" value="关闭"><span class="close"></span></a></div>
                                        <div style="margin-left:15px"><i>文本框显示内容，稍等即更新...读取文件【/tmp/upload/my_iptables_l.txt】。</i></div>
                                        <div style="margin: 10px 10px 10px 10px;width:98%;text-align:center;">
                                            <textarea cols="50" rows="20" wrap="off" id="IPTtxt" style="width:97%;padding-left:10px;padding-right:10px;border:1px solid #222;font-family:'Courier New', Courier, mono; font-size:11px;background:#475A5F;color:#FFFFFF;outline: none;" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
                                        </div>
                                        <div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
                                            <input id="edit_node2" class="button_gen" type="button" onclick="close_conf('my_iptables_l');" value="返回主界面">
                                        </div>
                                    </div>
                                    
                                    <div id="my_cru_l_lnk"  class="contentM_qis" style="box-shadow: 3px 3px 10px #000;margin-top: 70px;">
                                        <div class="user_title">查询定时任务&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0)" onclick="close_conf('my_cru_l_lnk');" value="关闭"><span class="close"></span></a></div>
                                        <div style="margin-left:15px"><i>显示当前生效的定时项，两 # 号之间的内容为<识别码>。读取软链接[/tmp/upload/my_cru_l_lnk.txt]。</i></div>
                                        <div style="margin: 10px 10px 10px 10px;width:98%;text-align:center;">
                                            <textarea cols="50" rows="10" wrap="off" id="crutxt" style="width:97%;padding-left:10px;padding-right:10px;border:1px solid #222;font-family:'Courier New', Courier, mono; font-size:11px;background:#475A5F;color:#FFFFFF;outline: none;" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
                                        </div>
                                        <div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
                                            <input id="edit_node3" class="button_gen" type="button" onclick="close_conf('my_cru_l_lnk');" value="返回主界面">
                                        </div>
                                    </div>
                                    
                                    <div id="my_script_l"  class="contentM_qis" style="box-shadow: 3px 3px 10px #000;margin-top: 70px;">
                                        <div class="user_title">查询文件列表&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0)" onclick="close_conf('my_script_l');" value="关闭"><span class="close"></span></a></div>
                                        <div style="margin-left:15px"><i>文本框显示内容，稍等即更新...读取文件[/tmp/upload/my_script_l.txt]。</i></div>
                                        <div style="margin: 10px 10px 10px 10px;width:98%;text-align:center;">
                                            <textarea cols="50" rows="20" wrap="off" id="scripttxt" style="width:97%;padding-left:10px;padding-right:10px;border:1px solid #222;font-family:'Courier New', Courier, mono; font-size:11px;background:#475A5F;color:#FFFFFF;outline: none;" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
                                        </div>
                                        <div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
                                            <input id="edit_node4" class="button_gen" type="button" onclick="close_conf('my_script_l');" value="返回主界面">
                                        </div>
                                    </div>
                                    
                                    <div id="my_script_echo"  class="contentM_qis" style="box-shadow: 3px 3px 10px #000;margin-top: 70px;">
                                        <div class="user_title">查看脚本输出&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0)" onclick="close_conf('my_script_echo');" value="关闭"><span class="close"></span></a></div>
                                        <div style="margin-left:15px"><i>文本不会自动刷新，读取文件[/tmp/upload/my_script_echo.txt]。</i></div>
                                        <div style="margin: 10px 10px 10px 10px;width:98%;text-align:center;">
                                            <textarea cols="50" rows="20" wrap="off" id="echotxt" style="width:97%;padding-left:10px;padding-right:10px;border:1px solid #222;font-family:'Courier New', Courier, mono; font-size:11px;background:#475A5F;color:#FFFFFF;outline: none;" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
                                        </div>
                                        <div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
                                            <input id="edit_node5" class="button_gen" type="button" onclick="close_conf('my_script_echo');" value="返回主界面">
                                            &nbsp;&nbsp;<input id="edit_node5_1" class="button_gen" type="button" onclick="close_conf('my_script_echo');clear_echo();" value="清空内容">
                                        </div>
                                    </div>
                                    
                                    <div id="my_script_c_lnk"  class="contentM_qis" style="box-shadow: 3px 3px 10px #000;margin-top: 70px;">
                                        <div class="user_title">查看脚本内容&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0)" onclick="close_conf('my_script_c_lnk');" value="关闭"><span class="close"></span></a></div>
                                        <div style="margin-left:15px"><i>文本框显示内容，稍等即更新...若显示为空，可能文件名不正确。读取软链接[/tmp/upload/my_script_c_lnk.txt]。</i></div>
                                        <div style="margin: 10px 10px 10px 10px;width:98%;text-align:center;">
                                            <textarea cols="50" rows="20" wrap="off" id="contenttxt" style="width:97%;padding-left:10px;padding-right:10px;border:1px solid #222;font-family:'Courier New', Courier, mono; font-size:11px;background:#475A5F;color:#FFFFFF;outline: none;" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
                                        </div>
                                        <div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
                                            <input id="edit_node6" class="button_gen" type="button" onclick="close_conf('my_script_c_lnk');" value="返回主界面">
                                        </div>
                                    </div>
                                    <!-- end of the popouparea -->
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
            <!--===================================Ending of Main Content===========================================-->
        </td>
        <td width="10" align="center" valign="top"></td>
    </tr>
</table>
</form>
<div id="footer"></div>
</body>
</html>
