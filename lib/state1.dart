import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:flutter/src/material/dropdown.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class Page1 extends StatefulWidget {
  Page1({this.auth, this.onSignedOut, this.goBack});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final VoidCallback goBack;

  @override
  State<StatefulWidget> createState() => new _Page1PageState();
  void _signOut() async {
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}

class _Page1PageState extends State<Page1>{
  String _name, _description, _imageurl;
  File _storedImage;
  var _foodcategory;
  double _latitude , _longitude;
  Geoflutterfire geo = Geoflutterfire();
  Position currentpos;
  GeoFirePoint myLocation;
  String uid;
  TextEditingController _textFieldController1 = TextEditingController();
  TextEditingController _textFieldController2 = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List <String> _foodcategorylist = <String> [
    'bread',
    'Cereal',
    'rice',
    'pasta',
    'grains',
    'taco',
    'burrito',
    'milk',
    'cheese',
    'chicken',
    'beef',
    'pork',
    'fish',
  ];

  void getuid() async {
    uid = await widget.auth.getuid();
 }

   Future <void> _takePicture(BuildContext context) async {
     final imageFile = await ImagePicker.pickImage(
       source: ImageSource.camera,
       );
       
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position){
          setState(() {
            currentpos = position;
            _latitude = currentpos.latitude;
            _longitude = currentpos.longitude;
             myLocation = geo.point(latitude: _latitude, longitude: _longitude);
          });
        });
     setState(() {
      _storedImage = imageFile;
      });
      _uploadImage(context);
      getuid();
   }
   
   void  _onClear() {
    setState(() {
      _textFieldController1.clear();
      _textFieldController2.clear();
      _storedImage = null;
      _foodcategory = null;
    });
  }
   


  @override
    Widget build(BuildContext context)
    {
      return new Scaffold(
          resizeToAvoidBottomPadding: false,
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
          body: SingleChildScrollView(
                      child: Column(
              children: <Widget>[
                SizedBox(width:10, height:10),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                     // mainAxisSize: MainAxisSize.min,
                      children: <Widget> [
                         Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(width:1, color: Colors.black),
                          ),
                          child: _storedImage != null
                          ? Image.file(
                            _storedImage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                          : Text('No Image Selected', textAlign: TextAlign.center,),
                          alignment: Alignment.center,
                        ),
                      
                          FlatButton.icon(
                            icon: Icon(Icons.camera), 
                            label: Text('Take Picture'),
                            textColor: Theme.of(context).primaryColor,
                            onPressed:(){ _takePicture(context);} ,
                            ),
                            
                          SizedBox(height:10,),
                          DropdownButton(
                              items: _foodcategorylist.map((value) => DropdownMenuItem(
                              child: Text(
                                value,
                                style: TextStyle(color: Color(0xff11b719)),
                              ),
                              value: value,
                            )).toList(), 
                            onChanged: (selectedtype) {
                              setState(() {
                                _foodcategory = selectedtype;
                              });
                            },
                            value: _foodcategory,
                            isExpanded: false,
                            hint: Text('Choose Food Category'),
                            style: TextStyle(color: Color(0xff11b719)),
                            ),     
                        TextField(
                          controller: _textFieldController1,
                          decoration: InputDecoration(
                            labelText: 'Food Name: ',  
                          ),
                        ),
                      
                        TextField(
                          controller: _textFieldController2,
                          decoration: InputDecoration(
                            labelText: 'Description: ',
                          ),
                        ),
                         Align(
                           alignment: Alignment.bottomCenter,
                             child: RaisedButton(
                             onPressed: (){
                               _submit(context);
                             },
                             child: Text('Submit'),
                             ),
                         )
                      ]
                    )
                  )
                ),
              ],
            ),
          )
      );
    }

     void _submitconfirm(BuildContext context) async{
       Firestore.instance.collection('foodnew').add(
        {
          "Name" : _name,
          "Description" : _description,
          "Image" : _imageurl,
          "Location" : myLocation.data,
          "latitude": _latitude,
          'longitude': _longitude,
          "Time" : DateTime.now(),
          'Reserved': false,
          'Complete':false,
          "doneruid": uid,
        }
      );
     }
      Future <void> _submit(BuildContext context) async{
        _name = _textFieldController1.text;
        _description = _textFieldController2.text;
        showDialog(
          context: context,builder: (_)=> AssetGiffyDialog(
            image: Image.network('https://media.giphy.com/media/l3q2wJsC23ikJg9xe/giphy.gif',
            fit: BoxFit.cover,
            ), 
            title: Text(
                    'Confirm Submission?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    fontSize: 22.0, fontWeight: FontWeight.w600),
                  ),
            description: Text("Are you ready to donate and feed some hungry mouths?", 
              style:TextStyle(fontWeight:FontWeight.w600,fontSize: 17) ,),
            entryAnimation: EntryAnimation.BOTTOM,
            buttonCancelColor: Colors.red[300],
            buttonCancelText: Text('No',
            style:TextStyle(color: Colors.black,
            fontWeight: FontWeight.w700)
            ),
            buttonOkColor: Colors.green,
            buttonOkText: Text('Yes',
            style:TextStyle(color: Colors.black,
            fontWeight: FontWeight.w700)
            ),
            onOkButtonPressed: (){
              _submitconfirm(context);
              Navigator.of(context).pop();
              _onClear();
            },
                  )
            );
     /* showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context){
          return AlertDialog(
            backgroundColor: Color(0xFFCAE1FF),
            title: Text('Confirm Submission?', textAlign: TextAlign.center,),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FloatingActionButton(
                  child: Text('Yes'),
                  backgroundColor: Colors.green[100],
                  onPressed:(){ 
                    _submitconfirm(context);
                    Navigator.of(context).pop();
                    _onClear();
                    }
                  ),
                FloatingActionButton(
                  child: Text('No'),
                  backgroundColor: Colors.red[100],
                  onPressed:(){ Navigator.of(context).pop();}
                  ),
              ],
            ),
          );

        },
      );*/
    }

  Future <void> _uploadImage(BuildContext context) async {
   String filName = basename(_storedImage.path);
   final StorageReference ref = FirebaseStorage.instance.ref().child(filName);
   final StorageUploadTask uploadTask = ref.putFile(_storedImage);
   var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    _imageurl = dowurl.toString();
    print(_imageurl);
   } 

}
