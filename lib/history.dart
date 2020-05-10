import 'package:flutter/material.dart';
import 'addQuestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'viewquestion.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HistoryPage extends StatefulWidget {

  final FirebaseUser user;

  HistoryPage(this.user);

  @override
  createState() {
    return new HistoryPageState(this.user);
  }
}

class HistoryPageState extends State<HistoryPage> {

  FirebaseUser user;
  HistoryPageState(this.user);

  @override
  Widget build(BuildContext context) {

    String usernameCategory = "user_" + user.email;

    return Scaffold(

      body:
      StreamBuilder(
        stream:  Firestore
            .instance
            .collection("askedquestions")
            .document(usernameCategory)
            .collection("answeredQuestions")
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data.documents.length == 0) {
            return new Container(
                child: new Center(
                  child: Text("List of Answered Questions"),
                ));
          } else return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context,int index){
              return Card(
                color: Colors.white,
                elevation: 2.0,
                child: ListTile(
                  title: Text(snapshot.data.documents[index]['title']),
                  subtitle: Text(snapshot.data.documents[index]['timestamp']),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return ViewQuestion(snapshot.data.documents[index].documentID, user, "answeredQuestions");
                    }));
                  },
                  //Text(snapshot.data.documents[index]['title']);
                ),
              );
            }, //itemBuilder
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          debugPrint('FAB clicked') ;
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AddQuestion(user);
          }));

        },

        tooltip: 'Add Question',
        backgroundColor: Colors.lightBlueAccent.shade100,

        child: Icon(Icons.add,
          color: Colors.black,),

      ),
    );

  }
}