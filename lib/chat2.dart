import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_savior/auth.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({this.groupid,this.uidreceiver,this.uiddoner,this.auth,});
  int groupid;
  String uidreceiver;
  String uiddoner;
  String currid;
  final BaseAuth auth;
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  String groupid1;
  String identifier ="Them";
  @override
  void initState() {
    super.initState();
    groupid1 = widget.groupid.toString();
    print(groupid1);
 }
  final TextEditingController textEditingController = new TextEditingController();
  CollectionReference ds = Firestore.instance.collection('messages');

  void _handleSubmit(String text)  {
   
    ds.document(groupid1).setData({
      'uidreserve': widget.uidreceiver,
      'uiddoner': widget.uiddoner,
    });
    textEditingController.clear();
    if(this.mounted)
    setState(() {
          //used to rebuild our widget
          ds.document(groupid1).collection('chat').document().setData({
            'text': text,
            "timeStamp":Timestamp.now(),
            "sentby": widget.currid,
          });
        });
  }

  void getuid() async{
     widget.currid = await widget.auth.getuid();
  }

  Widget _textComposerWidget() {
    return new IconTheme(
      data: new IconThemeData(color: Color(0xFF827DFA)),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                decoration: new InputDecoration.collapsed(
                    hintText: "Enter your message"),
                controller: textEditingController,
                onSubmitted: _handleSubmit,
              ),
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => _handleSubmit(textEditingController.text),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
            title: Text("Food Reservation Chat"),
            backgroundColor: Color(0xFFCAE1FF),
            actions: <Widget>[
            new FlatButton(
                child: new Text('Back', style: new TextStyle(fontSize: 17.0, color: Colors.black)),
                onPressed:(){ Navigator.pop(context);}
              ),
              ],
              ),

          body: StreamBuilder(
            stream: Firestore.instance.collection('messages').document(groupid1).collection('chat').orderBy("timeStamp",descending: true).snapshots(),
            builder: (context, snapshot) {
              getuid();
              if(snapshot.data == null) return CircularProgressIndicator();
              else 
              return new Column(
              children: <Widget>[
                new Flexible(
                  child: new ListView.builder(
                    padding: new EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder:(context,index){
                      DocumentSnapshot ds = snapshot.data.documents[index];
                      if(ds['sentby']== widget.currid) identifier = 'You';
                      else identifier = 'Them';
                      return new Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            margin: const EdgeInsets.only(right: 16.0),
                            child: new CircleAvatar(
                              child: new Text('P'),
                            ),
                          ),
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(identifier,style: Theme.of(context).textTheme.subhead),
                              new Container(
                                margin: const EdgeInsets.only(top: 5.0),
                                child: new Text('${ds['text']}'),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                    },
                    itemCount: snapshot.data.documents.length,
                  ),
                ),
                new Divider(height: 1.0,),
                new Container(
                  decoration: new BoxDecoration(
                    color: Theme.of(context).cardColor,
                  ),
                  child: _textComposerWidget(),
                )
              ],
        );
            }
          ),
    );
  }
}