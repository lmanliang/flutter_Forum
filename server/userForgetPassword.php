<?php
function main(){
	global $dbh ;
	global $raw;
	global $system;
	if ( empty($raw['email'])){
		return ['state' => false , 'msg'=>'需要Email'];
	}

	if(!empty($raw['email']) and !empty($raw['forget']) and !empty($raw['pwd'])){
		$sth = $dbh->prepare('select id from users where email=:email and forget=:forget and forget is not null');
		$sth->bindParam(':email' , $raw['email']);
		$sth->bindParam(':forget' , $raw['forget']);
		$sth->execute();
		if ($sth->RowCount() > 0 ){
			$userId = $sth->fetch(PDO::FETCH_ASSOC)['id'];
			$sth = $dbh->prepare('update users set pwd = :pwd,forget=null where id = :id');
			$sth->bindParam(':id' , $userId);
			$sth->bindParam(':pwd' , $raw['pwd']);
			$sth->execute();
			return ['state'=>true, 'data' => '密碼變更成功'];
		}else{
			return ['state'=>false,'msg'=>'email或驗證碼錯誤','errorCode' => '100001'];
		}

	}

	if ( empty($raw['forget'])){
		$sth = $dbh->prepare('select id,email from users where email=:email');
		$sth->bindParam(':email' , $raw['email']);
		$sth->execute();
		$count = $sth->RowCount();
		if ($count > 0){
			$forget = rand(1000,9999);
			$data = $sth->fetch(PDO::FETCH_ASSOC);
			$sth = $dbh->prepare('update users set forget = :forget where id=:id');
			$sth->bindParam(':id' , $data['id']);
			$sth->bindParam('forget',$forget);
			$sth->execute();
			//mail ( $raw['email'] , $system['name'] .':忘記密碼' , "您的驗證碼為 $forget", "From: {$system['noreply']}" );
			return ['state'=>true, 'data' => '驗證碼已寄到您的信箱(可能出現在垃圾筒或廣告信)。'];
		}else{
			return ['state'=>true, 'data' => '驗證碼已寄到您的信箱(可能出現在垃圾筒或廣告信))。'];
		}
	}
	return ['state' => false, 'msg' => '參數不足'];
}
