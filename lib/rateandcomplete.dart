import 'package:flutter/material.dart';
import 'package:tutelage_student/home.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RateAndComplete extends StatefulWidget {

  final String answerID;
  final FirebaseUser user;
  final String tutorName ;
  RateAndComplete({Key key, this.answerID, this.user, this.tutorName}) : super (key: key);

  @override
  State<StatefulWidget> createState() {
    return RateAndCompleteState(this.answerID, this.user,this.tutorName);
  }

}

class RateAndCompleteState extends State<RateAndComplete> {
  String answerID;
  FirebaseUser user;
  String tutorName;
  RateAndCompleteState(this.answerID, this.user, this.tutorName);

  static var _rate = [
    "1", "2" , "3" , "4", "5"
  ];

  String rateValue;
  bool highlightOrNot = false;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: Text("Complete Question",textAlign: TextAlign.center, style: TextStyle(color: Colors.black),),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            StreamBuilder(
                stream: Firestore.instance
                    .collection("tutorUserProfiles")
                    .document("tutor_" + tutorName)
                    .snapshots(),

                builder: (context, snapshot){
                  if (!snapshot.hasData){
                    return Center(
                      child: CircularProgressIndicator(),
                    );}
                  return ListView(

                      shrinkWrap: true,
                      children: <Widget> [

                        SizedBox(height: 30,),

                        Text("Please rate your tutors answer!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20,),

                        Center(
                          child: DropdownButton(
                              items: _rate.map((String dropDownintItem) {
                                return DropdownMenuItem<String>(
                                  value: dropDownintItem,
                                  child: Text(dropDownintItem,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                );
                              }).toList(),
                              hint: Text("Select rating"),
                              value: rateValue,
                              onChanged: (NewValue) {
                                setState(() {
                                  debugPrint('Selected $NewValue');
                                  updateRate(NewValue);
                                });
                              }
                          ),
                        ),
                        SizedBox(height: 20,),
                        // ask user for consent to publish question, false dont publish, true publish
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              checkColor: Colors.blue[600],
                              value: highlightOrNot,
                              onChanged: (value) {
                                setState(() {
                                  highlightOrNot = value;
                                });
                              },
                            ),

                            Text("Would you like to share this question \n on the Featured Tab? ",
                              style: TextStyle(
                                fontSize: 20,
                              )
                              ,),
                          ],
                        ),

                        SizedBox(height: 20,),
                        RaisedButton(
                          color: Colors.blue[400],
                          textColor: Colors.black,
                          child: Text(
                            'Complete Question',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Send button clicked");
                              CompleteQuestion(snapshot.data['noOfQuestionsAnswered'], snapshot.data['totalPoints'],);
                            });
                          },
                        ),



                      ]
                  );}
            )],),
      ),
    );

  }

  void updateRate(String a) {
    rateValue = a;
  }

  void fromPendingToHistory() async{
    //string is user ID
    String docID = answerID.substring(0, answerID.length - 4) ;


    //delete from pending and copy to history
    DocumentReference fromPending = Firestore.instance
        .collection("askedquestions")
        .document("user_" + user.email)
        .collection("questions")
        .document(docID);

    DocumentReference toHistory = Firestore.instance
        .collection("askedquestions")
        .document("user_" + user.email)
        .collection("answeredQuestions")
        .document(docID);

    DocumentReference toHighlight = Firestore
        .instance
        .collection("highlightedQuestions")
        .document(docID);


    if(highlightOrNot == true) {

      fromPending.get().then((dataSnapshot){
        if (dataSnapshot.exists) {
          toHistory.setData(dataSnapshot.data)
              .then((data){
            toHighlight.setData(dataSnapshot.data)
                .then((data){
              fromPending.delete();
              print("File transferred successfully");
            }
            ).catchError((e) => print(e));
          });}
      });

    } else fromPending.get().then((dataSnapshot){
      if (dataSnapshot.exists) {
        toHistory.setData(dataSnapshot.data)
            .then((data){
          fromPending.delete();
          print("File transferred successfully");
        }
        ).catchError((e) => print(e));
      }
    });





  }

  void returnToMainPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MainPage(user: user);}));
  }

  void CompleteQuestion(int totalQns, totalPts) async{
    fromPendingToHistory();

// update tutor qn database
    Firestore.instance
        .collection("answeredquestions")
        .document("tutor_" + tutorName)
        .collection("questions")
        .document(answerID.substring(0,answerID.length-4)) //question id
        .updateData({
      "askedOrAnswered" : "answeredQuestions",
    })
        .then((response) {
      print("success");
    }).catchError((error) {
      print(error);
      _showAlertDialog(
          'Error: UNANSLISTDB', 'Problem Saving Answer ');
    } );

// update tutor user profile
    Firestore.instance
        .collection("tutorUserProfiles")
        .document("tutor_" + tutorName)
        .updateData({
      "totalPoints" :totalPts + int.parse(rateValue) ,
      "noOfQuestionsAnswered" : totalQns + 1,
    })
        .then((response) {
      print("success");
    }).catchError((error) {
      print(error);
      _showAlertDialog(
          'Error: UNANSLISTDB', 'Problem Saving Answer ');
    } );

    returnToMainPage();


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





