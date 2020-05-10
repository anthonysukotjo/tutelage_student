import 'package:flutter/material.dart';
import 'package:tutelage_student/signin/login.dart';
import 'package:tutelage_student/signin/signinorup.dart';
import 'history.dart' as history;
import 'pendingonlinedb.dart' as pending;
import 'package:firebase_auth/firebase_auth.dart';
import 'highlightedquestions.dart' as highlight;

class MainPage extends StatefulWidget{

  final FirebaseUser user;

  const MainPage({
    Key key,
    this.user,
  }) : super(key: key);

  @override
  MainPageState createState() => new MainPageState(this.user);

}

class MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {

  FirebaseUser user;

  MainPageState(this.user);

  TabController controller;


  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "My Questions",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.blue[600],
          actions: <Widget>[
            PopupMenuButton(
              icon: Icon(
                Icons.menu,
                color: Colors.black,),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("Log Out"),
                  value: 1,
                ),
              ],

              onCanceled: () {
                print("You have canceled the menu.");
              },
              onSelected: (value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => signInOrUp()),
                );
              },
            )






          ],
          bottom: new TabBar(
            controller: controller ,
            tabs: <Tab> [
              new Tab(text: "Pending") ,
              new Tab(text: 'History') ,
              new Tab(child:Text('Featured\nQns',textAlign: TextAlign.center,)),
            ],
            labelColor: Colors.black,
          ),


        ),
        body: new TabBarView(
            controller: controller,
            children: <Widget>[
              new pending.PendingPage(user),
              new history.HistoryPage(user),
              new highlight.HighlightedQuestions(user),
            ]),
      ),
    );
  }
}


