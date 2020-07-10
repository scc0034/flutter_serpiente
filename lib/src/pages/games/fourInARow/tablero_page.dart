import 'dart:async';
//import 'dart:html';
import 'dart:math' show Random;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake/src/services/sing_in_service.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/animation.dart';


// ignore: must_be_immutable
/// Clase que controla el juego del 4 en raya
/// Aclara que el de color yellow es el anfitrión,
/// por lo que lanza la moneda para ver quien empieza
// ignore: must_be_immutable
class TableroPage extends StatefulWidget {
  String code = "";
  TableroPage({this.code});

  @override
  _TableroPageState createState() => _TableroPageState(code : code);
}

class _TableroPageState extends State<TableroPage> with TickerProviderStateMixin{

  /// Es el código de la base de datos que permite jugar
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
  //https://deporteros.pe/wp-content/uploads/2017/07/icon-persona.png
  String _fotoArriba = "";

  //Tablero
  final int _nCol = 7;
  final int _nFil = 7;
  int celdas = 0;
  final Random _semilla = new Random();

  /// Variables de control de la entrada de mensajes
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  int _cuentaAtrasMsg = -1;/// Controla el tiempo que se muestra el mensaje
  int _cuentaAtrasField = -1;
  bool _enableField = true;

  /// Variables de los mensajes
  AnimationController controller;
  Animation<double> animation;
  BubbleStyle styleBubble = BubbleStyle(
      nip: BubbleNip.leftTop,
      color: Colors.white,
      elevation: 2.5,
      margin: BubbleEdges.only(top: 8.0, right: 50.0),
      alignment: Alignment.topLeft,
  );

  @override
  void initState() {
    //ads ?AdMobService.showBannerAd() : AdMobService.hideBannerAd();
    firestoreDB = Firestore.instance;
    celdas = (_nFil*_nCol);

    _cargarPartida();
    _controlTiempo();
    controller = AnimationController(
        duration: const Duration(milliseconds: 5000), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    controller.forward();
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
        automaticallyImplyLeading: true,
        leading: _volverAtras(),
        title: Text("4 in a row Online"),
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
          // ZONA MSG
          _pintarMsg(),
        ]
      )
    );
  }

  /// Widget con la flecha de atrás del appbar
  Widget _volverAtras(){ 
    return IconButton(
      icon: Icon(Icons.home), 
      onPressed: (){
        Navigator.popUntil(context, ModalRoute.withName("four"));
      },
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

          /// Control del color de los turnos y el color
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
          
          /// Control de que tenemos mensaje
          String invitado = getEmailInvitado();
          invitado = invitado.split("@")[0]+"msg";
          invitado = invitado.replaceAll(".", "");
          String m = doc[invitado.toString()].toString();
          if(m==null){
            m="";
          }
          if (_cuentaAtrasMsg<0 && m.compareTo("") !=0){ 
            _cuentaAtrasMsg = 10;/// Duración del mensaje hasta que se borra
          }
          return Container(
            height: 65,
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
                    child: Row(
                      children :<Widget>[
                        FadeTransition(
                          opacity: animation,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                m.compareTo("")==0? Container():
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return FadeTransition(child: child,opacity: animation);
                                  },
                                  child: Bubble(
                                    //key: ValueKey<String>(m.toString()),
                                    style: styleBubble,
                                    child: Text(m, style: TextStyle(color: Colors.black),),
                                  ),
                                ),
                              ]
                          )
                        )
                      ], 
                    ),
                  ),
                  Container(
                    child: Text("Time $min : $seg", style: 
                      TextStyle(color: Colors.black, ),),
                  ),
                  SizedBox(width: 20,),
                ],
              )
          );
        }else{
          return Container(child: Text("Sin contenido"));
        }
      },// Final del builder
    );
  }

  /// Método para pintar el tablero en tiempo real con los datos de la base de datos firestore
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

                  /// Miramos si se puede meter la ficha en la casilla pulsada
                  int celdaAbajo = index+_nFil;

                  /// Miramos que no se a terminado el juego
                  if(doc["endGame"] == false){
                  
                  //Miramos si estamos en la última fila
                    if(celdaAbajo >= celdas){
                      //Miramos que el index este vacio
                      if(doc[index.toString()].toString().compareTo("")==0){
                        await _putFicha(index,doc["turno"],doc["endGame"]);
                      }
                    }else{
                      //Miramos si la celda de abajo esta vacia
                      if(doc[celdaAbajo.toString()].toString().compareTo("")!=0){
                        if(doc[index.toString()].toString().compareTo("")==0){
                          await _putFicha(index,doc["turno"],doc["endGame"]);
                        }
                      }
                    }
                  }
                },
              );
            }
          );
        }else{
          return Container(child: Text("Sin contenido"));
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

          /// Control del color segun el turno
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
            height: 65,
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
        }else{
          return Container(child: Text("Sin contenido"));
        }
      },// Final del builder
    );
  }
  
  /// Widget de enviar los mensajes
  Widget _pintarMsg(){
  return Container(
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              child: TextField(
                enabled: _enableField,
                maxLength: 15,
                cursorColor: Colors.black,
                style: TextStyle( fontSize: 15.0, color: Colors.black),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your short message...',
                  hintStyle: TextStyle(color: Colors.black),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: 
                _enableField? Icon(Icons.send, color: Colors.black, semanticLabel: "Send",) : 
                    Icon(Icons.cancel, color: Colors.black, semanticLabel: "!",),
                onPressed: () => _enableField? _enviarMsg(textEditingController.text) : null,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.blue, width: 0.5)), color: Colors.white),
    );
  }

  ///Método que actualiza la variable del mapa que contien las vars del juego
  Future<void> _actualizaMap() async{
    try {
      await firestoreDB.collection(_coleccionDB).document(code).get().then((snapDoc) {
        if(snapDoc.exists){
          setState(() {
            _mapVarGame = snapDoc.data;
          });
        }
    });
    } catch (err) {
      print("El error es: $err");
    }
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
    // ignore: unused_local_variable
    Timer _timer;
    bool finJuego = false;
    _timer = new Timer.periodic(Duration(seconds: 1),
    (Timer _timer) => setState(()  {
      s +=1;
      _cuentaAtrasMsg -=1;
      _cuentaAtrasField -= 1;
      if(s == 60){
        m+=1;
        s = 0;
      }
      setState(() async{
        s<10?seg ="0$s" : seg="$s";
        m<10?min ="0$m" : min="$m";

        //Update cada dos segundos por si acaso

        _actualizaMap();

        /// Mostramos el cuadro dialogo de quien es el que comienza el turno
        if(_mapVarGame["lanzamiento"] == true && _mapVarGame["mostrado"] == false){
          _mostrarQuienComienza();
        }
        
        finJuego = _mapVarGame["endGame"];
        if(finJuego){
          _timer.cancel();
          _mostrarFinal(context,_mapVarGame["winner"].toString(),_mapVarGame["winnerImg"]);
        }
        
        // Cuenta atrás es cero borramos el contenido
        if (_cuentaAtrasMsg == 0){
          _borrarMensajeInvitado();
        }

        if (_cuentaAtrasField == 0){
          _enableField = !_enableField;
        }
       });
      
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
    String _turno = "";

    //Decidimos quien de los dos es el que comienza, tira la moneda el anfitrion
    if(_esAnfitrion()){
      _semilla.nextInt(2) == 0 ? _turno = "yellow" : _turno = "red";
      _mapVarGame["turno"] = _turno;
      _mapVarGame["lanzamiento"] = true;
      await firestoreDB.collection(_coleccionDB).document(code).updateData(_mapVarGame);
    }
  }

  /// Método para mostrar el mensaje de quien es el que comienza la partida
  void _mostrarQuienComienza() async{
    String msgTurno ="Comienza el jugador: ";
    String _turno = _mapVarGame["turno"];

    if(_turno.compareTo("red") == 0){
      msgTurno +=_mapVarGame["emailRed"];
    }

    if(_turno.compareTo("yellow") == 0){
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

    _mapVarGame["mostrado"] = true;
    await firestoreDB.collection(_coleccionDB).document(code).updateData(_mapVarGame);
  }

  /// Metodo que devuelve la url de la imagen de arriba, dependiendo del que juega
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
    return "https://cdn.onlinewebfonts.com/svg/img_365985.png";
  }

  /// Méétodo que mete la ficha en la base de datos y cambia el turno
  Future<void> _putFicha(int index, String turno, bool endGame) async{
    bool updated = false;
    String ficha  ="";
    if (endGame == false){
      if (turno.compareTo("yellow") == 0 && emailGoogle.compareTo(_mapVarGame["emailYellow"]) ==0 ){
        ficha = "Y";
        _mapVarGame[index.toString()] =  ficha;
        updated = true;
      }

      if (turno.compareTo("red") == 0 && emailGoogle.compareTo(_mapVarGame["emailRed"]) ==0 ){
        ficha = "R";
        _mapVarGame[index.toString()] =  ficha;
        updated = true;
      }

      //Actualizamos la variable en la base de datos
      if (updated){
        _mapVarGame["turno"].compareTo("yellow") == 0? _mapVarGame["turno"]="red" : _mapVarGame["turno"]="yellow";
        await firestoreDB.collection(_coleccionDB).document(code).updateData(_mapVarGame);
      }
      bool endGame = false;
      if(_controlFinHorizontal(index, ficha) || _controlFinVertical(index, ficha) || _controlFinDiagonal(index, ficha)){
        endGame = true;
      }

      print("Lo que tenemos dentro de endGame = $endGame");

      if (endGame && updated){
        _mapVarGame["endGame"] = true;
        _mapVarGame["winner"] = emailGoogle;
        _mapVarGame["winnerImg"] = imageUrlGoogle;
        await firestoreDB.collection(_coleccionDB).document(code).updateData(_mapVarGame);
      }
    }
  }

  bool _controlFinHorizontal(int index, String ficha){
    // ignore: unused_local_variable
    int columna;
    int fila;
    int inicioFila;
    Map<String,String> cadenaValidar = {
      "R" : "RRRR",
      "Y" : "YYYY"
    };
    index == 0? columna = (0) : columna = (index%_nCol);
    index == 0? fila = (0) : fila = (index~/_nFil); // ~/Parte entera de la
    /*print("------------------------------------------------------------------------------");
    print("CONTROL DE LA HORIZONTAL\n");*/
    /// Miramos si tenemos alguna coincidencia en horizontal
    String cadenaFila = "";
    fila == 0? inicioFila = 0 : inicioFila = _nCol*fila;
    //print("INICIO DE LA FILA PARA CONTROL HORIZONTAL = $inicioFila");
    for (var i = inicioFila; i < inicioFila+_nCol; i++) {
      String contenido = _mapVarGame[i.toString()].toString();
      if(contenido.compareTo("") == 0){
        contenido = "-";
      }
      cadenaFila+=contenido;
      print("Index mirado = $i, la cadena = $cadenaFila");

    }
    /*print("CADENA HORIZONTAL = $cadenaFila \n");
    print("------------------------------------------------------------------------------");*/

    if(cadenaFila.contains(cadenaValidar[ficha])){
      //print("WIN HORIZONTAL");
      return true;
    }
    return false;
  }


  bool _controlFinVertical(int index, String ficha){
    int columna;
    // ignore: unused_local_variable
    int fila;
    // ignore: unused_local_variable
    int inicioFila;
    Map<String,String> cadenaValidar = {
      "R" : "RRRR",
      "Y" : "YYYY"
    };
    index == 0? columna = (0) : columna = (index%_nCol);
    index == 0? fila = (0) : fila = (index~/_nFil); // ~/Parte entera de la
    /*print("||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
    print("CONTROL DE LA VERTICAL");*/
    /// Miramos que es lo que pasa en la vertical
    String cadenaColumna = "";
    for (var i = columna; i < celdas; i=i+7) {
      String contenido = _mapVarGame[i.toString()].toString();
      if(contenido.compareTo("") == 0){
        contenido = "-";
      }
      cadenaColumna+=contenido;
      print("Index mirado = $i, la cadena = $cadenaColumna");

    }
    if(cadenaColumna.contains(cadenaValidar[ficha])){
      print("WIN VERTICAL");
      return true;
    }

    /*print("CADENA VERTICAL = $cadenaColumna \n");
    print("||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");*/
    return false;

  }

  ///Método que se encarga de validar si la partida termina, cuando
  bool _controlFinDiagonal(int index, String ficha){
    /// Sacamos del index la fila y la coluna de la ficha
    int columna;
    int fila;
    // ignore: unused_local_variable
    int inicioFila;
    Map<String,String> cadenaValidar = {
      "R" : "RRRR",
      "Y" : "YYYY"
    };

    index == 0? columna = (0) : columna = (index%_nCol);
    index == 0? fila = (0) : fila = (index~/_nFil); // ~/Parte entera de la division

    /*print("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");
    print("CONTROL DE LA DIAGONAL SUP IZQ");
    /// Diagonal sup izq -> inf der, ya tenemos el inicio de la fila y la col
    print("COLUMNA $columna");*/
    int filSI = fila;
    int colSI = columna;
    int indexSI = index;
    int indexII = index;
    String cadenaSIID="";
    String cadenaIISD = "";
    int menor = filSI;
    // Miramos cual de las dos es menor, ya que os limita la búsqueda
    filSI<colSI ? menor = filSI : menor = colSI;
    /*print("Lo que tenemos dentro de menor = $menor");*/
    while(menor !=0){
      indexSI = indexSI -_nCol - 1;
      menor--;
    }
    

    /*print("EL VALOR DE NUEVA COL INDEX = $nuevaColIndex");*/
    //Iteramos para recorrer la diagonal sup izq _> inf der
    for (var i = indexSI; i < celdas; i += _nCol + 1) {
      print("MIRO $i, con el index = $indexSI, cadena = $cadenaSIID");
      String contenido = _mapVarGame[i.toString()].toString();
      if(contenido.compareTo("") == 0 ){
        contenido = "-";
      }
      cadenaSIID+=contenido;
    }

    if(cadenaSIID.contains(cadenaValidar[ficha])){
      //print("WIN DIAGONAL SUP IZQ");
      return true;
    }

    /*print("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\");

    // CONTROLAMOS LA DIAGONAL INF IZQ - SUP DER
    print("=================================================================");
    print("AHORA DIAGONA INFERIOR IZQUIERDA A SUPERIOR DERECHA");
    print("lo que tenemos dentro de indexII = $indexII");
    print("fila = $fila, el valor de la columna = $columna");*/

    while(fila<_nFil){
      indexII = indexII +(_nCol - 1);
      print("El nuevo valor del index = $indexII, con la cadena = $cadenaIISD, el valor de la fila = $fila");
      fila++;
      columna--;
    }
    columna++;
    //print("El valor de la columna donde empezamos a mirar = $columna");

    for (var i = columna; i < _nCol-1; i++) {
      String contenido = _mapVarGame[indexII.toString()].toString();
      if(contenido.compareTo("") == 0){
        contenido = "-";
      }
      cadenaIISD+=contenido;
      indexII = indexII -(_nCol - 1);
      //print("El valor del index = $indexII , cadena = $cadenaIISD ");
    }

    //print("El valor de la cadena con la que tenemos que validar = $cadenaIISD");

    if(cadenaIISD.contains(cadenaValidar[ficha])){
      print("WIN DIAGONAL iNF IZQ");
      return true;
    }
    //print("=================================================================");
    
    // En cualquier caso false
    return false;
  }

  void _mostrarFinal(BuildContext context, String winner, String winnerImg){
      showDialog(
        barrierDismissible: false, // Permite pulsar fuera para salir
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('THE WINNER IS:'),
            content: Column(
              mainAxisSize: MainAxisSize.min, // Controla que la ventana se ajuste al contenido
              
              children: <Widget>[
                Text(winner),
                CircleAvatar(
                  minRadius: 45,
                  child:Image.network(winnerImg),
                ),
              ],
            ),
            actions: <Widget>[
              RaisedButton(
                  child: new Container(
                  child: Row(
                    children: [
                      new Text("Salir"),
                      SizedBox(width: 10,),
                      Icon(Icons.exit_to_app)
                    ],
                  ),
                ),
                  onPressed: () {
                    setState(() {
                      Navigator.pushNamed(context, "/");
                    });
                  },
                ),
            ],
          );
        });
  }

  String getEmailInvitado(){
    String aux = "";
    for (var k in _mapVarGame.keys) {
      _mapVarGame[k] == emailGoogle ? aux=k.toString() : aux="";

      if (aux.compareTo("emailRed") == 0){
        return _mapVarGame["emailYellow"];
      }else if(aux.compareTo("emailYellow") == 0){
        return _mapVarGame["emailRed"];
      }
    }
    return "";
  }
  void _enviarMsg(String msg){
    // Miramos que tenga contenido
    // ignore: unrelated_type_equality_checks
    if (msg.trim() != 0){
      textEditingController.clear();
      String k = emailGoogle.split("@")[0]+"msg";
      k = k.replaceAll(".", "");
      _mapVarGame[k] = msg;
      firestoreDB.collection(_coleccionDB).document(code).updateData(_mapVarGame);
    }
    setState(() {
      _enableField = !_enableField;
    _cuentaAtrasField = 11;
    });
  }

  void _borrarMensajeInvitado(){
    String invitado = getEmailInvitado();
    invitado = invitado.split("@")[0]+"msg";
    invitado = invitado.replaceAll(".", "");
    _mapVarGame[invitado] = "";
     firestoreDB.collection(_coleccionDB).document(code).updateData(_mapVarGame);
  }  
}