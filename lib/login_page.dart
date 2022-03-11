import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'auth.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth,this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType {
  login,
  register
}

class _LoginPageState extends State<LoginPage> {
  
  final formKey = new GlobalKey<FormState>();
  String _email;
  String _password;
  String _name;
  String _food;
  File _storedImage;
  String _imageURL;
  FormType _formType = FormType.login;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          await widget.auth.signInWithEmailAndPassword(_email, _password);
        }
        else {
          await widget.auth.createUserWithEmailAndPassword(_email, _password, _name);
        }
        widget.onSignedIn();
      }
      catch (e) {
        print('Error: $e');
        _displayError(e, context);
      }
    }
  }

  void moveToRegister(){
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin(){
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }


  @override
    Widget build(BuildContext context) {
      return new Scaffold(
        body: new Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 0.0),
          child: new Form(
            key: formKey,
            child: new ListView(
              children: buildInputs(context) + buildSubmitButtons(),
            ),
          ),
        )
      );
    }

    List<Widget> buildInputs(context){
      if (_formType == FormType.login)
      {
        return [      
            Padding(padding: EdgeInsets.only(top:100.0)),
            Image.asset(
              'Assets/LOGO.png',
              width: 200,
              height: 100,
              fit: BoxFit.contain,
            ),
              new TextFormField(
                decoration: new InputDecoration(
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                  labelText: 'Email',
                ),
                validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
                onSaved: (value) => _email = value,
              ),
              new TextFormField(
                decoration: new InputDecoration(
                  labelStyle: TextStyle(
                    color: Colors.black,
              //      fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                  labelText: 'Password',
                  ),
                validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
                obscureText: true,
                onSaved: (value) => _password = value,
              ),
        ];
      }
      else {
          return [      
            Image.asset(
              'Assets/LOGO.png',
              width: 200,
              height: 100,
              fit: BoxFit.contain,
            ),
            new TextFormField(
              decoration: new InputDecoration(
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                labelText: 'Email',
              ),
              validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
              onSaved: (value) => _email = value,
            ),
            new TextFormField(
              decoration: new InputDecoration(
                labelStyle: TextStyle(
                  color: Colors.black,
            //      fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
                labelText: 'Password',
                ),
              validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
              obscureText: true,
              onSaved: (value) => _password = value,
            ),
            new TextFormField(
            decoration: new InputDecoration(
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
              ),
              labelText: 'Full Name',
            ),
            validator: (value) => value.isEmpty ? 'Full Name can\'t be empty' : null,
            onSaved: (value) => _name = value,
          ),
          new TextFormField(
            decoration: new InputDecoration(
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
              ),
              labelText: 'Favorite Food',
            ),
            validator: (value) => value.isEmpty ? 'Favorite Food can\'t be empty' : null,
            onSaved: (value) => _food = value,
          ),
          Padding(padding: EdgeInsets.only(top:10.0)),
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
            : Text('No Profile Picture', textAlign: TextAlign.center,),
            alignment: Alignment.center,
          ),
          FlatButton.icon (
            icon: Icon(Icons.camera), 
            label: Text('Update Profile Picture'),
            textColor: Colors.lightBlue,
            onPressed:(){ _takePicture(context);} ,
          ),
        ];
      }
    }

    List<Widget> buildSubmitButtons() {
      if (_formType == FormType.login) 
      {
        return [           
            new SizedBox(height:20),
            new RaisedButton(
              child: new Text('Login', style: new TextStyle(fontSize: 20.0)),
              onPressed: validateAndSubmit,
            ),
            new RaisedButton(
              child: new Text('Create an account', style: new TextStyle(fontSize: 20.0)),
              onPressed: moveToRegister,
            ),
            _signInButton()
        ];
      } else {
        return [
            Padding(padding: EdgeInsets.only(top:10.0)),
            new RaisedButton(
              child: new Text('Create an Account', style: new TextStyle(fontSize: 20.0)),
              onPressed: validateAndSubmit,
            ),
            new RaisedButton(
              child: new Text('Have an account? Login', style: new TextStyle(fontSize: 20.0)),
              onPressed: moveToLogin,
            ),
        ];
      }
    }
  Widget _signInButton() {
    return new Row(
      children: <Widget>[
        new Container(
          padding: EdgeInsets.only(left: 50.0, top: 20.0),
          alignment: Alignment.center,
          child: new OutlineButton(
            splashColor: Colors.green,
            onPressed: () {
              widget.auth.signInWithGoogle().whenComplete(() {
                widget.onSignedIn();
              });
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            highlightElevation: 0,
            borderSide: BorderSide(color: Colors.green),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(image: AssetImage("Assets/google_logo.png"), height: 35.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        )
      ],
    );
  }

  void _displayError(PlatformException error, context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Error"),
          content: new Text(error.message),
        );
      }
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