import 'dart:async';
import 'dart:ffi';
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

  // VARIABLES DEL TIEMPO
  String min = "00";
  int m = 0;
  String seg = "00";
  int s = 0;

  /// VARIABLES DE CONTROL DEL JUEGO
  /// Turno
  Color _colorY = Colors.white;
  Color _colorR = Colors.white;
  String _fotoArriba = "https://deporteros.pe/wp-content/uploads/2017/07/icon-persona.png";
  final int _numFichasEnd = 4;

  //Tablero
  final int _nCol = 7;
  final int _nFil = 7;
  int celdas = 0;
  final Random _semilla = new Random();

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
  void dispose(){
    super.dispose();
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
          _pintarArriba(context),
          ///DONDE VA EL TABLERO
          Expanded(
            child: Container(
              color: Colors.orange[100],
              child: _pintarTablero(context),
            ),
          ),
          // ABAJO
          _pintarAbajo(context),
        ]
      )
    );
  }

  /// Método para pintar la zona de arriba del tablero, dependiendo del turno del jugador y del dispositivo
  Widget _pintarArriba(BuildContext context){
    return StreamBuilder(
      stream: firestoreDB.collection(_coleccionDB).document(code).snapshots().asBroadcastStream(),
      builder: (context, AsyncSnapshot snapshot){
        // En el caso de que no tengamos datos mostramos la barra de progreso
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        // Miramos si tenemos datos dentro del snapshot
        if(snapshot.hasData){
          DocumentSnapshot doc = snapshot.data;
          String t = doc["turno"].toString();

          if (t.compareTo("") == 0){
            _colorR = Colors.white;
          }else{
            if(_esAnfitrion()){
            if(t.compareTo("yellow") == 0){
              _colorR=Colors.white;
            }else{
              _colorR=Colors.red[200];
            }
            
            }else{
              if(t.compareTo("yellow") == 0){
                _colorR=Colors.yellow[200];
              }else{
                _colorR=Colors.white;
              }
              
            }
          }
          
          return Container(
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
          );
        }
      },// Final del builder
    );
  }

  // Método para pintar el tablero en tiempo real con los datos de la base de datos firestore
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
              if( contenidoCelda.compareTo("") == 0){
                colorFicha = Colors.white;
              }else if (contenidoCelda.compareTo("R") ==0){
                colorFicha = Colors.red;
              }else if (contenidoCelda.compareTo("Y") ==0){
                colorFicha = Colors.yellow;
              }
              return GestureDetector(
                child: Container(
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
                ),
                onTap: () async{
                  print("HEMOS PULSADO EN LA CELDA $index");

                  /// Miramos si se puede meter la ficha en la casilla pulsada
                  int celdaAbajo = index+_nFil;

                  //Miramos si estamos en la última fila
                  if(celdaAbajo >= celdas){
                    //Miramos que el index este vacio
                    if(doc[index.toString()].toString().compareTo("")==0){
                      await _putFicha(index);
                    }
                  }else{
                    //Miramos si la celda de abajo esta vacia
                    if(doc[celdaAbajo.toString()].toString().compareTo("")!=0){
                      print("Celda de abajo no eta vacia");
                      if(doc[index.toString()].toString().compareTo("")==0){
                        await _putFicha(index);
                      }
                    }
                  }
                },
              );
            }
          );
        }
      },// Final del builder
    );
  }
  
  /// Método para pintar el fondo de la zona de abajo dependiendo del turno en la base de datos
  Widget _pintarAbajo(BuildContext context){
    return StreamBuilder(
      stream: firestoreDB.collection(_coleccionDB).document(code).snapshots().asBroadcastStream(),
      builder: (context, AsyncSnapshot snapshot){
        // En el caso de que no tengamos datos mostramos la barra de progreso
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        // Miramos si tenemos datos dentro del snapshot
        if(snapshot.hasData){
          DocumentSnapshot doc = snapshot.data;
          String t = doc["turno"].toString();
          if(t.compareTo("") == 0){
            _colorY = Colors.white;
          }else{
            if(_esAnfitrion()){
              if(t.compareTo("yellow") == 0){
                _colorY = Colors.yellow[200];
              }else{
                _colorY = Colors.white;
              }
            }else{
              if(t.compareTo("yellow") == 0){
                _colorY = Colors.white;
              }else{
                _colorY = Colors.red[200];
              }

            }
          }
          
          return Container(
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
          );
        }
      },// Final del builder
    );
  }
  
  ///Método que actualiza la variable del mapa que contien las vars del juego
  Future<void> _actualizaMap ()async{
    try {
      await firestoreDB.collection(_coleccionDB).document(code).get().then((snapDoc) {
        if(snapDoc.exists){
          _mapVarGame = snapDoc.data;
        }
    });
    } catch (err) {
      print("El error es: $err");
    }
    setState(() {
      
    });
  }

  ///Método que nada más empezar la partida modifica la interfaz
  Future<void> _cargarPartida() async{ 
    setState(( ) async{
      await _actualizaMap();
      _fotoArriba =  _getFotoArriba();
      await _lanzamientoMoneda();
    }); 
  }

  ///Método que da sensación de que se esta online, ya qe el tiempo pasa
  void _controlTiempo(){
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

      if(s%2==0){
        _actualizaMap();
        print("Turno = ${_mapVarGame['turno']} en la hora $min : $seg");
      }
    }),
    );
  }

  /// Método para saber si se es el anfitrión de la partida, es decir, el amarilo
  bool _esAnfitrion(){
    if(_mapVarGame["emailYellow"].toString().compareTo(emailGoogle) == 0){
      return true;
    }
    return false;
  }

  /// Método que se encarga de decidir cual de los dos juagdores es el que empieza
  Future<void> _lanzamientoMoneda() async{
    print("DENTRO DEL LANZAMIENTO DE LA MONEDA");
    String _turno = "";

    String msgTurno ="Comienza el jugador: ";

    //Decidimos quien de los dos es el que comienza, tira la moneda el anfitrion
    if(_esAnfitrion()){
      _semilla.nextInt(2) == 0 ? _turno = "yellow" : _turno = "red";
      _mapVarGame["turno"] = _turno;
      /// Guardamos el turno en la base de datos
      await firestoreDB.collection(_coleccionDB).document(code).updateData(_mapVarGame);
    }

    ///Hacemos el update del mapa
    await _actualizaMap();

    if(_mapVarGame["turno"].toString().compareTo("red") == 0){
      msgTurno +=_mapVarGame["emailRed"];
    }else{
      msgTurno +=_mapVarGame["emailYellow"];
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
  }

  ///Metodo que devuelve la url de la imagen de arriba, dependiendo del que juega
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

  /// Méétodo que mete la ficha en la base de datos y cambia el turno
  Future<void> _putFicha(int index) async{

    bool updated = false;
    String ficha  ="";
    // Calculamos en la columna que toca
    /*index == 0? columna = (0).toString() : columna = (index%7).toString();*/

    if (_mapVarGame["turno"].compareTo("yellow") == 0 && emailGoogle.compareTo(_mapVarGame["emailYellow"]) ==0 ){
      print("pulsando $emailGoogle dentro su turno");
      updated = true;
      ficha = "Y";
      _mapVarGame[index.toString()] =  ficha;
    }

    if (_mapVarGame["turno"].compareTo("red") == 0 && emailGoogle.compareTo(_mapVarGame["emailRed"]) ==0 ){
      updated = true;
      ficha = "R";
      _mapVarGame[index.toString()] =  ficha;
    }

    //Actualizamos la variable en la base de datos
    if (updated){
      print("Estamos dentro del update");
      //Cambiamos el turno del jugador
      _mapVarGame["turno"].compareTo("yellow") == 0? _mapVarGame["turno"]="red" : _mapVarGame["turno"]="yellow";
      await firestoreDB.collection(_coleccionDB).document(code).updateData(_mapVarGame);
      //Volvemos a cargar los datos del mapa
      _actualizaMap();
    }

    bool endGame = _controlFinPartida(index, ficha);


    if (endGame){
      print("DEBEMoS DE MOSTRAR EL MENSAJE DE QUE EL JUEGO A TERMINADO");
    }
  }

  ///Método que se encarga de validar si la partida termina, cuando
  bool _controlFinPartida(int index, String ficha){
    /// Sacamos del index la fila y la coluna de la ficha
    int columna;
    int fila;
    int inicioFila;
    Map<String,String> cadenaValidar = {
      "R" : "RRRR",
      "Y" : "YYYY"
    };

    index == 0? columna = (0) : columna = (index%_nCol);
    /// ~/ se queda con la parte entera de la division
    index == 0? fila = (0) : fila = (index~/_nFil);

    print("CONTROL DE LA HORIZONTAL\n");
    /// Miramos si tenemos alguna coincidencia en horizontal
    String cadenaFila = "";
    fila == 0? inicioFila = 0 : inicioFila = _nCol*fila;
    print("INICIO DE LA FILA PARA CONTROL HORIZONTAL = $inicioFila");
    for (var i = inicioFila; i < inicioFila+_nCol; i++) {
      String contenido = _mapVarGame[i.toString()].toString();
      if(contenido.compareTo("") == 0){
        contenido = "-";
      }
      cadenaFila+=contenido;
    }
    print("CADENA HORIZONTAL = $cadenaFila \n");

    if(cadenaFila.contains(cadenaValidar[ficha])){
      print("WIN HORIZONTAL");
      return true;
    }

    print("CONTROL DE LA VERTICAL");
    /// Miramos que es lo que pasa en la vertical
    String cadenaColumna = "";
    for (var i = columna; i < celdas; i=i+7) {
      String contenido = _mapVarGame[i.toString()].toString();
      if(contenido.compareTo("") == 0){
        contenido = "-";
      }
      cadenaColumna+=contenido;
    }
    if(cadenaColumna.contains(cadenaValidar[ficha])){
      print("WIN VERTICAL");
      return true;
    }

    print("CADENA VERTICAL = $cadenaColumna \n");


    print("CONTROL DE LA DIAGONAL SUP IZQ");
    /// Diagonal sup izq -> inf der, ya tenemos el inicio de la fila y la col
    int filSI = fila;
    int colSI = columna;
    int indexSI;
    String cadenaSIID="";
    while(colSI == 0 || filSI == 0){
      filSI--;
      colSI--;
    }
    indexSI = filSI*_nFil+colSI;

    //Iteramos para recorrer la diagonal sup izq _> inf der
    for (var i = colSI; i < _nCol; i++) {
      String contenido = _mapVarGame[indexSI.toString()].toString();
      if(contenido.compareTo("") == 0){
        contenido = "-";
      }
      cadenaSIID+=contenido;
      indexSI = _nCol + 1;
    }

    if(cadenaSIID.contains(cadenaValidar[ficha])){
      print("WIN DIAGONAL SUP IZQ");
      return true;
    }


    // En cualquier caso false
    return false;
  }

}