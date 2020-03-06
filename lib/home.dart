import 'dart:io';
import 'package:bits_grievance/history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'contactus.dart';
import 'main.dart';
import 'package:toast/toast.dart';
import 'Grievance.dart';
import 'package:firebase_auth/firebase_auth.dart';
final db=Firestore.instance;
// ignore: camel_case_types
class drawer1 extends StatelessWidget
{
  drawer1();

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Home Page",style: TextStyle(color: Colors.white)),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: <Widget>[
          Image(
            image: AssetImage("assets/pic.png"),
            width: size.width,
            height: size.height,
            fit: BoxFit.fill,
            color: Colors.black54, //lightens the image
            colorBlendMode: BlendMode.darken,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text("""\n\nThe Student's Grievance App helps the students of BITS EDU CAMPUS to lodge/file any\n\n#Complaints\n#Feedback\n#Suggestions\n\nThis grievance will be viewed by the authorities of the college.\nPlease submit only valid grievances.""",
                    style: TextStyle(fontSize: 20,color: Colors.white),softWrap: true,textAlign: TextAlign.justify),
              ),
              MaterialButton(
                color: Colors.lightBlueAccent,
                textColor: Colors.white,
                child: Text("Grievances Form"),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                splashColor: Colors.lightBlue,
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => grievance()
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                padding: EdgeInsets.zero,
                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.lightBlue),
                  accountName: Text("$fname $lname\n"+s,style: TextStyle(fontSize: 18.0),),
                  currentAccountPicture: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      image: DecorationImage(fit: BoxFit.fill,
                          image: AssetImage("assets/pic2.jpeg")),
                    ),
                  ),
                  accountEmail: null,
                ),
              ),
              ListTile(
                title: Text('Home'),
                leading: Icon(Icons.home,color: Colors.redAccent),
                onTap: () {
                  drawer1();
                  Navigator.pop(context);
                },
              ),

              ListTile(
                title: Text('Grievance Form'),
                leading: Icon(Icons.comment,color: Colors.green,),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => grievance()
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('History'),
                leading: Icon(Icons.history,color: Colors.orange,),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => display()
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('Contact Us'),
                leading: Icon(Icons.contacts,color: Colors.blueAccent),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => contactus()
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('Log Out'),
                leading: Icon(Icons.exit_to_app,color: Colors.black,),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Toast.show("You have successfully Logged Out", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  Navigator.of(context).pop();
                  Future.delayed(const Duration(milliseconds: 500), () {
                    exit(1);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
