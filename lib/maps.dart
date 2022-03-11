import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'auth.dart';
import 'package:geolocator/geolocator.dart';
import 'database_model.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';


class Page3 extends StatefulWidget {
   Page3({this.auth, this.onSignedOut, this.goBack});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final VoidCallback goBack;
  final String title = "iLeftOver";
  
  @override
  _Page3PageState createState() => _Page3PageState();
  void _signOut() async {
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  } 
}

class _Page3PageState extends State<Page3> {
  //
  GoogleMapController _controller;
  List<Marker> allMarkers = [];
  List <Food_data> foodlist = [];
  final Firestore db = Firestore.instance;
  Position currentPosition;
  double initlatitude = 15.7179;
  double initlongitude = -80.2746;
  

  PageController _pageController;

  int prevPage;

  createmarkers(){
    db.collection('foodnew').getDocuments().then((docs) {
      if(docs.documents.isNotEmpty){
        for(int i =0;i<docs.documents.length;i++){
          allMarkers.add(Marker(
            markerId: MarkerId(docs.documents[i]['Name']),
            draggable: false,
            infoWindow: InfoWindow(
              title:docs.documents[i]['Name'],
              snippet: docs.documents[i]['Description']
              ),
            position: LatLng(docs.documents[i]['latitude'], docs.documents[i]['longitude']),
          ));
        }
      }
    });
  }
  
  void getCurrentLocationandmovecam(Position currentPosition,BuildContext context) async {
    currentPosition  = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() {
      initlatitude = currentPosition.latitude;
      initlongitude = currentPosition.longitude;
    });
     _controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(initlatitude, initlongitude),
        zoom:14.0,
        bearing:45.0,
        tilt: 45.0)));
  }

  @override
  void initState() {
    super.initState();  
    createmarkers();
    populatefoodlist();
    _pageController = PageController(initialPage: 1, viewportFraction: 0.8)
    ..addListener(_onScroll);
    
  }

  void populatefoodlist(){
    db.collection('foodnew').getDocuments().then((docs) {
      if(docs.documents.isNotEmpty){
        for(int i =0;i<docs.documents.length;i++){
          foodlist.add(Food_data(
            name: docs.documents[i]['Name'],
            description: docs.documents[i]['Description'],
            imageurl: docs.documents[i]['Image'],
            time: docs.documents[i]['Time'].toDate(),
            latitude: docs.documents[i]['latitude'],
            longitude: docs.documents[i]['longitude'],
            documentid: docs.documents[i].documentID,
          ));
        }
      }
    });
    }



  void _onScroll(){
    if(_pageController.page.toInt() != prevPage){
      prevPage = _pageController.page.toInt();
      moveCamera();
    }
  }


  Future _movedocument(String id,int index) async{
      String user = await widget.auth.getuid();
      CollectionReference userdoc =  Firestore.instance.collection('users').document(user).collection('reservedfood');
      DocumentReference copyfrom =  Firestore.instance.collection('foodnew').document(id);
       copyfrom.updateData({
        'Reserved': 'yes',
        'Complete': false,
        });
     // print('copy from docid: $id');
     // print("copy to userid: $user");
      await copyfrom.get().then((dataread){
        userdoc.document(id).setData(dataread.data);
      });
      copyfrom.delete();
      setState(() {
        foodlist.removeAt(index);
        createmarkers();
      });
    } 

  _foodList(index){
    return AnimatedBuilder(
      animation: _pageController,
      builder: (BuildContext context, Widget widget){
        double value = 1;
        if(_pageController.position.haveDimensions){
          value = _pageController.page - index;
          value = (1-(value.abs() * 0.3)+0.06).clamp(0.0,1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) *125.0,
            width: Curves.easeInOut.transform(value) *350.0,
            child: widget,
          ),
        );
      },
      child:InkWell(
        onTap: (){
          showDialog(
            context: context,
            barrierDismissible: true,
             builder: (BuildContext context) {
             return AlertDialog(
             backgroundColor: Color(0xFFCAE1FF),
             title: Text('Reservation Confirmation', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
             content: Container(
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: <Widget>[
                   Container(
                     child: Flexible(child: Text("Do you want to proceed with reserving ${foodlist[index].name}?"))),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: <Widget>[
                       RaisedButton(
                         elevation: 8,
                         color: Colors.greenAccent,
                         onPressed: (){
                           Navigator.of(context).pop();
                           _movedocument(foodlist[index].documentid,index);
                           
                         },
                         child:Row(
                           mainAxisAlignment: MainAxisAlignment.start,
                           children: <Widget>[
                             Icon(Icons.check_box),
                             Text("Reserve"),
                           ],)
                         ),
                       RaisedButton(
                         elevation: 8,
                         color: Colors.redAccent,
                         onPressed: (){Navigator.of(context).pop();},
                         child: Row(
                           children: <Widget>[
                             Icon(Icons.cancel),
                             Text("Cancel"),
                         ],),
                         )
                     ],
                     )
                   
                 ],
               ),
             ),
            );
             });
        }, 
        child: Stack(
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10.0, vertical: 20.0,
                ),
                height: 125.0,
                width: 275.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      offset: Offset(0.0, 4.0),
                      blurRadius: 10.0,
                    ),
                  ]
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 90.0,
                        width: 90.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            topLeft: Radius.circular(10.0)
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                              foodlist[index].imageurl
                            ),
                            fit: BoxFit.cover
                          )
                        )
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                                  Text(
                                    foodlist[index].name,
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    DateFormat('EEE d MMM').format(foodlist[index].time),
                                    style: TextStyle(
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    DateFormat('kk:mm').format(foodlist[index].time),
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600),
                                  )
                          ]
                        ),
                      )
                    ]
                  )
                )
                )
              )
          ]
        )
      ),
    );
  }
    @override 
    Widget build(BuildContext context){
      createmarkers();
      return Scaffold(
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
        body: Stack(
          children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height-50.0,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(initlatitude,initlongitude),zoom: 12.0),
                    markers: Set.from(allMarkers),
                    onMapCreated: mapCreated,
                ),
              ),
              Positioned(
                bottom: 20.0,
                child: Container(
                  height: 200.0,
                  width: MediaQuery.of(context).size.width,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: foodlist.length,
                    itemBuilder: (BuildContext context, int index){
                      return _foodList(index);
                    },
                  ),
                ),
              )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:(){getCurrentLocationandmovecam(currentPosition,context);},
          tooltip: 'Get Current location',
          child: Icon(Icons.flag),
          ),
      );
    }
  
  void mapCreated(controller){
    setState((){
      _controller = controller;
    });
  }

  moveCamera(){
    _controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target:LatLng(foodlist[_pageController.page.toInt()].latitude,foodlist[_pageController.page.toInt()].longitude),
          zoom:14.0,
          bearing:45.0,
          tilt: 45.0
      )
      ));
  }
}

