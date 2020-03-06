import 'package:bits_grievance/historydisp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'historydisp.dart';
class CustomCard extends StatelessWidget {
  CustomCard({@required this.doc, this.description, this.category, this.subject, this.status});

  final doc;
  final description;
  final category;
  final subject;
  final status;

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: <Widget>[
                Text("Form ID: "+doc),
                FlatButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    child: Text("See More"),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => historydisplay(doc: doc,  description: description, category: category, subject: subject, status: status,)));
                    }),
              ],
            )
        )
    );
  }
}

class display extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: new AppBar(
          title: new Text("History", style: TextStyle(color: Colors.white)),
          iconTheme: new IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('Forms').where("02 Enrollment No",isEqualTo: s).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                if (!snapshot.hasData && snapshot.data.documents == null) return new Text('No forms are available now!!!\n\nPlease try again later.',style: TextStyle(fontSize: 15));
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text('Retrieving Forms...',style: TextStyle(fontSize: 20),);
                  default:
                    return new ListView(
                      children: snapshot.data.documents.map((DocumentSnapshot document) {
                        return CustomCard(
                          doc: document.documentID,
                          category: document['07 Category'],
                          subject: document['08 Subject'],
                          description: document['09 Description'],
                          status: document['10 Status'],

                        );
                      }).toList(),
                    );
                }
              },
            ),
          ),
        ),
      );
  }
}