<?php

include('config.php');
$token = 'ak18';

$rawdata =  file_get_contents( 'php://input' );
if (php_sapi_name() == 'cli'){
	$_GET['method'] = 'userForgetPassword';
	$rawdata = '{"account":"lman","pwd":"3a106e5a7c999d2630b20ac103dfc27b"}';
	$rawdata = '{"email":"lman@brain-c.com"}';
	$rawdata = '{"email":"lman@brain-c.com","check":"3081","pwd":"3a106e5a7c999d2630b20ac103dfc27b"}';
	$rawdata = '{"email":"lman@brain-c.com","forget":"2276","pwd":"3a106e5a7c999d2630b20ac103dfc27b"}';
}
//file_put_contents('log.txt', date('Y-m-d H:i:s') . 'Recive ininput: ' . print_r($data,true),FILE_APPEND);
if (!in_array($_GET['method'] , ['userRegister','userLogin','userForgetPassword'])){
	if ($_GET['token'] != $token){
		echo json_encode(['method' => $_GET['method'],'state' => false , 'msg' => 'token error.']);
		exit();
	}elseif( !file_exists($_GET['method'].'.php'))
	{
		echo json_encode(['method' => $_GET['method'],'state' => false , 'msg' => 'method not found.']);
		exit();
	}
}
$raw = json_decode($rawdata,1);

include($_GET['method'].'.php');
$return = main();
$return['method'] = $_GET['method'];
echo json_encode($return,JSON_UNESCAPED_UNICODE);

file_put_contents('log.txt', date('Y-m-d H:i:s') . "\n".'Raw: ' . print_r($rawdata,true)."\n",FILE_APPEND);
file_put_contents('log.txt', 'Get: ' . print_r($_GET,true),FILE_APPEND)."\n";
file_put_contents('log.txt', 'POST: ' . print_r($_POST,true),FILE_APPEND)."\n";
file_put_contents('log.txt', 'return: ' . print_r($return,true),FILE_APPEND)."\n";
file_put_contents('log.txt', '-----',FILE_APPEND)."\n";
