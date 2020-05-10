import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddQuestion extends StatefulWidget {

  final FirebaseUser user;
  AddQuestion(this.user);

  @override
  State<StatefulWidget> createState() {

    return AddQuestionState(this.user);
  }
}

class AddQuestionState extends State<AddQuestion> {

  FirebaseUser user;
  AddQuestionState(this.user);

  // Camera API
  File _image;
  //URL for uploaded image
  String _uploadedFileURL; //unused

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera,imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  String subjectValue ;
  String levelValue ;
  int counter;



  static var _subject = [
    "English",
    "Math",
    "Physics",
    "Chemistry",
    "Biology",
    "Science"
  ];
  static var _level = [
    "P1",
    "P2",
    "P3",
    "P4",
    "P5",
    "P6",
    "Sec 1",
    "Sec 2",
    "Sec 3",
    "Sec 4",
    "Sec 5",
  ];


  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return WillPopScope(

        onWillPop: () {
          moveToLastScreen();
        },

        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Add Question",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
            backgroundColor: Colors.blue[600],
            leading: IconButton(icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
                onPressed: () {
                  // Write some code to control things, when user press back button in AppBar
                  moveToLastScreen();
                }
            ),
          ),

          body: Padding(
            padding: EdgeInsets.all(10.0),
            child: ListView(
              children: <Widget>[


                // First Element
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: titleController,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Field');
                    },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)
                        )
                    ),
                  ),
                ),

                // Second Element
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: null,
                    controller: descriptionController,
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)
                        )
                    ),
                  ),
                ),


                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      DropdownButton(
                          items: _subject.map((String dropDownStringItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            );
                          }).toList(),
                          value: subjectValue,
                          hint: Text("Select Subject"),
                          onChanged: (NewValue) {
                            setState(() {
                              debugPrint('Selected $NewValue');
                              updateSubject(NewValue);
                              subjectValue = NewValue;
                            });
                          }
                      ),

                      Container(width: 10.0,),

                      DropdownButton(
                          items: _level.map((String dropDownStringItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem,
                                style: TextStyle(
                                  fontSize: 20,
                                ),),
                            );
                          }).toList(),
                          hint: Text("Select Level"),
                          value: levelValue,
                          onChanged: (NewValue) {
                            setState(() {
                              debugPrint('Selected $NewValue');
                              levelValue = NewValue;
                            });
                          }
                      ),


                    ],
                  ),
                ),


                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          onPressed: () {
                            getImage();
                            debugPrint("Image Pressed");
                          },
                          color: Colors.blue[400],
                          child: Text(
                            "Attach Image",
                            style: TextStyle(color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                    padding: EdgeInsets.all(10.0),
                    child:
                    _image == null
                        ? Text(
                      "No Image Selected", textAlign: TextAlign.center,)
                        : Image.file(_image)
                ),
                // Upload image option
                //  Padding(
                //    padding: EdgeInsets.all(10.0),
                //    child: _image == null
                //    ? Text("")
                //    : _uploadedFileURL == null
                //    ? RaisedButton(
                //      color: Colors.teal,
                //      textColor: Colors.black,
                //      child: Text(
                //        "Upload Picture",
                //        textScaleFactor: 0.75,
                //        ),
                //        onPressed: () => ,
                //    )

                //  ),
                //Buttons below
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Colors.lightGreenAccent.shade100,
                          textColor: Colors.black,
                          child: Text(
                            'Send',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Send button clicked");
                              obtainCounterThenSave();
                            });
                          },
                        ),
                      ),

                      Container(width: 10.0,),

                      Expanded(
                        child: RaisedButton(
                          color: Colors.red[300],
                          textColor: Colors.black,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,

                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Delete button clicked");
                              _delete();
                            });
                          },
                        ),
                      ),

                    ],
                  ),
                ),

              ],
            ),
          ),

        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updateSubject(String value) {
    subjectValue = value;
  }

  void updateLevel(String value) {
    levelValue = value;
  }



//  Future<int> obtainCounter(String usernameCategory) async{
//
//    var db = await Firestore.instance
//        .collection("askedquestions")
//        .document(usernameCategory)
//        .collection("questions")
//        .document("allTimeQuestionCounter").get();
//    db.data["counter"].then((value) {
//        if (value.exists) {
//          counter = value;
//        } else counter = 0;
//    }).catchError((error) {
//      print(error);
//      _showAlertDialog(
//          'Error: Counter ', 'Error Sending Question ');
//    } );
//  }

  void obtainCounterThenSave() async{


    final DocumentReference whatIsCounter = await Firestore.instance
        .collection("askedquestions")
        .document("user_" + user.email)
        .collection("questions").document("allTimeQuestionCounter");

    whatIsCounter.get().then( (data) {
      int counter = data['counter'];
      _save(counter);
    }).catchError((error) {
      print(error);
      _showAlertDialog(
          'Error Status Counter ID', 'Problem Saving Question ');
    } );

  }


  void _save(int finalIdNumber) async {

    String usernameCategory = "user_" + user.email ;
    String questionID = user.email + "_qnID" + "_" + finalIdNumber.toString();
    if(_image!=null)uploadPicture(questionID);
    // debugPrint("uploadFileURL = "+_uploadedFileURL);
    //save to personal database
    if (titleController.text.isNotEmpty
        && descriptionController.text.isNotEmpty
        && !(subjectValue == null)
        && !(levelValue == null)) {
      Firestore.instance.collection("askedquestions")
          .document(usernameCategory)
          .collection("questions").document(questionID).setData(
          {"title": titleController.text,
            "description": descriptionController.text,
            "timestamp": new DateFormat.yMMMd().add_jm().format(DateTime.now()),
            "subject": subjectValue,
            "level": levelValue,
            "askedBy" : user.email,
          }
      ).then((response) {
        print("success");
      }).catchError((error) {
        print(error);
        _showAlertDialog(
            'Error Status Local', 'Problem Saving Question ');
      } );
//update id counter
      Firestore.instance.collection("askedquestions")
          .document(usernameCategory)
          .collection("questions")
          .document("allTimeQuestionCounter")
          .setData(
          {'counter': finalIdNumber + 1 ,}
      ).then((response) {
        print("success");
      }).catchError((error) {
        print(error);
        _showAlertDialog(
            'Error Status Global', 'Problem Saving Question');
      } );


      // save to global database: list of question from all users
      Firestore.instance.collection("unansweredquestionlist")
          .document(questionID)
          .setData(
          { "title": titleController.text,
            "description": descriptionController.text,
            "timestamp": new DateFormat.yMMMd().add_jm().format(DateTime.now()),
            "subject": subjectValue,
            "level": levelValue,
            "askedBy" : user.email,
            "askedOrAnswered" : 'questions',
          }
      ).then((response) {
        print("success");
      }).catchError((error) {
        print(error);
        _showAlertDialog(
            'Error Status Global', 'Problem Saving Question');
      } );
      moveToLastScreen();
    } else { // Failure
      _showAlertDialog(
          'Error Status', 'Problem Saving Question, Make Sure all fields are filled');
    }

  }

  void uploadPicture(String questionID) {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('questions/${questionID}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    uploadTask.onComplete;
    storageReference.getDownloadURL().then((value) => {
      setState(() {
        // _uploadedFileURL = value; //unused
        debugPrint(value);
      }
      )
    });
  }
  // Save data to personal user database OLD VERSION
//  void _save(int finalIdNumber) async {
//    String usernameCategory = "user_" + user.email ;
//
//      if(finalIdNumber == null){
//        finalIdNumber = 0;
//      } else finalIdNumber = finalIdNumber;
//
//    String questionID = user.email + "_qnID" + "_" + finalIdNumber.toString();
//
//    //save to personal database
//    if (titleController.text.isNotEmpty
//        && descriptionController.text.isNotEmpty
//        && !(subjectValue == null)
//        && !(levelValue == null)) {
//      Firestore.instance.collection("askedquestions")
//          .document(usernameCategory)
//          .collection("questions").document(questionID).setData(
//          {"title": titleController.text,
//            "description": descriptionController.text,
//            "timestamp": new DateFormat.yMMMd().add_jm().format(DateTime.now()),
//            "subject": subjectValue,
//            "level": levelValue,
//            "askedBy" : user.email,
//          }
//      ).then((response) {
//        print("success");
//      }).catchError((error) {
//        print(error);
//        _showAlertDialog(
//            'Error Status Local', 'Problem Saving Question ');
//      } );
////update id counter
//      Firestore.instance.collection("askedquestions")
//          .document(usernameCategory)
//          .collection("questions")
//          .document("allTimeQuestionCounter")
//          .setData(
//          {'counter': finalIdNumber + 1 ,}
//      ).then((response) {
//        print("success");
//      }).catchError((error) {
//        print(error);
//        _showAlertDialog(
//            'Error Status Global', 'Problem Saving Question');
//      } );
//
//
//      // save to global database: list of question from all users
//        Firestore.instance.collection("unansweredquestionlist")
//            .document(questionID)
//            .setData(
//            { "title": titleController.text,
//              "description": descriptionController.text,
//              "timestamp": new DateFormat.yMMMd().add_jm().format(DateTime.now()),
//              "subject": subjectValue,
//              "level": levelValue,
//              "askedBy" : user.email,
//              "askedOrAnswered" : 'questions',
//            }
//        ).then((response) {
//          print("success");
//        }).catchError((error) {
//          print(error);
//          _showAlertDialog(
//              'Error Status Global', 'Problem Saving Question');
//        } );
//      moveToLastScreen();
//    } else { // Failure
//      _showAlertDialog(
//          'Error Status', 'Problem Saving Question, Make Sure all fields are filled');
//    }
//
//  }


  void _delete() async {
    moveToLastScreen();
    debugPrint("Deleted button pressed");
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






//grabs all documents from database before counting number of documents
//To find more efficient way to count documents
//List<DocumentSnapshot> docCount = (await questionDB.getDocuments()).documents ;

//String numberOfQns = docCount.length.toString();



