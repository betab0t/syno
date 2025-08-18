<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta http-equiv=pragma content=no-cache>
</head>

<body>
<SCRIPT LANGUAGE="JavaScript">
	var username, userpass, RTSP_Port, RTSP_Path, width, height;
	var port = window.location.port == "" ? (window.location.protocol.indexOf("https") != -1 ? 443 : 80) : window.location.port;

	username  = "admin";
	userpass  = "admin";
	RTSP_Port = "554";
	RTSP_Path = "2";
	width     = "1920";
	height    = "1080";

	function sleep(seconds) {
		var timer = new Date();
		var time = timer.getTime();
		do
			timer = new Date();
		while ((timer.getTime() - time) < (seconds * 1000));
	}

	sleep(1);

	document.write('<OBJECT ID="IPCam_Plugin" CLASSID=clsid:E7EBE29C-F450-411A-ADAD-D039BE0FD69C ALIGN="CENTER" WIDTH="640" HEIGHT="360">');
	document.write('<PARAM name="IP" value="'+window.location.hostname+'">');
	document.write('<PARAM name="WebPort" value="'+port+'">');
	document.write('<PARAM name="RTSP_Port" value="'+RTSP_Port+'">');
	document.write('<PARAM name="Login" value='+username+'>');
	document.write('<PARAM name="Password" value='+userpass+'>');
	document.write('<PARAM name="URL" value="'+RTSP_Path+'">');
	document.write('<PARAM name="RTSP_Width" value="'+width+'">');
	document.write('<PARAM name="RTSP_Height" value="'+height+'">');
	document.write('</OBJECT>');
</SCRIPT>
</body>
</html>
