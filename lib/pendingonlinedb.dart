import 'package:flutter/material.dart';
import 'dart:async';
import 'addQuestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'viewquestion.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PendingPage extends StatefulWidget {


  final FirebaseUser user;

  const PendingPage(this.user);

  @override
  State<StatefulWidget> createState() {

    return PendingPageState(this.user);
  }
}

class PendingPageState extends State<PendingPage>{

  FirebaseUser user;
  PendingPageState(this.user);



  //var  firestoredbunamedcollection = Firestore.instance.collection("question").snapshots();
  //var  firestoredbunamedcollection = Firestore.instance ;
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
            .collection("questions")
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
                  child: Text("Please ask a new question!"),
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
                      return ViewQuestion(snapshot.data.documents[index].documentID, user, "questions");
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
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AddQuestion(user);}));

//            Navigator.push(context, MaterialPageRoute(builder: (context) {
//              return AddQuestion();
//            }));

        },

        tooltip: 'Add Question',
        backgroundColor: Colors.lightBlueAccent.shade100,

        child: Icon(Icons.add,
          color: Colors.black,),

      ),
    );

  }








}



//    .catchError((error){
//print(error);
//_showAlertDialog('Status', 'Problem Deleting Question');
//});}




