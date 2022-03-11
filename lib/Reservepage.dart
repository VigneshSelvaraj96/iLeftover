import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fancy_dialog/fancy_dialog.dart';
import 'package:fancy_dialog/FancyAnimation.dart';
import 'package:fancy_dialog/FancyGif.dart';
import 'package:fancy_dialog/FancyTheme.dart';
import 'chat2.dart';



class Reservepage extends StatefulWidget {
  Reservepage({this.auth, this.onSignedOut, this.goBack});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final VoidCallback goBack;
  

  @override
  State<StatefulWidget> createState() => new _ReservepageState();
  void _signOut() async {
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}

class _ReservepageState extends State<Reservepage>{
  String uid;
   Widget _buildstatus(bool value){
          if(value){
           return Icon(MaterialIcons.check_circle);
          }
          else return null;
        }
  @override 
  Widget build(BuildContext context){
   getuid();
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
                child: new Text('Logout', style: new TextStyle(fontSize: 17.0, color: Colors.black)),
                onPressed: widget._signOut
              )
            ],
          ),
          body: StreamBuilder(
            stream: Firestore.instance.collection("users").document(uid).collection('reservedfood').orderBy('Complete').snapshots(),
            builder: (context,snapshot) {
              if(!snapshot.hasData) 
                return Center(child: 
                Text('No Active Reservations!',
                style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.italic
                ),
                )
                );
               {
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context,index){
                  DocumentSnapshot ds = snapshot.data.documents[index];
                  return Container(
                    height: 130,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                                    context: context,
                                    builder: (BuildContext context)=> FancyDialog(
                                      title: 'Food Status Update',
                                      descreption: "Click the icons below to indicate completion or to chat!",
                                      ok: 'Finished',
                                      okColor: Color(0xFF6469E5),
                                      cancel: 'Chat',
                                      cancelFun: () async{
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
                                      cancelColor: Color(0xFF6A8A87),
                                      animationType: FancyAnimation.BOTTOM_TOP,
                                      gifPath: FancyGif.CHECK_MAIL,
                                      theme: FancyTheme.FANCY, 
                                      okFun: (){
                                        String docnum =ds.documentID;
                                        DocumentReference ref =  Firestore.instance.collection("users").document(uid).collection('reservedfood').document(docnum);
                                        ref.updateData({
                                          'Complete': true,
                                        });
                                        setState(() {
                                          
                                        });
                                      },
                                    ),
                          );
                        },
                         child: Card(
                          elevation: 5.0,
                          color: Colors.red[100],
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black87, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height:115,
                                  width:115,
                                  child: Image.network('${ds['Image']}',fit: BoxFit.fill,),
                                ),
                                SizedBox(width:80),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text('${ds['Name']}',style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),),
                                   /* Text('${ds['Description']}',style: TextStyle(
                                      fontSize:15.5,
                                    ),),
                                    */
                                    Text(
                                      DateFormat('kk:mm EEE d MMM').format(ds['Time'].toDate()),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10,),
                                 Align(
                                  alignment: Alignment.centerRight,
                                  child: _buildstatus(ds['Complete']),
                                )
                              ],
                              
                          )
                        ),
                        
                  ),
                      ),
                    ));
                  }
                  
                  );
              }
            }
          )
        );
       
  }

   


 Future getuid() async {
     await  widget.auth.getuid().then((result){
       setState(() {
         uid = result;
       });});
  }
}