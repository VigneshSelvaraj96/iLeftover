import 'package:flutter/material.dart';
import 'auth.dart';
import 'state1.dart';
import 'state2.dart';
import 'maps.dart';
import 'chathome.dart';

int homePageNumber = 0;

class HomePage2 extends StatefulWidget {
  HomePage2({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() => new _HomePage2State();
    void _signOut() async {
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  static void goHome () async
  {
    homePageNumber = 0;
  }
}



class _HomePage2State extends State<HomePage2>{

  void changePage(int pageNum) {
    setState(() {
      homePageNumber = pageNum;
    });
  }

  void defaultPage() {
    setState(() {
      homePageNumber = 0;
    });
  }
  
  @override 
  Widget build(BuildContext context){
    switch(homePageNumber){
      case 0:
        return new Scaffold(
          appBar: new AppBar(
            backgroundColor: Color(0xFFCAE1FF),
            actions: <Widget>[
            new FlatButton(
                child: new Text('Logout', style: new TextStyle(fontSize: 17.0, color: Colors.black)),
                onPressed: widget._signOut
              )
            ],
          ),
          body: new Container(
            
            child: new Container(
              child: Column(
                
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                      'Assets/LOGO.png',
                      width: 300,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                    ],
                  ),
                    new Container(
                        child: Center(
                            child: new Column(
                              children: <Widget>[
                                new Padding(padding: EdgeInsets.only(top: 15.0)),
                                  new RawMaterialButton(
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                      new Icon(
                                      Icons.local_offer,
                                      color: Colors.white,
                                      size: 50.0
                                      ),
                                      new Text(
                                        'Donate',
                                        style: TextStyle(fontSize: 40, color: Colors.black)
                                      ),
                                    ]
                                    ),
                                    onPressed: () => changePage(1),
                                    shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(40),),
                                    elevation: 2.0,
                                    fillColor: Colors.red[200],
                                    padding: const EdgeInsets.all(15.0),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 15.0)),
                                  new RawMaterialButton(
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                      new Icon(
                                      Icons.fastfood,
                                      color: Colors.white,
                                      size: 50.0
                                      ),
                                      new Text(
                                        'Reserve Food',
                                        style: TextStyle(fontSize: 40, color: Colors.black)
                                      ),
                                    ]
                                    ),
                                    onPressed: () => changePage(2),
                                    shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                    elevation: 2.0,
                                    fillColor: Color(0xFF84D9FF),
                                    padding: const EdgeInsets.all(15.0),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 15.0)),
                                  new RawMaterialButton(
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                      new Icon(
                                      Icons.map,
                                      color: Colors.white,
                                      size: 50.0
                                      ),
                                      new Text(
                                        'Explore',
                                        style: TextStyle(fontSize: 40, color: Colors.black)
                                      ),
                                    ]
                                    ),
                                    onPressed: () => changePage(3),
                                    shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                    elevation: 2.0,
                                    fillColor: Colors.red[200],
                                    padding: const EdgeInsets.all(15.0),
                                  ),
                                   Padding(padding: EdgeInsets.only(top: 15.0)),
                                   new RawMaterialButton(
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                      new Icon(
                                      Icons.chat_bubble,
                                      color: Colors.white,
                                      size: 50.0
                                      ),
                                      new Text(
                                        'Chats',
                                        style: TextStyle(fontSize: 40, color: Colors.black)
                                      ),
                                    ]
                                    ),
                                    onPressed: () { Navigator.push(
                                      context, MaterialPageRoute(
                                        builder: (context) => Chathomepage(widget.auth)),
                                        );},
                                        
                                    shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                    elevation: 2.0,
                                    fillColor: Color(0xFF84D9FF),
                                    padding: const EdgeInsets.all(15.0),
                                  ),
                                ],
                              )
                          ),
                      ),
                ],
              )
            ),
          ),
        );
      case 1:
       return new Page1(
         auth: widget.auth,
         onSignedOut: widget._signOut,
         goBack: defaultPage
      );
      case 2:
       return new Page2(
         auth: widget.auth,
         onSignedOut: widget._signOut,
         goBack: defaultPage
      );
      case 3:
       return new Page3(
         auth: widget.auth,
         onSignedOut: widget._signOut,
         goBack: defaultPage     
      );
    }
  }
}