import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forum/libs/http.dart';
import 'package:forum/libs/tools.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class UserLoginPage extends StatefulWidget {
  UserLoginPage({Key key}) : super(key: key);
  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  @override
  var tools;
  Random rd;
  Map bList = {};
  SharedPreferences prefs;

  int checkr1;
  int checkr2;
  LHttp http = new LHttp();
  var abc_def;
  Map tc = {};
  TextEditingController loginAccount = TextEditingController();
  TextEditingController loginPwd = TextEditingController();
  final fkLogin = GlobalKey<FormState>();
  final fkRegister = GlobalKey<FormState>();
  var bRegisterText = Text('註冊帳號');
  var bRegisterDisabled = true;
  login() async {
    //tools.process('註冊中');
    tools.process('登入中');
    await http.setInitVar();
    await http.loadVar();
    var data = {
      'account': loginAccount.text,
      'pwd': gmd5(loginPwd.text),
    };
    var rbody = await http.execute('userLogin', data);
    tools.closePage();
    print(data);
    print(rbody);
    if (rbody['state'] == false) {
      tools.alert(rbody['msg']);
    } else {
      prefs = await SharedPreferences.getInstance();
      print(rbody);
      await prefs.setString('userid', rbody['body']['id']);
      await prefs.setString('token', rbody['body']['token']);
      await prefs.setString('username', rbody['body']['username']);
      Navigator.of(context).pushNamed('/');
    }
  }

  forgetPassword() {
    TextEditingController checkEmail = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //TextEditingController email = TextEditingController();
          return SimpleDialog(
            title: Text('忘記密碼'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () async {
                  Navigator.pop(context, true);
                },
                child: Column(
                  children: <Widget>[
                    TextField(
                        controller: tc['email']['tc'],
                        decoration: new InputDecoration(
                          labelText: '請輸入你的email',
                        )),
                    TextField(
                        controller: tc['pwd']['tc'],
                        obscureText: true,
                        decoration: new InputDecoration(
                          labelText: '請輸入你的新密碼',
                        )),
                    TextField(
                        controller: checkEmail,
                        decoration: new InputDecoration(
                          labelText: '請輸入你的驗證碼',
                        )),
                    RaisedButton(
                      child: Text('送出'),
                      onPressed: () async {
                        if (tc['email']['tc'].text == '') {
                          tools.alert('請輸入Email');
                          return;
                        }
                        if (tc['pwd']['tc'].text != '' &&
                            checkEmail.text == '') {
                          tools.alert('請輸入驗證碼後才可以更新密碼');
                          return;
                        }
                        if (tc['pwd']['tc'].text == '' &&
                            checkEmail.text != '') {
                          tools.alert('請輸入更新密碼');
                          return;
                        }
                        var data = {
                          'email': tc['email']['tc'].text,
                          'forget': checkEmail.text,
                          'pwd': gmd5(tc['pwd']['tc'].text)
                        };
                        Navigator.of(context).pop();
                        tools.process('處理中');
                        var rbody =
                            await http.execute('userForgetPassword', data);
                        tools.closePage();
                        print(rbody);
                        if (rbody['msg'] != null) {
                          tools.alert(rbody['msg']);
                        } else {
                          tools.alert(rbody['body']);
                        }
                      },
                    ),
                    Text('請先輸入Email後，點擊送出，待到得到驗證碼後，輸入密碼及驗證碼。')
                  ],
                ),
              ),
            ],
          );
        });
  }

  register() async {
    //tools.process('註冊中');
    tools.process('註冊中');
    await http.setInitVar();
    await http.loadVar();
    var data = {
      'username': tc['username']['tc'].text,
      'account': tc['account']['tc'].text,
      'pwd': gmd5(tc['pwd']['tc'].text),
      'email': tc['email']['tc'].text,
    };
    var rbody = await http.execute('userRegister', data);
    tools.closePage();
    if (rbody['state'] == false) {
      switch (rbody['errorCode']) {
        case '302001':
          tools.alert('顯示名稱已存在，請更改後重試');
          break;
        case '302002':
          tools.alert('帳號已存在，請更改後重試');
          break;
        case '302003':
          tools.alert('EMail已被使用，請改更後重試');
          break;
        case '500001':
          tools.alert(rbody['msg']);
          break;
      }
    } else {
      http.setVar('token', rbody['body']['token']);
      Navigator.of(context).pushNamed('/');
    }
  }

  initState() {
    tools = new LTools();
    rd = Random();
    checkr1 = rd.nextInt(9);
    checkr2 = rd.nextInt(9);

    super.initState();
  }

  regContainer(labelText, hintText, tcname,
      {errorText, List inputFormats: null, obscureText: false}) {
    List<TextInputFormatter> inputFormats2 = [];
    if (inputFormats == null) {
      inputFormats = [];
    }
    if (inputFormats.length > 0) {
      inputFormats2.add(inputFormats[0]);
    }

    if (tc[tcname] == null) {
      tc[tcname] = {};
      tc[tcname]['tc'] = TextEditingController();
    }
    tc[tcname]['errorText'] = errorText;

    return SizedBox(
        width: 250,
        child: Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: TextFormField(
              inputFormatters: inputFormats2,
              controller: tc[tcname]['tc'],
              obscureText: obscureText,
              validator: (value) {
                switch (tcname) {
                  case 'username':
                    if (tc[tcname]['tc'].text == '') {
                      return '請輸入名稱';
                    }
                    break;
                  case 'pwd':
                    if (tc[tcname]['tc'].text != tc['2pwd']['tc'].text) {
                      return '二次密碼不同';
                    }
                    break;
                  case 'check':
                    print('check check');
                    var sum = checkr1 + checkr2;
                    if (tc[tcname]['tc'].text == null) {
                      return '驗證碼錯誤';
                    }
                    if (tc[tcname]['tc'].text != sum.toString()) {
                      return '驗證碼錯誤';
                    }
                    break;
                  default:
                  //print(tcname);
                }
              },
              decoration: new InputDecoration(
                  labelText: labelText,
                  suffixText: labelText,
                  hintText: hintText,
                  errorText: tc[tcname]['errorText']),
            )));
  }

  Widget build(BuildContext context) {
    tools.setContext(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('登入或註冊'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Form(
                key: fkLogin,
                child: Column(children: <Widget>[
                  Container(
                      margin: EdgeInsets.fromLTRB(30, 40, 30, 10),
                      child: TextFormField(
                        controller: loginAccount,
                        //autofocus: true,
                        validator: (value) {
                          if (value.isEmpty) {
                            return '請輸入帳號';
                          }
                        },
                        decoration: new InputDecoration(
                          filled: true,
                          labelText: '帳號',
                        ),
                      )),
                  Container(
                      margin: EdgeInsets.fromLTRB(30, 30, 30, 10),
                      child: TextFormField(
                        controller: loginPwd,
                        obscureText: true,
                        validator: (value) {
                          if (value.isEmpty) {
                            return '請輸入密碼';
                          }
                        },
                        decoration: new InputDecoration(
                          filled: true,
                          labelText: '密碼',
                        ),
                      )),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          onPressed: login,
                          child: Text('登入'),
                        ),
                      ),
                      Expanded(
                        child: RaisedButton(
                          onPressed: forgetPassword,
                          child: Text('忘記密碼'),
                        ),
                      )
                    ],
                  )
                ])),
            Container(
              margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Divider(
                height: 1.0,
                indent: 00.0,
                color: Colors.red,
              ),
            ),
            Center(
              child: Text('尚未有帳號，進行註冊'),
            ),
            Form(
                key: fkRegister,
                child: Column(children: <Widget>[
                  regContainer('顯示名稱', '要給大家看的暱稱', 'username', inputFormats: [
                    WhitelistingTextInputFormatter(
                        RegExp(r"([A-Za-z0-9\u4e00-\u9fa5])")),
                    BlacklistingTextInputFormatter(RegExp(r"^[W+]"))
                  ]),
                  regContainer('帳號', '帳號英文大小寫及數字', 'account',
                      obscureText: false,
                      inputFormats: [
                        WhitelistingTextInputFormatter(
                            RegExp(r"([a-zA-Z0-9])")),
                        BlacklistingTextInputFormatter(RegExp(r"^[W+]"))
                      ]),
                  regContainer('密碼', '請輸入密碼', 'pwd', obscureText: true),
                  regContainer('確認密碼', '請再次輸入密碼', '2pwd', obscureText: true),
                  regContainer('EMail', '請輸入電子信箱', 'email', inputFormats: [
                    WhitelistingTextInputFormatter(
                        RegExp(r"([a-zA-Z0-9\-\._@])")),
                    BlacklistingTextInputFormatter(RegExp(r"^[W+]"))
                  ]),
                  regContainer('請輸入算式答案', '$checkr1 + $checkr2 = ?', 'check',
                      inputFormats: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ]),
                  RaisedButton(
                    onPressed: () async {
                      bRegisterText = Text('註冊中，請稍後');

                      setState(() {});
                      if (fkRegister.currentState.validate()) {
                        // If the form is valid, we want to show a Snackbar
                        await register();
                      } else {
                        await register();
                        //tools.alert('資料錯誤，請確定後重新點擊註冊');
                      }
                    },
                    child: Text('註冊'),
                  ),
                  //new SnackBarPage(),
                ])),
          ],
        ),
      ),
    );
  }
}
