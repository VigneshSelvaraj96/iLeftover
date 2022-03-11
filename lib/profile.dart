import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';


class ProfilePage extends StatefulWidget {
  ProfilePage({this.auth, this.onSignedOut, this.goBack});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final VoidCallback goBack;

  @override
  State<StatefulWidget> createState() => new _ProfilePagePageState();
  void _signOut() async {
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}

class _ProfilePagePageState extends State<ProfilePage>{
  File _storedImage;
  String _imageURL;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context)
  {
    return Scaffold (
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
            backgroundColor: Color(0xFFCAE1FF),
            actions: <Widget>[
            new FlatButton(
                child: new Text('Back', style: new TextStyle(fontSize: 17.0, color: Colors.white),),
                onPressed: widget.goBack
                
              ),
            new FlatButton(
                child: new Text('Logout', style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: widget._signOut
              )
            ],
          ),  
      body: Column(
        children: <Widget>[
          FutureBuilder(
            future: widget.auth.currentUserInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                print(snapshot.data);
                return displayUserInformation(context, snapshot);
              }
              else {
                return CircularProgressIndicator();
              }
            },
          )
        ]
      )
    );
  } 
  Widget displayUserInformation(context, snapshot) {
    final user = snapshot.data;
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 75.0),),
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(width:1, color: Colors.black),
          ),
          child: user.photoUrl != null
          ? Image.network(
            user.photoUrl,
            fit: BoxFit.cover,
            width: double.infinity,
          )
          : Text('No Profile Picture', textAlign: TextAlign.center,),
          alignment: Alignment.center,
        ),
        FlatButton.icon (
          icon: Icon(Icons.camera), 
          label: Text('Update Profile Picture'),
          textColor: Theme.of(context).primaryColor,
          onPressed:(){ _takePicture(context);} ,
        ),
        Padding(padding: const EdgeInsets.only(top: 10.0)),
        Align(
          alignment: Alignment.center,
          child: Text(
            "Name: ${user.displayName ?? 'Please Update Your Name'}", style: TextStyle(fontSize: 20),),
        ),

        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text("Email: ${user.email ?? 'Anonymous'}", style: TextStyle(fontSize: 20),),
        ),

        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text("Created: ${DateFormat('MM/dd/yyyy').format(
              user.metadata.creationTime)}", style: TextStyle(fontSize: 20),),
        ),
        Padding(padding: EdgeInsets.only(top:25.0),),
        showEditProfile(context),
      ],
    );
  }
  
  Widget showEditProfile(context) {
    String name;
      return RaisedButton(
        child: Text("Edit Profile"),
        onPressed: () async {
          showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              decoration: new InputDecoration(labelText: 'Full Name'),
                              validator: (value) => value.isEmpty ? 'Full Name can\'t be empty' : null,
                              onSaved: (value) => name = value,
                            ),
                          ),
                          new RaisedButton(
                              child: new Text('Submit', style: new TextStyle(fontSize: 20.0)),
                              onPressed: () {
                                widget.auth.setName(name);
                              },
                          ),
                        ],
                      ),
                    ),
                  );
                });
        },
      );
  }

  Future <void> _takePicture(BuildContext context) async {
     final imageFile = await ImagePicker.pickImage(
       source: ImageSource.camera,
       );
     setState(() {
      _storedImage = imageFile;
      });
      _uploadImage(context);
   }

  Future <void> _uploadImage(BuildContext context) async {
   String filName = basename(_storedImage.path);
   final StorageReference ref = FirebaseStorage.instance.ref().child(filName);
   final StorageUploadTask uploadTask = ref.putFile(_storedImage);
   var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    _imageURL = dowurl.toString();
    print(_imageURL);
    widget.auth.updatePhotoURL(_imageURL);
   } 
}
