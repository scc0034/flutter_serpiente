import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TableroPage extends StatefulWidget {
  String code = "";
  TableroPage({this.code});

  @override
  _TableroPageState createState() => _TableroPageState(code : code);
}

class _TableroPageState extends State<TableroPage> {

  String code = "";
  _TableroPageState({this.code});

  /// Base de datos
  Firestore firestoreDB;
  String _coleccionDB = "cuatrorows";
  Map<String,dynamic> _mapVarGame = {};

  /// Variables del juego
  String min = "00";
  int m = 0;
  String seg = "00";
  int s = 0;

  @override
  void initState() {
    //ads ?AdMobService.showBannerAd() : AdMobService.hideBannerAd();
    firestoreDB = Firestore.instance;
    _cargarPartida();
    _controlTiempo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        excludeHeaderSemantics: true,

        title: Text("Jugando 4 en raya"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                minRadius: 50,
                maxRadius: 60,
                backgroundColor: Colors.blue,
                backgroundImage: NetworkImage(_mapVarGame["imageUrlRojo"],),
              ),
              Container(
                child: Text("$min : $seg"),
              )
            ],
          )
        ],
      )
    );
  }

  Future<void> _cargarPartida() async{
    bool flagExiste = false;
    try {
      await firestoreDB.collection(_coleccionDB).document(code).get().then((snapDoc) {
        if(snapDoc.exists){
          flagExiste = true;
          setState(() {
            _mapVarGame = snapDoc.data;
          });
          
        }
    });
    } catch (err) {
      print("El error es: $err");
    }
  }

  ///Método que da sensación de que se esta online, ya qe el tiempo pasa
  _controlTiempo(){
    Timer _timer;
    _timer = new Timer.periodic(Duration(seconds: 1),
    (Timer _timer) => setState(() {
      s +=1;
      if(s == 60){
        m+=1;
        s = 0;
      }
      s<10?seg ="0$s" : seg="$s";
      m<10?min ="0$m" : min="$m";

    }),
    );
  }

}