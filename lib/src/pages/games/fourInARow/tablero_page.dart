import 'dart:async';
//import 'dart:html';
import 'dart:math' show Random;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake/src/services/sing_in_service.dart';

// ignore: must_be_immutable
/// Clase que controla el juego del 4 en raya
/// Aclara que el de color yellow es el anfitrión,
/// por lo que lanza la moneda para ver quien empieza
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
  Stream doc = firestoreDB

  // VARIABLES DEL TIEMPO
  String min = "00";
  int m = 0;
  String seg = "00";
  int s = 0;

  /// VARIABLES DE CONTROL DEL JUEGO
  /// Turno
  String _turno = "";
  Color _colorY = Colors.white;
  Color _colorR = Colors.white;
  String _fotoArriba = "";
  //Tablero
  final int _nCol = 7;
  final int _nFil = 7;
  int celdas = 0;
  static final Random _semilla = new Random();

  @override
  void initState() {
    //ads ?AdMobService.showBannerAd() : AdMobService.hideBannerAd();
    firestoreDB = Firestore.instance;
    celdas = (_nFil*_nCol);
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
          ///ARRIBA
          Container(
            height: 75,
            color: _colorR,
            child: 
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: 20,),
                  CircleAvatar(
                    minRadius: 20,
                    maxRadius: 30,
                    backgroundColor: Colors.blue,
                    backgroundImage: NetworkImage(_fotoArriba),
                  ),
                  Expanded(
                    child: Container(
                      
                    ),
                  ),
                  Container(
                    child: Text("Time $min : $seg"),
                  ),
                  SizedBox(width: 20,),
                ],
              )
          ),
          ///DONDE VA EL TABLERO
          Expanded(
            child: Container(
              color: Colors.orange[100],
              child: _pintarTablero(context),
            ),
          ),
          // ABAJO
          Container(
            height: 75,
            color:_colorY,
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    minRadius: 20,
                    maxRadius: 30,
                    backgroundColor: Colors.blue,
                    backgroundImage: NetworkImage(imageUrlGoogle.toString(),),
                  )
                ],
              )
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
          _mapVarGame = snapDoc.data;
        }
    });
    } catch (err) {
      print("El error es: $err");
    }

    setState(( ) async{
      _fotoArriba = _getFotoArriba();
      await _lanzamientoMoneda();
    }); 
  }

  ///Método que da sensación de que se esta online, ya qe el tiempo pasa
  _controlTiempo(){
    Timer _timer;
    _timer = new Timer.periodic(Duration(seconds: 1),
    (Timer _timer) => setState(()  {
      s +=1;
      if(s == 60){
        m+=1;
        s = 0;
      }
      s<10?seg ="0$s" : seg="$s";
      m<10?min ="0$m" : min="$m";
      //Actualizamos los datos cada 2 segundos
      /*if (s%2==0){
        print("Cargando datos");
         firestoreDB.collection(_coleccionDB).document(code).get().then((value){
          if(value.exists){
            _mapVarGame = value.data;
          }
        });
      }*/
    }),
    );
  }

  Future<void> _lanzamientoMoneda() async{
    print("dentro del lanzamiento de la moneda");
    _turno = "";
    String msgTurno ="Comienza el jugador: ";
    //Uno de los dos tiene que lanzar la moneda, para ver quien comienza
    if(_mapVarGame["emailYellow"] == emailGoogle){
      _semilla.nextInt(2) == 0 ? _turno = "yellow" : _turno = "red";
      _turno == "yellow" ? msgTurno +="${_mapVarGame['emailYellow']}" : msgTurno +="${_mapVarGame['emailRed']}";
      setState(() {
        _mapVarGame['turno'] = _turno;
      });
      
      // Miramos de quien es el turno
      print("El turno es de $_turno");
      /// Guardamos el turno en la base de datos
      await firestoreDB.collection(_coleccionDB).document(code).updateData(_mapVarGame);
    }

    
    /// Mostramos el mensaje de quien es el que tiene el turno
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Turn draw'),
          content: Text(msgTurno),
          actions: <Widget>[
          ],
        );
      }
    );

    _changeColorTurno();
  }

  ///Método para cambiar el color del fondo del jugador que tiene el turno
  void _changeColorTurno(){
    setState(() {
      _turno == "yellow" ? _colorY = Colors.yellow[100] : _colorY = Colors.white;
      _turno == "red" ? _colorR = Colors.red[100] : _colorR = Colors.white;
    });
    
  }

  String _getFotoArriba(){
    String aux = "";
    for (var k in _mapVarGame.keys) {
      _mapVarGame[k] == emailGoogle ? aux=k.toString() : aux="";

      if (aux.compareTo("emailRed") == 0){
        return _mapVarGame["imageUrlYellow"];
      }else if(aux.compareTo("emailYellow") == 0){
        return _mapVarGame["imageUrlRed"];
      }
    }
      
  }


  Widget _pintarTablero(BuildContext context){
    Color colorFondo = Colors.blue;
    Color colorFicha = Colors.white;
    return StreamBuilder(
      stream: firestoreDB.collection(_coleccionDB).document(code).snapshots().asBroadcastStream(),
      builder: ( context, AsyncSnapshot snapshot){
        // En el caso de que no tengamos datos mostramos la barra de progreso
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        // Miramos si tenemos datos dentro del snapshot
        if(snapshot.hasData){
          DocumentSnapshot doc = snapshot.data;

          print(doc["emailRed"]);
          //List<dynamic> list = map.values.toList();
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _nCol), 
            itemCount: celdas,
            itemBuilder: (context, int index) {

              String contenidoCelda = doc[index.toString()].toString();
              print("Contenido de la celda = $contenidoCelda");
              if( contenidoCelda.compareTo("") == 0){
                colorFicha = Colors.white;
              }else if (contenidoCelda.compareTo("R") ==0){
                colorFicha = Colors.red;
              }else if (contenidoCelda.compareTo("Y") ==0){
                colorFicha = Colors.yellow;
              }
              return Container(
                padding: EdgeInsets.all(0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Container(
                    child: ClipOval(
                      
                      child: Container(
                        margin: EdgeInsets.all(8),
                        color: colorFicha,
                    ),),
                    color: colorFondo,
                  ),
                ),
              );
            }
          );
        }
      },// Final del builder
    );
  }


  
}