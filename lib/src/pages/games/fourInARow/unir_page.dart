import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake/src/services/admob_service.dart';
import 'package:flutter_snake/src/services/sing_in_service.dart';

// ignore: must_be_immutable
class UnirPage extends StatefulWidget {

  bool ads = false;
  UnirPage({this.ads});

  @override
  _UnirPageState createState() => _UnirPageState(ads:ads);
}

class _UnirPageState extends State<UnirPage> {

  ///Base de datos de firebase
  Firestore firestoreDB;
  final String _coleccionDB = "cuatrorows";
  String _codigoUnirse = "";

  ///Publicidad
  bool ads = false;
  _UnirPageState({this.ads});
  
  @override
  void initState() {
    ads ?AdMobService.showBannerAd() : AdMobService.hideBannerAd();
    firestoreDB = Firestore.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        excludeHeaderSemantics: true,

        title: Text("Invitar amigo"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(30),
            child: _textFieldCodigo(),
          ),
          SizedBox(height: 20,),
          _crearBoton(),
        ],
      ),
      
    );
  }

  Widget _textFieldCodigo() {
    return TextField(
      enabled: true,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          labelText: "Code",
          hintText: "XxXxXxXxXxX",
      ),
      onChanged: (value) {
        setState(() {
          _codigoUnirse = value;
        });
      },
    );
  }

  RaisedButton _crearBoton() {
    return RaisedButton(
      color: Colors.blue,
      onPressed: () {
        _validateCode();
      },
      child: Text(
        "Connect",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<void> _validateCode()async {
    bool flagExiste = false;
    Map mapa = {};
    try {
      await firestoreDB.collection(_coleccionDB).document(_codigoUnirse).get().then((snapDoc) {
        if(snapDoc.exists){
          flagExiste = true;
          mapa = snapDoc.data;
          mapa["conectado"] = true;
          mapa["nombreRed"] = nameGoogle;
          mapa["imageUrlRed"] = imageUrlGoogle;
        }
    });
    } catch (err) {
      print("El error es: $err");
    }

    if(flagExiste && mapa.isNotEmpty){
      try {
        await firestoreDB.collection(_coleccionDB).document(_codigoUnirse).updateData(mapa);
        Navigator.pushNamed(context, "tablero");
      } catch (err) {
        print("El error es: $err");
      }
    }else{
      showDialog(
         context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                
                title: Text('Code not valid'),
                content: Text("Try again"),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).pop();
                      });
                    },
                  ),

                ],
              );
          });
    }
  }



}

