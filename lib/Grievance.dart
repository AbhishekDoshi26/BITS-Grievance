import 'package:bits_grievance/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: camel_case_types
class grievance extends StatefulWidget {
  grievance({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _grievancestate createState() => new _grievancestate();
}

// ignore: camel_case_types
class _grievancestate extends State<grievance> {
  final db=Firestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser user;
  final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'genericEmail');
  String emailAddress;
  String pass;
  String doc;

  List<String> _categories = <String>['', "Complaints", "Feedback", "Suggestions"];
  String _category = '';
  TextEditingController _description = new TextEditingController();
  TextEditingController _subject = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
    auth.onAuthStateChanged.listen((u) {
      setState(() => user = u);
    });
  }

  sendEmail() {
      return callable.call({
        'user': '$s',
        'text': "Thanks for contacting us!\nYour request ["+doc+"] has been received and we\'ll get back to you as soon as possible.\n\nYour form details are as following,\n1. Category: $_categories\n2. Subject: "+_subject.text+"\n3. Description: "+_description.text,
      }).then((res) => print(res.data));
  }

  void submit()  async{
    if(_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Map<String,dynamic> data = <String,dynamic>{
        "07 Category": '$_category',
        "08 Subject": _subject.text,
        "09 Description": _description.text,
        "03 First Name": fname,
        "04 Last Name": lname,
        "02 Enrollment No": '$s',
        "05 Branch": branch,
        "06 Semester": sem,
        "01 Submitted On": Timestamp.now(),
        "10 Status": 'Open',
      };
      final docId= await db.collection("Forms").add(data).whenComplete(() {
        print("Form Added");
      }).catchError((e) => print(e));
      doc=docId.documentID;
      db.collection("Users").document("$s").get().then((datasnapshot) {
        if(datasnapshot.exists) {
          emailAddress = datasnapshot.data["Email Id"];
          pass = datasnapshot.data["Password"];
        }
      }).catchError((e1) => print(e1));
      print(emailAddress);
      print(pass);
      auth.createUserWithEmailAndPassword(email: emailAddress, password: pass);
      sendEmail();
      Toast.show("Form Submitted Successfully", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      Navigator.of(context).pop();
      auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: new AppBar(
        title: new Text("Grievances Form", style: TextStyle(color: Colors.white)),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      body: new SafeArea(
        top: false,
        bottom: false,
        child: new Form(
          key: _formKey,
          child: new ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              new FormField(
                builder: (FormFieldState state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.category),
                      labelText: 'Category',
                    ),
                    isEmpty: _category == '',
                    child: new DropdownButtonHideUnderline(
                      child: new DropdownButton(
                        value: _category,
                        isDense: true,
                        onChanged: (String newValue) {
                          setState(() {
                            _category = newValue;
                            print(newValue);
                            state.didChange(newValue);
                          });
                        },
                        items: _categories.map((String value) {
                          return new DropdownMenuItem(
                            value: value,
                            child: new Text(value, style: TextStyle(color: Colors.black),),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              new TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.subject),
                  hintText: 'Eg: Complaint regarding lectures',
                  labelText: 'Subject',
                ),
                validator: (value) {
                  if(value.isEmpty)
                    return 'Please enter subject';
                  return null;
                },
                controller: _subject,
                textCapitalization: TextCapitalization.sentences,
              ),
              new TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.description), alignLabelWithHint: true,
                  hintText: 'Enter complete details for the complaint/feedback/suggestions',
                  labelText: 'Description',
                ),
                validator: (value) {
                  if(value.isEmpty)
                    return 'Please enter description';
                  return null;
                },
                controller: _description,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                maxLength: 1000,
                maxLengthEnforced: true,
              ),
              new Container(
                  padding: const EdgeInsets.only(top: 20, left: 110, right: 110),
                  child: new MaterialButton(
                    color: Colors.lightBlueAccent,
                    textColor: Colors.white,
                    child: Text('Submit', style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    splashColor: Colors.lightBlue,
                    onPressed: submit,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}