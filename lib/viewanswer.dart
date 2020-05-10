import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tutelage_student/chat/chatui.dart';
import 'package:tutelage_student/viewquestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutelage_student/home.dart';
import 'rateandcomplete.dart';

class ViewAnswer extends StatefulWidget {

  final String fromPendingorHistory;
  final String answerID;
  final FirebaseUser user;
  ViewAnswer(this.answerID, this.user, this.fromPendingorHistory);

  @override

  State<StatefulWidget> createState() {
    return ViewAnswerState(this.answerID, this.user, this.fromPendingorHistory);
  }

}

class ViewAnswerState extends State<ViewAnswer> {
  String answerID;
  FirebaseUser user;
  String fromPendingOrHistory;
  ViewAnswerState(this.answerID, this.user, this.fromPendingOrHistory);
  String _imageURL;
  @override
  Widget build(BuildContext context) {

    String usernameCategory = "user_" + user.email;

    var firestoreRef= Firestore.instance
        .collection("askedquestions")
        .document(usernameCategory)
        .collection("answers")
        .document(answerID)
        .snapshots();


    Future getImageURL() async {
      String path = 'answers/' + answerID;
      var cloudstorageRef = FirebaseStorage.instance.ref().child(path);
      cloudstorageRef.getDownloadURL().then((value) => {
        setState(() {
          _imageURL = value;
          debugPrint("PING " + _imageURL);
        })
      }).catchError((e) => debugPrint("No URL"));
    }

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
                    );
                  }
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


                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: RaisedButton(
                                color: Colors.blue[200],
                                textColor: Colors.black,
                                child: Text(
                                  completedYet(),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () {
                                  setState(() {
                                    debugPrint("Answered button clicked");
                                    completedYetButton(snapshot.data['writtenBy']);
                                    //completedYetButton(String string, tutorName)
                                  });
                                },
                              ),
                            ),

                            Container(width: 10.0,),

                            Expanded(
                              child: RaisedButton(
                                color: Colors.blue[200],
                                textColor: Colors.black,
                                child: Text(
                                  'Chat with Tutor',
                                ),
                                onPressed: () {
                                  setState(() {
                                    debugPrint("Chat button clicked");
                                    answerChat( answerID,user);
                                  });
                                },
                              ),
                            ),

                          ],
                        ),
                      ),

                    ],
                  );
                }),
          ),
        ));
  }

  String completedYet() {
    if (fromPendingOrHistory == "questions") {
      return "Question Answered?";
    } else if (fromPendingOrHistory == "answeredQuestions") {
      return "Question has been closed";
    }
    return "ERROR";
  }

  void answerChat(String ans, user) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return chatPage(ans, user);
    }));
  }

//  void fromPendingToHistory(String userId) async{
//      //string is user ID
//    String docID = answerID.substring(0, answerID.length - 4) ;
//
//    //delete from pending and copy to history
//
//    DocumentReference fromPending = Firestore.instance
//        .collection("askedquestions")
//        .document(userId)
//        .collection("questions")
//        .document(docID);
//
//    DocumentReference toHistory = Firestore.instance
//        .collection("askedquestions")
//        .document(userId)
//        .collection("answeredQuestions")
//        .document(docID);
//
//    fromPending.get().then((dataSnapshot){
//      if (dataSnapshot.exists) {
//       toHistory.setData(dataSnapshot.data)
//           .then((data){
//             fromPending.delete();
//             print("File transferred successfully");
//       }
//       ).catchError((e) => print(e));
//      }
//    });
//  }

  void returnToMainPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MainPage(user: user);}));
  }





  void completedYetButton(String tutorName) async{
    if (fromPendingOrHistory == "questions") {
      // fromPendingToHistory(string);

//      Firestore.instance
//          .collection("answeredquestions")
//          .document("tutor_" + tutorName)
//          .collection("questions")
//          .document(answerID.substring(0,answerID.length-4)) //question id
//          .updateData({
//        "askedOrAnswered" : "answeredQuestions",
//      })
//          .then((response) {
//        print("success");
//      }).catchError((error) {
//        print(error);
//        _showAlertDialog(
//            'Error: UNANSLISTDB', 'Problem Saving Answer ');
//      } );returnToMainPage();

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return RateAndComplete(answerID: answerID, user: user, tutorName: tutorName );}));


    } else
      return null;
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