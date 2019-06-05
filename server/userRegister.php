<?php
function main(){
	global $dbh ;
	global $raw;
	// check user
	if ( !checkDataExists('users','username',$raw['username'])['state']){
		return ['state' => false , 'msg' => 'username is exists.' , 'errorCode' => '302001'];
	}
	if ( !checkDataExists('users','account',$raw['account'])['state']){
		return ['state' => false , 'msg' => 'account is exists.' , 'errorCode' => '302002'];
	}
	if ( !checkDataExists('users','email',$raw['email'])['state']){
		return ['state' => false , 'msg' => 'email is exists.' , 'errorCode' => '302003'];
	}
	$sth = $dbh->prepare('insert users ( username,account,pwd,email,token,created)values(:username,:account,:pwd,:email,uuid(),now())');
	$sth->bindParam(':username',$raw['username']);
	$sth->bindParam(':account',$raw['account']);
	$sth->bindParam(':pwd',$raw['pwd']);
	$sth->bindParam(':email',$raw['email']);
	$sth->execute();
	if($sth->errorInfo()[0] == '00000'){
		$id = $dbh->lastInsertId();
		$sthToken = $dbh->prepare('select token from users where id=:id');
		$sthToken->bindParam(':id' , $id);
		$dataToken= $sthToken->execute();
		$dataToken= $sthToken->fetchAll(PDO::FETCH_ASSOC)[0]['token'];
		
		
		return ['state' => true , 'data' => ['token' => $dataToken] ];
	}else{
		return ['state' => false , 'msg' => '不明錯誤，請洽系統管理員' , 'errorCode' => '500001' ];
	}

}
function checkDataExists($table,$key , $value){
	global $dbh;
	$sth = $dbh->prepare("select id from $table where $key=:$key");
	$sth->bindParam(":$key",$value);
	$sth->execute();
	$data = $sth->fetchAll(PDO::FETCH_ASSOC);
	if ( $data != null){
		return ['state' => false , 'msg' => 'it is exists.' , 'errorCode' => '302'];
	}else{
		return ['state' => true] ;
	}
}
