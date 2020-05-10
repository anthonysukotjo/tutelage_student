import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class chatPage extends StatefulWidget {

  final String ansID;
  final FirebaseUser user;

  chatPage(this.ansID, this.user);

  @override
  chatPageState createState() => new chatPageState(this.ansID, this.user);

}

class chatPageState extends State<chatPage> {

  String ansID;
  FirebaseUser user;
  chatPageState(this.ansID, this.user);


  final Firestore _firestore = Firestore.instance;


  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();


  Future<void> callback() async {
    if (messageController.text.isNotEmpty) {
      await _firestore
          .collection('askedquestions')
          .document('user_' + user.email )
          .collection("answers")
          .document(ansID)
          .collection("chats")
          .add({
        'text': messageController.text,
        'from': user.email,
        'timestamp': new DateFormat.yMMMd().add_jm().format(DateTime.now()),
        'date': DateTime.now().toIso8601String().toString(),
      });
      messageController.clear();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tutor Chat",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('askedquestions')
                    .document('user_' +user.email )
                    .collection("answers")
                    .document(ansID)
                    .collection("chats")
                    .orderBy('date', descending: false)
                    .snapshots(),

                builder: (context, snapshot){
                  if(!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  List<DocumentSnapshot> docs = snapshot.data.documents;

                  List<Widget> messages = docs
                      .map((doc) => Message(
                    timeStamp: doc.data['timestamp'],
                    text: doc.data['text'],
                    sender: user.email == doc.data['from'],
                  ))
                      .toList();

                  return ListView(
                    controller: scrollController,
                    children: <Widget>[
                      ...messages,
                    ],
                  );
                },
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onSubmitted: (value) => callback(),
                      controller: messageController,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                        hintText: 'Enter a message',
                        border: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                  ),

                  RawMaterialButton(

                    shape: CircleBorder(),
                    fillColor: Colors.lightGreen,
                    child: IconButton(
                      alignment: Alignment.center,
                      onPressed: () => callback(),
                      iconSize: 24.0,
                      icon: Icon(Icons.send),
                    ),

                  ),



                ],
              ),
            ),



          ],
        ),
      ),
    );
  }
}


class Message extends StatelessWidget {
  final String timeStamp;
  final String text;
  final bool sender;
  const Message({Key key, this.timeStamp, this.text, this.sender}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Column(
        //positions each message depending on who sent it,
        // if user is sender will be on the right else on left
        crossAxisAlignment: sender
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          Text(timeStamp),
          //changes color depending on who sent it,
          // if user is sender will be on the right else on left
          Material(
            color: sender
                ? Colors.lightBlueAccent
                : Colors.grey,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
              child: Text(text),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}









