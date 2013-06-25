<?php
header("Content-Type: text/html; charset=utf-8");

require_once(dirname(__FILE__) . '/' . 'IGt.Push.php');

define('APPKEY','ugk775NpfR64x0KRo2bmI6');
define('APPID','5i1qDCvTEo7EklhuPztmV5');
define('MASTERSECRET','ONg9pxrrE37ZhbWEClZQ47');
define('HOST','http://192.168.10.61:8006/apiex.htm');
define('CID','3f5afc260a39b454ed2d20da02703851');



pushMessageToSingle();

//pushMessageToList();

//pushMessageToApp();


function pushMessageToSingle(){
	$igt = new IGeTui(HOST,APPKEY,MASTERSECRET);
	
	//消息类型 : 透传信息
	$template =  new IGtTransmissionTemplate(); 

	$template ->set_transmissionType(2);//透传消息类型
	$template ->set_appId(APPID);//应用appid
	$template ->set_appkey(APPKEY);//应用appkey
	$template ->set_transmissionContent("测试离线");//透传内容

	//个推信息体
	$message = new IGtSingleMessage();

	$message->set_isOffline(true);//是否离线
	$message->set_offlineExpireTime(3600*12);//离线时间
	$message->set_data($template);//设置推送消息类型

	//接收方
	$target = new IGtTarget();
	$target->set_appId(APPID);
	$target->set_clientId(CID);

	$rep = $igt->pushMessageToSingle($message,$target);

	var_dump($rep);
    echo ("<br><br>");
}

function pushMessageToList(){
	$igt = new IGeTui(HOST,APPKEY,MASTERSECRET);

	//消息类型 :状态栏链接 点击通知打开网页 
	$template =  new IGtLinkTemplate(); 

	$template ->set_appId(APPID);//应用appid
	$template ->set_appkey(APPKEY);//应用appkey
	$template ->set_title("个推");//通知栏标题
	$template ->set_text("个推最新版点击下载");//通知栏内容
	$template ->set_logo("http://wwww.igetui.com/logo.png");//通知栏logo
	$template ->set_isRing(true);//是否响铃
	$template ->set_isVibrate(false);//是否震动
	$template ->set_isClearable(false);//通知栏是否可清除
	$template ->set_url("http://www.igetui.com/");//打开连接地址

	//个推信息体
	$message = new IGtSingleMessage();

	$message->set_isOffline(true);//是否离线
	$message->set_offlineExpireTime(3600*12);//离线时间
	$message->set_data($template);//设置推送消息类型
	
	$contentId = $igt->getContentId($message);

	//接收方1	
	$target1 = new IGtTarget();
	$target1->set_appId(APPID);
	$target1->set_clientId(CID);
	
	$targetList[] = $target1;

	$rep = $igt->pushMessageToList($contentId, $targetList);

	var_dump($rep);
    echo ("<br><br>");

}

function pushMessageToApp(){
	$igt = new IGeTui(HOST,APPKEY,MASTERSECRET);
	
	//消息类型 : 状态栏通知 点击通知启动应用
	$template =  new IGtNotificationTemplate(); 

	$template->set_appId(APPID);//应用appid
	$template->set_appkey(APPKEY);//应用appkey
	$template->set_transmissionType(2);//透传消息类型
	$template->set_transmissionContent("测试离线");//透传内容
	$template->set_title("个推");//通知栏标题
	$template->set_text("个推最新版点击下载");//通知栏内容
	$template->set_logo("http://wwww.igetui.com/logo.png");//通知栏logo
	$template->set_isRing(false);//是否响铃
	$template->set_isVibrate(false);//是否震动
	$template->set_isClearable(false);//通知栏是否可清除

	//基于应用消息体
	$message = new IGtAppMessage();

	$message->set_isOffline(true);
	$message->set_offlineExpireTime(3600*12);
	$message->set_data($template);

 
	$message->set_appIdList(array(APPID));
	$message->set_phoneTypeList(array('ANDROID'));
	$message->set_provinceList(array());

	$rep = $igt->pushMessageToApp($message);

	var_dump($rep);
    echo ("<br><br>");

}


 
?>
