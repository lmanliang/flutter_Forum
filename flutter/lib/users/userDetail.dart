import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forum/libs/http.dart';
import 'package:forum/libs/tools.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailPage extends StatefulWidget {
  UserDetailPage({Key key}) : super(key: key);
  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  var tc;
  iniState() {}

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('用戶資料')),
        body: Column(
          children: <Widget>[],
        ));
  }
}
