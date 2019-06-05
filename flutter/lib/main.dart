import 'package:flutter/material.dart';
import 'package:forum/users/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:forum/libs/http.dart';
import 'package:forum/libs/tools.dart';
import 'package:forum/users/userDetail.dart';

void main() => runApp(MyForum());

class MyForum extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "梁楓的飲食討論區",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        //home: MyForumPage(title: 'Forum'),
        initialRoute: '/',
        routes: {
          '/': (context) => MyForumPage(title: 'Forum'),
          'userLogin': (context) => UserLoginPage(),
          'userDetail': (context) => UserDetailPage(),
        });
  }
}

class MyForumPage extends StatefulWidget {
  MyForumPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyForumPageState createState() => _MyForumPageState();
}

class _MyForumPageState extends State<MyForumPage> {
  LHttp http = LHttp();
  List content = [
    {'name': '生酮新手', 'id': 1},
    {'name': '我的餐盤', 'id': 1},
    {'name': '醫療問題', 'id': 1},
    {'name': 'APP回報', 'id': 1},
    {'name': '低碳商城', 'id': 1, 'bgcolor': Colors.amber}
  ];
  Widget dDrawer;
  Widget firstMenu;
  List BTNI = ['論壇', '工具', '商城', '個人資料'];
  int _tabIndex = 0;
  var tabImgs;
  Image getTabsImage(int curIndex) {
    if (curIndex == _tabIndex) {
      return tabImgs[curIndex][1];
    }
    return tabImgs[curIndex][0];
  }

  dataDrawer() async {
    Widget firstMenu;
    var prefs = await SharedPreferences.getInstance();
    var username = await prefs.getString('username');
    var account = await prefs.getString('account');
    var userid = await prefs.getString('userid');
    var token = await prefs.getString('token');
    LTools tools = LTools();
    await http.loadVar();

    if (userid == null) {
      firstMenu = RaisedButton(
        onPressed: () async {
          await Navigator.pushNamed(context, 'userLogin');
          dataDrawer();
        },
        child: Text('登入或註冊'),
      );
    } else {
      firstMenu = Row(
        children: <Widget>[
          Expanded(
              child: RaisedButton(
            onPressed: () async {
              await Navigator.pushNamed(context, 'userDetail');
              dataDrawer();
            },
            child: Text('你好 $username'),
          )),
          Expanded(
              child: RaisedButton(
            onPressed: () async {
              tools.setContext(context);
              tools.process('登出中');
              Map data = {':id': userid, 'token': token};
              await http.execute('userLogout', data);
              prefs.remove('userid');
              prefs.remove('username');
              prefs.remove('token');
              tools.closePage();
              await Navigator.pushNamed(context, '/');
              dataDrawer();
            },
            child: Text('登出'),
          ))
        ],
      );
    }
    return Drawer(
        child: Column(children: <Widget>[
      Container(
          margin: EdgeInsets.fromLTRB(10, 26, 10, 10),
          child: Container(margin: EdgeInsets.all(10), child: firstMenu)),
      Container(color: Colors.grey, child: Center(child: Text("主題列表"))),
      Expanded(
        child: ListView.builder(
            itemCount: content.length,
            itemBuilder: (BuildContext context, int index) {
              var titleBgColor = Colors.white;
              if (content[index]['bgcolor'] == null) {
                titleBgColor = Colors.white;
              } else {
                titleBgColor = content[index]['bgcolor'];
              }
              return Card(
                color: titleBgColor,
                child: Container(
                    margin: EdgeInsets.fromLTRB(10, 15, 10, 15),
                    child: Text(content[index]['name'])),
              );
            }),
      ),
    ]));
  }

  @override
  void initState() {
    super.initState();
  }

  calldrawer() async {
    dDrawer = await dataDrawer();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    calldrawer();
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: dDrawer,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
            ],
          ),
        ),
        bottomNavigationBar: new BottomNavigationBar(
            items: [
              new BottomNavigationBarItem(
                icon: Icon(Icons.forum),
                title: Text('討論區'),
              ),
              new BottomNavigationBarItem(
                  icon: Icon(Icons.pan_tool), title: Text('工具區')),
              new BottomNavigationBarItem(
                  icon: Icon(Icons.settings), title: Text('個人資料')),
            ],
            currentIndex: _tabIndex,
            onTap: (index) {
              print(index);
              setState(() {
                _tabIndex = index;
              });
            }));
  }
}
