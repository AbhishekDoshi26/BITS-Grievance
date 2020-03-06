import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class contactus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Contact Us", style: TextStyle(color: Colors.white)),
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
                padding: EdgeInsets.all(8.0),
                child: Text(
                  """\nVadodara-Mumbai NH#8, Varnama, Vadodara-391240 Gujarat, India.\n\nCollege Phone Number:\n+91 – 265 – 2303991/2/3\n8238077699\nFax No. : +91 – 265 – 2359999\n""",
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                  softWrap: true,
                  textAlign: TextAlign.justify,),
              ),
            ],
          ),
        ],
      ),
    );
  }
}