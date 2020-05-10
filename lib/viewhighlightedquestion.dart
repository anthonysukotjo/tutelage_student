import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tutelage_student/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutelage_student/viewhighlightedanswer.dart';


class ViewHighlightedQuestion extends StatefulWidget {

  final String selectedDocID;
  final String selectedUser;
  final FirebaseUser user;


  const ViewHighlightedQuestion(this.selectedDocID, this.selectedUser, this.user);

  @override
  State<StatefulWidget> createState() {
    return ViewHighlightedQuestionState(this.selectedDocID, this.selectedUser , this.user);
  }
}

class ViewHighlightedQuestionState extends State<ViewHighlightedQuestion> {

  String selectedDocID;
  String selectedUser;
  FirebaseUser user;
  ViewHighlightedQuestionState(this.selectedDocID, this.selectedUser, this.user);
  String _imageURL;

  Future getImageURL () async {
    String path = 'questions/' + selectedDocID;
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

  //qn number on database
  @override
  Widget build(BuildContext context) {

    var firestoreRef= Firestore.instance
        .collection("highlightedQuestions")
        .document(selectedDocID)
        .snapshots();

    return WillPopScope(
        onWillPop: () {
          returnToHomeScreen(user);
        },

        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "My Question",
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
                    returnToHomeScreen(user);
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
                  if(_imageURL == null)getImageURL().catchError((e)=>debugPrint("Caught at THIS"));
                  return ListView(
                    children: <Widget> [
                      Padding(

                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            snapshot.data['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),)),


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
                                    "Level: ${snapshot.data['level']} Subject: ${snapshot.data['subject']}",
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
                          child:
                          _imageURL !=null?
                          Image.network(_imageURL)
                              : Text('')

                      ),
//to be turned into future tutor page
                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: GestureDetector(
                          onTap: () => goToAnswer(snapshot.data["answerID"] , user ),
                          child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.lightGreenAccent,
                              ),

                              child:
                              Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text( answeredYet(snapshot.data["answerID"], ),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                              )
                          ),

                        ),
                      ),

                    ],
                  );
                },
              ),
            )
        ));
  }

  void goToAnswer(String ansid, user) {
    if(ansid != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ViewHighlightedAnswer(ansid, user);
      }));} else return null;
  }

  String answeredYet(String ansId) {
    if(ansId != null) {
      return "Click for the answer!";
    } else return "Currently Looking for Tutor";
  }


  void returnToHomeScreen(FirebaseUser user) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MainPage(user: user);
    }));
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );}


}

