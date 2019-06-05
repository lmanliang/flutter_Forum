import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class LHttp {
  String hToken;
  String hUrl;
  Duration hTimeout;
  String url;
  SharedPreferences prefs;
  setInitVar() async {
    prefs = await SharedPreferences.getInstance();
    var httpTimeout = await prefs.getInt('httpTimeout');
    if (httpTimeout == null) {
      prefs.setInt('httpTimeout', 5);
    }

    var httpUrl = await prefs.getString('httpUrl');
    if (httpUrl == null) {
      await prefs.setString(
          'httpUrl', 'https://keto.brain-c.com/app/forum/index.php');
    }

    var httpToken = await prefs.getString('token');
    if (httpToken == null) {
      await prefs.setString('token', 'ak18');
    }
  }

  setVar(k, v) async {
    prefs = await SharedPreferences.getInstance();
    switch (k) {
      case 'httpTimeout':
      case 'httpToken':
        await prefs.setString(k, v);
        break;
      case 'httpTimeout':
        await prefs.setInt(k, v);
        break;
    }
  }

  loadVar() async {
    prefs = await SharedPreferences.getInstance();
    hToken = await prefs.getString('token');
    hUrl = await prefs.getString('httpUrl');
    var tmpTimeout = await prefs.getInt('httpTimeout');
    hTimeout = Duration(seconds: tmpTimeout);
  }

  combindUrl(method) async {
    await loadVar();
    return "$hUrl?token=$hToken&method=$method";
  }

  execute(String method, Map data) async {
    String url = await combindUrl(method);
    print(url);
    var json;
    if (data == null) {
    } else {
      json = jsonEncode(data);
    }
    HttpClient client = new HttpClient();
    client.connectionTimeout = hTimeout;
    try {
      final request = await client.postUrl(Uri.parse(url)).timeout(hTimeout);
      request.headers.set('content-type', 'application/json');
      if (json != null) {
        request.add(utf8.encode(json));
      }
      final response = await request.close().timeout(hTimeout);
      if (response.statusCode == 200) {
        String responseBody = await response.transform(Utf8Decoder()).join();
        var re = jsonDecode(responseBody);
        if (re['state'] == false) {
          return {
            'state': false,
            'msg': re['msg'],
            'errorCode': re['errorCode']
          };
        } else {
          return {'state': true, 'body': re['data']};
        }
      } else {
        return {'state': false, 'errorCode': 10000, 'msg': '服務器不明錯誤，請聯絡系統管理員'};
      }
    } on SocketException catch (_) {
      return {'state': false, 'errorCode': 10001, 'msg': '連線不明原因錯誤'};
    } on TimeoutException catch (_) {
      return {'state': false, 'errorCode': 10002, 'msg': '連線逾時'};
    }
  }
}
