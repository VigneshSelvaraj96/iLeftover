import 'package:flutter/material.dart';
import 'auth.dart';
import 'profile.dart';
import 'statement.dart';
import 'home.dart';
import 'Reservepage.dart';


class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
    void _signOut() async {
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}



class _HomePageState extends State<HomePage>{
  int pageNumber = 0;

  void changePage(int pageNum) {
    setState(() {
      if (pageNum == 0)
        HomePage2.goHome();
      pageNumber = pageNum;
    });
  }

  void defaultPage() {
    setState(() {
      pageNumber = 0;
    });
  }

  @override 
  Widget build(BuildContext context){
    List<Widget> _children = [
        HomePage2(
          auth: widget.auth,
          onSignedOut: widget._signOut,
        ),
        ProfilePage(
            auth: widget.auth,
            onSignedOut: widget._signOut,
            goBack: defaultPage
        ),
            Reservepage(
            auth: widget.auth,
            onSignedOut: widget._signOut,
            goBack: defaultPage
        ),
        Page4(                                // statement page
            auth: widget.auth,
            onSignedOut: widget._signOut,
            goBack: defaultPage
          ),
      ];
      return new Scaffold(
          body: _children[pageNumber],
          bottomNavigationBar: new BottomNavigationBar(
            onTap: changePage,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Color(0xFFCAE1FF),
            currentIndex: pageNumber,
            items: [
              BottomNavigationBarItem(
                icon: new Icon(Icons.home),
                title: new Text('Home', style: TextStyle(color: Colors.black),),
                ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.person),
                title: new Text('Profile',style: TextStyle(color: Colors.black),),
                ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.shopping_basket),
                title: new Text('Reservations',style: TextStyle(color: Colors.black),),
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.satellite),
                title: new Text('About Us',style: TextStyle(color: Colors.black),),
              ),
             ],
          ),
        );
    }
  }