import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'home.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin.dart';

bool ot;
String s='';
String fname;
String lname;
String branch;
String sem;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
      routes: <String, WidgetBuilder>{
        '/homepage': (BuildContext context) => drawer1(),
        '/loginpage': (BuildContext context) => MyApp(),
        '/admin': (BuildContext context) => Admindisplay(),
      },
      theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          accentColor: Colors.blueAccent
      ),
    );
  }
}

class Login extends StatefulWidget {
  @override
  State createState() => new loginpage();
}

// ignore: camel_case_types
class loginpage extends State<Login> with SingleTickerProviderStateMixin{

  TextEditingController _enrollmentController = new TextEditingController();
  TextEditingController _password = new TextEditingController();

  final db=Firestore.instance;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyPhone() async {
    Toast.show("OTP has been sent to your registered number. Please Wait...\n\nIf you don't receive otp, you have been blocked by our server for multiple logins in a day. Please try again after 24 hours", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsOTPDialog(context).then((value) {
        print('sign in');
      });
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo, // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent: smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (AuthException exceptio) {
            print('${exceptio.message}');
          });
    } catch (e) {
      handleError(e);
    }
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(15)),
            title: Text('Enter OTP',style: TextStyle(color: Colors.blue)),
            content: Container(
              padding: const EdgeInsets.only(left:15.0,right: 15),
              height: 85,
              child: Column(children: [
                TextField(
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onChanged: (value) {
                    this.smsOTP = value;
                  },
                ),
                Padding(padding: EdgeInsets.only(top: 10),),
                (errorMessage != '' ? Text(errorMessage, style: TextStyle(color: Colors.red),) : Container())
              ]),
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                child: Text('Done'),
                onPressed: () {
                  _auth.currentUser().then((user) {
                    if (user != null) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/homepage');
                      Toast.show("You have successfully signed in", context, duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
                    } else {
                      signIn();
                    }
                  });
                },
              )
            ],
          );
        });
  }

  signIn() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/homepage');
      Toast.show("You have successfully signed in", context, duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
    } catch (e) {
      handleError(e);
    }
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid OTP';
        });
        Navigator.of(context).pop();
        smsOTPDialog(context).then((value) {
          print('sign in');
        });
        break;
      case 'We have blocked all requests from this device due to unusual activity. Try again later.':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'You have been blocked by our server for multiple logins in a day. Please try again after 24 hours';
        });
        Navigator.of(context).pop();
        smsOTPDialog(context).then((value) {
          print('sign in');
        });
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });
        break;
    }
  }

  void change() async {
    String pass;
    s = _enrollmentController.text;
    if((s == "Admin") && _password.text == "admin")
      Navigator.of(context).pushReplacementNamed('/admin');
    if (_formKey.currentState.validate()) {
      DocumentReference documentReference = Firestore.instance.collection("Users").document("$s");
      documentReference.get().then((datasnapshot) {
        if (datasnapshot.exists) {
          pass = datasnapshot.data['Password'].toString();
          if (_password.text == pass) {
            branch = datasnapshot.data['Branch'].toString();
            phoneNo = datasnapshot.data['Phone Number'].toString();
            fname = datasnapshot.data['First Name'].toString();
            lname = datasnapshot.data['Last Name'].toString();
            sem = datasnapshot.data['Semester'].toString();
            verifyPhone();
          }
          else
            Toast.show("Invalid Password!!!", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        }
        else
          Toast.show("User not registered!!!", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
      );
    }
  }

  @override
  // ignore: must_call_super
  void initState() {
    ot = true;
    _enrollmentController.text=null;
    _password.text=null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image(
            image: AssetImage("assets/pic.png"),
            fit: BoxFit.cover,
            color: Colors.black54, //lightens the image
            colorBlendMode: BlendMode.darken,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                  key: _formKey,
                  child: Theme(
                    data: ThemeData(
                      brightness: Brightness.dark,
                      primaryColor: Colors.lightBlueAccent,
                      inputDecorationTheme: InputDecorationTheme(
                        labelStyle: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: (){ FocusScope.of(context).requestFocus(FocusNode()); },
                      child: Container(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                            ),
                            TextFormField(
                              autofocus: true,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(prefixIcon: Icon(Icons.person),hintText: 'Enrollment Number',
                                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                              ),
                              validator: (value){
                                if(value.isEmpty)
                                  return 'Please enter Enrollment Number';
                                return null;
                              },
                              controller: _enrollmentController,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                            ),
                            TextFormField(
                              autofocus: false,
                              obscureText: ot,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(prefixIcon: Icon(Icons.lock),hintText: 'Password',
                                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                                suffixIcon: GestureDetector(
                                  onTap: () { setState(() {ot = !ot;}); },
                                  child: Icon(ot ? Icons.visibility : Icons.visibility_off,
                                    semanticLabel: ot ? 'show password' : 'hide password',
                                  ),
                                ),
                              ),
                              validator: (value){
                                if(value.isEmpty)
                                  return 'Please enter Password';
                                return null;
                              },
                              controller: _password,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                            ),
                            MaterialButton(
                              color: Colors.tealAccent,
                              textColor: Colors.black,
                              child: Text('Verify',style: TextStyle(fontWeight: FontWeight.bold)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              onPressed: change,
                              splashColor: Colors.teal,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                FlatButton(
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  onPressed: () async { launch('https://bits-grievance-1c10f.firebaseapp.com/resetPassword.html'); },
                                  child: Text('Forgot Password', style: TextStyle(color: Colors.white70)),
                                ),
                                Text("|"),
                                FlatButton(
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  onPressed: () async { launch('https://bits-grievance-1c10f.firebaseapp.com/registration.html'); },
                                  child: Text('Register Now', style: TextStyle(color: Colors.tealAccent)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
              ),
            ],
          )
        ],
      ),
    );
  }
}