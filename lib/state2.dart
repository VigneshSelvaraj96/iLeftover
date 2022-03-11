import 'package:fancy_dialog/FancyAnimation.dart';
import 'package:fancy_dialog/FancyGif.dart';
import 'package:fancy_dialog/FancyTheme.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_savior/chat2.dart';
import 'auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat2.dart';
import 'package:fancy_dialog/fancy_dialog.dart';
import 'package:geolocator/geolocator.dart';

class Page2 extends StatefulWidget {
  Page2({this.auth, this.onSignedOut, this.goBack});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final VoidCallback goBack;

  @override
  State<StatefulWidget> createState() => new _Page2PageState();
  void _signOut() async {
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}


class _Page2PageState extends State<Page2>{

  Future _getcurrlocation() async { 
  return Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  updatelocation() async {
    position = await _getcurrlocation();
    setState(() {
      _currlatitude = position.latitude;
        _currlongitude = position.longitude;
    });
  }

  Position position;
  double _currlatitude = 0, _currlongitude= 0;

  void initState()  {
    super.initState();
    updatelocation();  
    WidgetsBinding.instance
            .addPostFrameCallback((_) => showDialog(
              context: context,
              builder: (BuildContext context)=> FancyDialog(
                title: 'Reservation Proximity',
                descreption: "Limiting reservations to within a 7 mile radius so everyone else can have a piece of the pie! ",
                ok: 'Confirm',
                cancel: 'Sure! ',
                cancelColor: Color(0xFF8784C7),
                animationType: FancyAnimation.TOP_BOTTOM,
                gifPath: FancyGif.FUNNY_MAN,
                theme: FancyTheme.FANCY,
            )));  
  }


  @override
    Widget build(BuildContext context)
    { 
      return new Scaffold(
         appBar: AppBar(
          leading: new FlatButton(
            child: new IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: widget.goBack,
            ),
              onPressed: widget.goBack 
            ),
          backgroundColor: Color(0xFFCAE1FF),
            actions: <Widget>[
            new FlatButton(
                child: new Text('Logout', style: new TextStyle(fontSize: 17.0, color: Colors.black)),
                onPressed: widget._signOut
              )
            ],
        ),
          body: StreamBuilder(
            stream: Firestore.instance.collection("foodnew").snapshots(),
            builder: (context,snapshot) { 
                if(!snapshot.hasData) 
                return Center(child: 
                Text('...Fetching data...!',style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.italic
                ),)
                );
              else if (snapshot.data.documents.length == 0) {
                return Center(child: 
                Text('No Active Reservations!',style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.italic
                ),)
                );
              }
              return new ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context,index){
                  DocumentSnapshot ds = snapshot.data.documents[index];
                  if( ds['latitude'] < (_currlatitude - 0.1) || ds['latitude'] > (_currlatitude + 0.1) ||
                    ds['longitude'] < (_currlongitude - 0.1) || ds['longitude'] > (_currlongitude + 0.1)) return SizedBox(height: 10,);                         
                  return Stack(
                    children: <Widget>[
                      Column(children: <Widget>[
                      Card(
                      elevation: 10,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                       color: Colors.white,
                       child: Center(child:Column(children:<Widget>[
                         Container(
                           width: MediaQuery.of(context).size.width,
                           height: 200,
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(30),
                           ),
                           child: ClipRRect(
                             borderRadius: BorderRadius.only(
                               topLeft: Radius.circular(30),
                               topRight: Radius.circular(30),
                             ),
                              child: Image.network(
                                '${ds['Image']}',
                                fit: BoxFit.fill
                              ),
                           ),
                         ),
                         SizedBox(height: 10.0),
                         Text('${ds['Name']}',
                         style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                         ),
                         SizedBox(height: 10.0),
                         Text('${ds['Description']}',
                         style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal,),
                         ),
                         SizedBox(height: 20,),
                         Padding(
                           padding: const EdgeInsets.only(
                             right: 10,
                           ),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.end,
                             children: <Widget>[
                               RaisedButton(
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                 color: Colors.redAccent,
                                 onPressed: () async{
                                   String uidfrom = await widget.auth.getuid();
                                   String uidto = ds['doneruid'];
                                   String temp = uidfrom + uidto;
                                   int groupchatid = temp.hashCode;
                                   Navigator.push(context, MaterialPageRoute(builder: (context)=>new ChatScreen(
                                     groupid: groupchatid,
                                     uidreceiver: uidfrom,
                                     uiddoner: uidto,
                                     auth: widget.auth,)));
                                 },
                                 child: Row(
                                   children: <Widget>[
                                     Icon(Icons.chat_bubble_outline),
                                     Text('Chat')
                                     ],
                                   )
                                 ),
                                 SizedBox(width:20),
                                 RaisedButton(
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                 color: Colors.greenAccent,
                                 onPressed: (){
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context)=> FancyDialog(
                                      title: 'Food Reservation',
                                      descreption: "Confirm Selection?",
                                      ok: 'Confirm',
                                      cancel: 'No',
                                      animationType: FancyAnimation.BOTTOM_TOP,
                                      gifPath: FancyGif.MOVE_FORWARD,
                                      theme: FancyTheme.FANCY,
                                      okFun: (){
                                        _reserveupdate(ds.documentID);
                                         _movedocument(ds.documentID);
                                         setState(() {
                                           
                                         });
                                      },
                                    )
                                    );
                                 },
                                /* onPressed: (){
                                   showDialog(
                                     context: context,
                                     barrierDismissible: false,
                                     builder: (BuildContext context) {
                                       return AlertDialog(
                                         backgroundColor: Color(0xFFCAE1FF),
                                         title: Text('Food Reservation', textAlign: TextAlign.center,),
                                         content: Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                                           children: <Widget>[
                                             Text('Food Reserved!'),
                                             RaisedButton(
                                               onPressed: (){
                                                 _reserveupdate(ds.documentID);
                                                 _movedocument(ds.documentID);
                                                 Navigator.of(context).pop();
                                                 setState(() {
                                                   
                                                 });},
                                               color: Colors.greenAccent,
                                               child: Row(
                                                 children: <Widget> [
                                                   Icon(Icons.arrow_back),
                                                   Text("Back"),
                                                 ],
                                               ),
                                               )
                                           ],
                                         ),
                                       );
                                     }
                                     );
                                   },*/
                                 child: Row(
                                   children: <Widget>[
                                     Icon(Icons.check_box),
                                     Text('Reserve')
                                     ],
                                 )
                                 )
                             ],
                           ),
                         ),
                         SizedBox(height:10)
                       ], 
                       ),
                       ),
                        ),
                      SizedBox(height:20)
                    ]),
                    ],
                    );
                }
              );
            },
          ),
      );
    }
    
    void _reserveupdate(String id)
    {
      final docref = Firestore.instance.collection('foodnew').document(id);
      docref.updateData({
        'Reserved': 'yes',
        'Complete': false,
        });

    }

    Future _movedocument(String id) async{
      String user = await widget.auth.getuid();
      CollectionReference userdoc =  Firestore.instance.collection('users').document(user).collection('reservedfood');
      DocumentReference copyfrom =  Firestore.instance.collection('foodnew').document(id);
      DocumentSnapshot copysnap = await copyfrom.get();
      String tempid = copysnap['doneruid'];
      CollectionReference donerdoc = Firestore.instance.collection('users').document(tempid).collection('reservedfood');
      await copyfrom.get().then((dataread){
        userdoc.document(id).setData(dataread.data);
        donerdoc.document(id).setData(dataread.data);
      });
      copyfrom.delete();
    } 
}