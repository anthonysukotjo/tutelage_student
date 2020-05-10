import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tutelage_student/chat/chatui.dart';
import 'package:tutelage_student/viewquestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutelage_student/home.dart';

import 'rateandcomplete.dart';

class ViewHighlightedAnswer extends StatefulWidget {

  final String answerID;
  final FirebaseUser user;
  ViewHighlightedAnswer(this.answerID, this.user);

  @override

  State<StatefulWidget> createState() {
    return ViewHighlightedAnswerState(this.answerID, this.user);
  }

}

class ViewHighlightedAnswerState extends State<ViewHighlightedAnswer> {
  String answerID;
  FirebaseUser user;
  ViewHighlightedAnswerState(this.answerID, this.user);
  String _imageURL;

  Future getImageURL () async {
    String path = 'answer/' + answerID;
    var cloudstorageRef = FirebaseStorage.instance
        .ref()
        .child(path);
    await cloudstorageRef.getDownloadURL().then((value) => {
      setState(() {
        _imageURL = value;
        debugPrint("PING " +value);
      }
      )
    }).catchError((e)=> debugPrint("No URL"));


  }
  @override
  Widget build(BuildContext context) {

    var firestoreRef= Firestore.instance
        .collection("highlightedAnswers")
        .document(answerID)
        .snapshots();

    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, true);
        },

        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Answer",
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            backgroundColor: Colors.blue[600],
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                }),
          ),
          body: Padding(
            padding: EdgeInsets.all(20.0),
            child: StreamBuilder(
                stream: firestoreRef,
                builder: (context, snapshot){
                  if (!snapshot.hasData){
                    return Center(
                      child: CircularProgressIndicator(),
                    );}
                  if (_imageURL == null) getImageURL();
                  return ListView(
                    children: <Widget> [
//timestamp
                      Padding(
                          padding: EdgeInsets.only(
                            top: 1.0,
                            bottom: 5.0,
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    snapshot.data['timestamp'],
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    "Written By ${snapshot.data['writtenBy']}",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ])),

                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Container(
                            alignment: Alignment.topLeft,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue[400],
                            ),
                            child:
                            Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  snapshot.data['description'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                )
                            )
                        ),
                      ),
                      //Load uploaded image
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: _imageURL != null
                              ? Image.network(_imageURL)
                              : Text('')
                      ),
                    ],
                  );
                }),
          ),
        ));
  }



}