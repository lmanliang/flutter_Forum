<?php
function main(){
	global $dbh ;
	$sth = $dbh->prepare('select * from users');
	$sth->execute();
	$data = $sth->fetchAll(PDO::FETCH_ASSOC);
	if (count($data) > 0){
	return  ['state' => true , 	'data' => $data];
	}else{
		return['state' => false, 'data' => '找不到用戶'];
	}


}
