import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake/src/pages/games/fourInARow/tablero_page.dart';
import 'package:flutter_snake/src/services/admob_service.dart';
import 'package:flutter_snake/src/services/sing_in_service.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';

class InvitarPage extends StatefulWidget {

  bool ads = false;
  InvitarPage({this.ads});

  @override
  _InvitarPageState createState() => _InvitarPageState(ads : ads);
}

class _InvitarPageState extends State<InvitarPage> {

  ///Publicidad
  bool ads = false;
  _InvitarPageState({this.ads});

  ///Base de datos de firebase
  Firestore firestoreDB;
  final String _coleccionDB = "cuatrorows";
  final key = new GlobalKey<ScaffoldState>();
  String _codigo = "";
  

  @override
  void initState() {
    ads ?AdMobService.showBannerAd() : AdMobService.hideBannerAd();
    firestoreDB = Firestore.instance;
    _crearPartida();
    _esperaJugador(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key : key,
      appBar: AppBar(
        excludeHeaderSemantics: true,

        title: Text("Invitar amigo"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        
        children: <Widget>[
          Text("Share match code"),
          SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            GestureDetector(
            child: Text("$_codigo"),
            onLongPress: () {
              Clipboard.setData(new ClipboardData(text: "$_codigo"));
              key.currentState.showSnackBar(
                  new SnackBar(content: new Text("Copied to Clipboard"),));
            },
          ),
          SizedBox(width: 15,),
          GestureDetector(
            child: Icon(Icons.content_copy),
            onTap: () {
              Clipboard.setData(new ClipboardData(text: "$_codigo"));
              key.currentState.showSnackBar(
                  new SnackBar(content: new Text("Copied to Clipboard"),));
            },
          ),
          ],),
          SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                minRadius: 50,
                maxRadius: 60,
                backgroundColor: Colors.blue,
                backgroundImage: NetworkImage(imageUrlGoogle,),
              ),
              SizedBox(width: 50,),
              GestureDetector(
                child: CircleAvatar(
                  minRadius: 50,
                  maxRadius: 60,
                  backgroundColor: Colors.blue,
                  child: Image.asset("assets/img/whatsapp.png",
                    height: 40,
                    color: Colors.cyan[50],
                  ),
                ),
                onTap: () async{
                  print("Mandar mediante whatsapp");
                  var response = await FlutterShareMe().shareToSystem(msg: _codigo);
                   if (response == 'success') {
                     print('navigate success');
                   }
                },
              )
            ],
          ),
          SizedBox(height: 50,),
          RaisedButton(
            child: Text("Back"),
            onPressed: (){
              _borrarDocumento(context);
            },
            )
        ],
      ),
    );
  }

  Future<void> _crearPartida() async{
    DocumentReference docPartidaNew = firestoreDB.collection(_coleccionDB).document();

    setState(() {
      _codigo = docPartidaNew.documentID;
    });
    

    Map<String, dynamic> data = {
      "imageUrlYellow": imageUrlGoogle,
      "imageUrlRed": "",
      "nombreYellow" : nameGoogle,
      "nombreRed" : "",
      "emailYellow" : emailGoogle,
      "emailRed" : "",
      "fecha": FieldValue.serverTimestamp(),
      "conectado" : false,
      "inGame" : false,
      "endGame" : false,
    };

    /// Añadimos el tablero vacio
    for (var i = 0; i < 49; i++) {
      data[i.toString()] = "";
    }

    print(data);

    try {
      docPartidaNew.setData(data);
    } catch (err) {
      print("El error del update es: $err");
    }
  }

  Future<void> _borrarDocumento(BuildContext context)async {
    await firestoreDB.collection(_coleccionDB).document(_codigo).delete();
    Navigator.pop(context);
  }

  /// Método que comprueba cada segundo si tenemos el otro jugador durante 2 mins
  void _esperaJugador(BuildContext context){
    Timer _timer;
    int _duracion = 180;

    _timer = new Timer.periodic(Duration(seconds: 1),
    (Timer _timer) => setState(
      () {
        print("${_duracion}");
        //En el caso de que se acabe el tiempo de espera para el otro player, msg y salir
        if (_duracion < 1) {
          _timer.cancel();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                
                title: Text('No Player'),
                content: Text("The other player has not connected to the game"),
                actions: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset("assets/img/noPlayer.png"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          setState(()async {
                            await _borrarDocumento(context);
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                      
                    ],
                  ),

                ],
              );
          });
        } else {
          _duracion = _duracion - 1;
          //Validamos si el otro jugador se ha concetado
          _validatePlayerConnected(context,  _timer);
        }
        },
      ),
    );
  }

  Future<void> _validatePlayerConnected(BuildContext context, Timer timer) async{
    await firestoreDB.collection(_coleccionDB).document(_codigo).get().then((snapDoc) {
      Map<String,dynamic> mapa = snapDoc.data;
      if (mapa["conectado"] == true){
        Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                timer.cancel();
                return TableroPage(code: _codigo,);
              },
            ),
          );
      }
    });
  }
}