import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutelage_student/home.dart';
import 'package:tutelage_student/signin/signinorup.dart';

class LoginPage extends StatefulWidget {

  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String email, password;
//Firebase doesnt support custom usernames, username must be in form of email
//final GlobalKey<FormState> _formkey = GlobalKey<FormState> ();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      backgroundColor: Colors.blue[600],
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Log In",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 50,
            ),

            TextField(
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => email = value.trim(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white70,
                hintText: "Enter your email",
                border: const OutlineInputBorder(),
              ),
            ),

            SizedBox(
              height: 20,
            ),

            TextField(
              autocorrect: false,
              obscureText: true,
              onChanged: (value) => password = value,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white70,
                hintText: "Enter your password",
                border: const OutlineInputBorder(),
              ),
            ),

            SizedBox(
              height: 20,
            ),

            PageButton(
              title: "Sign In",
              callback: signIn,
            ),

          ], ),
      ),

    );



//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("Sign In"),
//        centerTitle: true,
//      ),
//      body: Form(
//        key: _formkey,
//        child: Column(
//          children: <Widget>[
//            TextFormField(
//              //keyboardType: TextInputType.emailAddress,
//              validator: (input){
//               if (input.isEmpty) {
//                 return 'Please input Username';
//               }
//              },
//              onSaved: (input) => username = input,
//              decoration: InputDecoration(
//                labelText: 'Username' ,
//              ),
//            ),
//
//            TextFormField(
//              validator: (input){
//                if (input.length < 6) {
//                  return 'Your password needs to be at least 6 characters long';
//                }
//              },
//              onSaved: (input) => password = input,
//              decoration: InputDecoration(
//                labelText: 'Password' ,
//              ),
//              obscureText: true,
//            ),
//            RaisedButton(
//            onPressed: signIn,
//              child: Text('Sign In'),
//            ),
//          ],
//        ),
//
//      ),
//    );
  }

  Future<void> signIn() async{
    try {
      FirebaseUser user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)).user;
      Navigator.push(context, MaterialPageRoute(builder: (context)=> MainPage(user: user)));
    } catch (e) {
      _showAlertDialog("ERROR",e.message);
    }

  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }
}