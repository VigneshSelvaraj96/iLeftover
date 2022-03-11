import 'package:flutter/material.dart';
import 'auth.dart';

class Page4 extends StatefulWidget {
  Page4({this.auth, this.onSignedOut, this.goBack});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final VoidCallback goBack;

  @override
  State<StatefulWidget> createState() => new _Page4PageState();
  void _signOut() async {
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}

class _Page4PageState extends State<Page4>{

  @override
    Widget build(BuildContext context)
    {
      return new Scaffold(
          appBar: new AppBar(
            backgroundColor: Color(0xFFCAE1FF),
            leading: new FlatButton(
            child: new IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: widget.goBack,
            ),
              onPressed: widget.goBack 
            ),
            actions: <Widget>[
            new FlatButton(
                child: new Text('Logout', style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: widget._signOut
              )
            ],
          ),
          body: new Container(
            decoration: BoxDecoration(
             
            ),
            child: new Container(
              child: new Center(
                child: new Column(
                  children: <Widget>[
                    new Padding(padding: EdgeInsets.fromLTRB(15.0, 140.0, 15.0, 0.0)),
                      new Text(
                         'Mission Statement:',
                          style: new TextStyle(color: Color(0xFF56748B), fontSize: 20.0),
                      ),
                     new Padding(padding: EdgeInsets.only(top: 20.0)),
                     new Text(
                         'Our Mission is to organize world’s food information and make it universally accessible and useful.',
                          style: new TextStyle(color: Color(0xFF7BA5C6), fontSize: 20.0),
                          textAlign: TextAlign.center,
                      ),
                      new Padding(padding: EdgeInsets.only(top: 20.0)),
                      new Text(
                         'iLeftOver LLC was created in the first quarter of 2020. Though we are an early company we have rose above the rest of the food savior genre. Our goal is creating a platform that can motivate users and neighbors to be sustainable with their food excess. A simple task at first, we teach these rules of sustainability to make a more green and healthy Earth. ',
                          style: new TextStyle(color: Color(0xFF7BA5C6), fontSize: 20.0),
                          textAlign: TextAlign.center,
                      ),
                      new Padding(padding: EdgeInsets.only(top: 20.0)),
                      new Text(
                         'Lefties Out! Yeet! Yeet!',
                          style: new TextStyle(color: Color(0xFF7BA5C6), fontSize: 20.0),
                      ),
                      
                    ],
                  )
              ),
            )
          ),
      );
    }
}