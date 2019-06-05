<?php
function main(){
	global $dbh ;
	global $raw;
	// check user
	if (empty($raw['account']) or empty($raw['pwd'])){
		return ['state' => false, 'msg' => '帳號或密碼錯誤.' , 'errorCode' => '303'];
	}
	$sth = $dbh->prepare('select id from users where account = :account and pwd = :pwd and disabled is null');
	$sth->bindParam(':account',$raw['account']);
	$sth->bindParam(':pwd',$raw['pwd']);
	$sth->execute();
	$data = $sth->fetchAll(PDO::FETCH_ASSOC);
	if(count($data) == 1){
		$sth = $dbh->prepare('update users set token=uuid()where id=:id');
		$sth->bindParam(':id' , $data[0]['id']);
		$sth->execute();
		$sth = $dbh->prepare('select id,username,token from users where id = :id');
		$sth->bindParam(':id',$data[0]['id']);
		$sth->execute();
		$data = $sth->fetch(PDO::FETCH_ASSOC);
		return ['state' => true , 'data' => $data ];
	}else{
		return ['state' => false, 'msg' => '帳號或密碼錯誤.' , 'errorCode' => '301'];
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
