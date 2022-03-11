import 'package:flutter/material.dart';
import 'auth.dart';
import 'login_page.dart';
import 'donation.dart';


class RootPage extends StatefulWidget{
  RootPage({this.auth});
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus{
  notSignedIn,
  signedIn
}


class _RootPageState extends State<RootPage>{

  AuthStatus authStatus = AuthStatus.notSignedIn;

  @override
  void initState(){
    super.initState(); 
    widget.auth.currentUserInfo().then((userId){
      setState(() {
       authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }


  void _signedIn() {
    setState((){
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    setState((){
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override 
  Widget build(BuildContext context){
    switch(authStatus){
      case AuthStatus.notSignedIn:
        return new LoginPage(
          auth: widget.auth,
          onSignedIn: _signedIn ,
        );
      case AuthStatus.signedIn:
       return new HomePage(
         auth: widget.auth,
         onSignedOut: _signedOut,
       );
    }
  }
}