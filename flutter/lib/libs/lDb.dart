import 'package:imei_plugin/imei_plugin.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../libs/http.dart';

class LDb {
  static final LDb _ldb = new LDb._internal();
  factory LDb() {
    return _ldb;
  }
  LDb._internal();
  var cUuid = new Uuid();
  bool debug = true;
  bool ready = false;
  Database db;
  LHttp httpClient = new LHttp();
  var imei;

  initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'seed.db');
    //var dbFile = new File(path);
    //deleteDatabase(path);
    db = await openDatabase(path, version: 4,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      print('create table');
      await db.execute('CREATE TABLE users ( id  int, name TEXT )');
      await db.execute(
          'CREATE TABLE orders( id int, productId int,styleId int ,userName TEXT,quantity  int  , imei TEXT,uuid TEXT ,delTag int)');
      await db.execute(
          'CREATE TABLE products ( id int ,name TEXT,price int , comments TEXT,stateId int ,styleCount int)');
      await db.execute(
          'CREATE TABLE productStyles ( id int , pid int , name TEXT)');
    });
    imei = await ImeiPlugin.getImei;
    ready = true;
  }

  printdb(table) async {
    var qq = await db.query(table);
    print('$table $qq');
  }
}
