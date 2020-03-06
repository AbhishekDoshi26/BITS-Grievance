import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'formdetail.dart';

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
                              builder: (context) => FormDetail(doc: doc, description: description, category: category, subject: subject,)));
                    }),
              ],
            )
        )
    );
  }
}

class Admindisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Grievances Forms'),
        ),
        body: Center(
          child: Container(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('Forms').where("10 Status",isEqualTo: "Open").snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  if (!snapshot.hasData && snapshot.data.documents == null) return new Text('No open forms are available now!!!\n\nPlease try again later.',style: TextStyle(fontSize: 15));
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return new Text('Retrieving Forms...',style: TextStyle(fontSize: 20),);
                    default:
                      return new ListView(
                        children: snapshot.data.documents.map((DocumentSnapshot document) {
                          return new CustomCard(
                            doc: document.documentID,
                            category: document['07 Category'],
                            subject: document['08 Subject'],
                            description: document['09 Description'],
                            status: document['10 Status']
                          );
                        }).toList(),
                      );
                  }
                },
              ),
          ),
        ),
      ),
    );
  }
}