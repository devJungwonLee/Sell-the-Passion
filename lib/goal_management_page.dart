import 'package:flutter/material.dart';
import 'package:sell_the_passion/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import 'goal_provider.dart';

import 'goal_created_page.dart';
import 'add_goal_page.dart';

class GoalManagementPage extends StatefulWidget {
  @override
  _GoalManagementPageState createState() => _GoalManagementPageState();
}

class _GoalManagementPageState extends State<GoalManagementPage> {
  String categoryString(int c) {
    String s="";
    switch(c) {
      case 0: s='건강'; break;
      case 1: s='학습'; break;
      case 2: s='취미'; break;
    }
    return s;
  }

  String authDayString(List<bool> authDay) {
    String s="";
    for (int i=0; i<7; i++) {
      if (authDay[i]==true) {
        switch(i) {
          case 1: s+="월 "; break;
          case 2: s+="화 "; break;
          case 3: s+="수 "; break;
          case 4: s+="목 "; break;
          case 5: s+="금 "; break;
          case 6: s+="토 "; break;
          case 0: s+="일 "; break;
        }
      }
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    FirebaseProvider fp = Provider.of<FirebaseProvider>(context);
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child('${fp.getUser().uid}').child("goal");
    Goal goal = Provider.of<Goal>(context);

    Color mint = Theme.of(context).primaryColor;
    Color brown = Theme.of(context).accentColor;

    List<Widget> widgetList = <Widget>[
      Text('등록된 목표가 아직 없습니다.', style: TextStyle(fontSize: 20)),
      Text('새로운 목표를 세워보세요!', style: TextStyle(fontSize: 20)),
      SizedBox(height: 20),
      RaisedButton(
        color: Colors.white,
        elevation: 7.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        child: Text('목표 세우기', style: TextStyle(fontSize: 15, color: mint)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return AddGoalPage();
          }));
        }
      ),
    ];

    if (goal.title != null) {
      widgetList.clear();
      widgetList += <Widget>[
        Container(
          width: MediaQuery.of(context).size.width*0.8,
          child: Text('${goal.title}', style: TextStyle(fontSize: 28), textAlign: TextAlign.center),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 0.0),
              padding: const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 1.0),
              decoration: BoxDecoration(
                border: Border.all(color: brown, width: 1.5),
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0)
                )
              ),
              child: Text('${categoryString(goal.category)}', style: TextStyle(
                  color: brown, fontSize: 15.0)
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 0.0),
              padding: const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 1.0),
              decoration: BoxDecoration(
                border: Border.all(color: brown, width: 1.5),
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0)
                )
              ),
              child: Text('${goal.period+1}주', style: TextStyle(
                  color: brown, fontSize: 15.0)
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          width: MediaQuery.of(context).size.width*0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('인증요일   ${authDayString(goal.authDay)}', style: TextStyle(fontSize: 15)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                Text('인증방법', style: TextStyle(fontSize: 15)),
                SizedBox(width: 12),
                Flexible(
                  child: Text('${goal.authMethod}', style: TextStyle(fontSize: 15), softWrap: true)
                ),
              ]),
            ],
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              color: brown,
              icon: Icon(Icons.edit),
              iconSize: 30.0,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return AddGoalPage();
                }));
              }
            ),
            RaisedButton(
              color: Colors.white,
              elevation: 7.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
              child: Text('후원 매칭하기', style: TextStyle(fontSize: 15, color: mint)),
              onPressed: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    content: Text('매칭을 시작하시겠습니까?'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('취소', style: TextStyle(color: mint),),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text('확인', style: TextStyle(color: mint),),
                        onPressed: () {
                          goal.isPaid = true;
                          goal.startDate = DateTime.now();
                          setState(() {
                            dbRef.update({
                              'is_paid': true,
                              'start_date': DateFormat('yyyy-MM-dd').format(goal.startDate),
                              'current_money': 0,
                            });
                          });
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                });
              }
            ),
            IconButton(
              color: brown,
              icon: Icon(Icons.delete),
              iconSize: 30.0,
              onPressed: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    content: Text('목표를 삭제하시겠습니까?'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('취소', style: TextStyle(color: mint),),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text('확인', style: TextStyle(color: mint),),
                        onPressed: () {
                          goal.isPaid = true;
                          goal.startDate = DateTime.now();
                          setState(() {
                            dbRef.remove();
                          });
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                });
              }
            ),
          ],
        ),
      ];
    }

    dbRef.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> map = snapshot.value as Map;
      if (map != null) {
        goal.title = map["title"];
        goal.period = map["period"];
        goal.authMethod = map["auth_method"];
        goal.authDay = List<bool>.from(map["auth_day"]);
        goal.category = map["category"];
        goal.isPaid = map["is_paid"];
      } else {
        goal.title = null;
        goal.period = null;
        goal.authMethod = null;
        goal.authDay = [false, false, false, false, false, false, false];
        goal.category = null;
        goal.isPaid = false;
      }
      if (goal.isPaid) {
        if (map["auth_image"] != null)
          goal.authImage = Map<String, String>.from(map["auth_image"]);
        goal.startDate = DateFormat('yyyy-MM-dd').parse(map["start_date"]);
        goal.currentMoney = map["current_money"];
      }
      setState(() {});
    });

    return FutureBuilder(
      future: dbRef.once(),
      builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
        if (snapshot.hasData) {
          Map<dynamic, dynamic> map = snapshot.data.value as Map;
          if (map != null) {
            goal.title = map["title"];
            goal.period = map["period"];
            goal.authMethod = map["auth_method"];
            goal.authDay = List<bool>.from(map["auth_day"]);
            goal.category = map["category"];
            goal.isPaid = map["is_paid"];
          } else {
            goal.title = null;
            goal.period = null;
            goal.authMethod = null;
            goal.authDay = [false, false, false, false, false, false, false];
            goal.category = null;
            goal.isPaid = false;
          }

          if (goal.isPaid) {
            if (map["auth_image"] != null)
              goal.authImage = Map<String, String>.from(map["auth_image"]);
            goal.startDate = DateFormat('yyyy-MM-dd').parse(map["start_date"]);
            goal.currentMoney = map["current_money"];
            return GoalCreatedPage();
          }

          goal.title = null;
          goal.period = null;
          goal.authMethod = null;
          goal.authDay = [false, false, false, false, false, false, false];
          goal.category = null;
          goal.isPaid = false;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widgetList,
            )
          );
        }
        return Center( child: CircularProgressIndicator() );
      }
    );
  }
}