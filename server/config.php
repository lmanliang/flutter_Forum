<?php

define('DB_NAME','');
define('DB_USER','');
define('DB_PASSWD','');
define('DB_HOST','');
define('DB_TYPE','mysql');
$dbh = new PDO(DB_TYPE.':host='.DB_HOST.';dbname='.DB_NAME, DB_USER, DB_PASSWD);

$system['name'] = '';
$system['noreply'] = 'noreply@yourdomain';
