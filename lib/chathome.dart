import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'chat2.dart';

class Chathomepage extends StatefulWidget {
  Chathomepage(this.auth);
  final BaseAuth auth;
  @override
  _ChathomepageState createState() => _ChathomepageState();
}

class _ChathomepageState extends State<Chathomepage> {
   String curruid;
   String piggy;
 Future getuid() async {
    // await  widget.auth.getuid().then((result){
         curruid = await widget.auth.getuid();
      // });
  }
@override
  void initState(){
    super.initState();
    setState(() {
       getuid();
    }); 
   
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
          appBar: new AppBar(
            title: Text('Your Chats'),
            backgroundColor: Color(0xFFCAE1FF),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('messages').where('uiddoner', isEqualTo: curruid).snapshots(),
        builder: (context,snapshot) {
          if(snapshot.data == null) return CircularProgressIndicator();
              if(!snapshot.hasData) 
                return Center(child: 
                Text('No Active Reservations!',
                style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.italic
                    ),
                  )
                );
                  return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context,index){
                  DocumentSnapshot ds = snapshot.data.documents[index];
                  String otherid = ds['uidreserve']; // as oppposed to currid
                //  print(otherid);
                  getname(otherid);
                  String temp = otherid + curruid;
                  int groupchatid = temp.hashCode;
                  return Container(
                    height: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>new ChatScreen(
                          groupid: groupchatid,
                          uidreceiver: otherid,
                          uiddoner: curruid,)
                          ));
                      },
                         child: Card(
                           color: Colors.tealAccent[100],
                           shape: StadiumBorder(
                            side: BorderSide(
                            color: Colors.black,
                            width: 2.0,),
                            ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Click to view message from: ",style: TextStyle(fontSize: 18),),
                              Text(piggy,style: TextStyle(fontSize: 18),), 
                            ],
                          ),
                        ),
                      ),
                    ),
                  ); 
                });
        },),
    
    );
  }

  void getname(String id) async {
    DocumentSnapshot temp = await Firestore.instance.collection('users').document(id).get();
    String pig = temp.data['Full Name'];
    if(this.mounted)setState(() {
      piggy = pig;
    });
  }
}