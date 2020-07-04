import 'dart:async';
import 'dart:math';
//import 'package:admob_flutter/admob_flutter.dart'; //Publicidad
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake/src/models/variables_persistentes.dart';
import 'package:flutter_snake/src/pages/rank_form.dart';
import 'package:flutter_snake/src/services/admob_service.dart';
import 'package:flutter_snake/src/services/database_service.dart';
import 'package:flutter_snake/src/services/sing_in_service.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

/*
 * Clase que contiene información relevante sobre la aplicación.
 * Esta página tiene que ser statefulWidget porque tenemos 
 * que hacer muchos cambios en la pantalla.
 */
// ignore: must_be_immutable
class SnakePage extends StatefulWidget {
  bool ads = false;
  SnakePage({this.ads});

  @override
  _SnakePageState createState() => _SnakePageState(anuncios: ads);
}

/*
 * Clase que se encarga de controlar 
 */
class _SnakePageState extends State<SnakePage> {
  // Atributos de la clase para controlar los estados y demás del juego
  var _dir = "der"; // Controla la dirección del juego
  bool _inGame = false; // Controla si tenemos el juego iniciado
  bool _end = false; // Guarda si se ha terminado la partida
  final int _nCol = 20; // Número de columnas que tiene el grid
  //final int _nFil = 29; // Número de filas del tablero
  //final double _escala = 1.45; // Relación entre el numero de col y de filas
  static int _maxIndexManzana = 579; // Número de casillas
  int _indexManzana = -1; //Indice de la manzana inicial
  static Random _semilla = Random(); // Semilla para generar aleaatorios
  int _puntuacion = 0; // Puntuación de la partida
  List<int> _serpiente = [21, 22, 23]; // Posición de las partes de la serpiente
  int _cabeza = 23; // Cabeza serpiente
  int _cola = 21; // Cola serpiente
  int _nBloques = 15; // Número de bloques en el tablero
  List<int> _bloques = []; // Bloques aleatorios como dificultad
  bool _selectorBloques =
      false; // Controla si la opción de velocidad se ha seleccionado
  String _selectorBloquesString =
      "selectorBloques"; // String de la variable en la base de datos
  Duration
      _velocidad; // Variable que mide el tiempo en el que se actualiza la pantalla
  DatabaseService dbService =
      DatabaseService.instance; // Instancia de la base de datos local
  List<int> _pared = []; // Vector que contiene las posiciones de la pared
  List<int> _tuberia = []; // PTuneria entre origen y destino
  List<String> _tuberiaDir = [];
  int auxTubSerp = 0; // Control aux de la tuberia serpiente
  //Variables de control musical, https://pub.dev/packages/audioplayers#-example-tab-
  AudioPlayer advancedPlayer; // Reproductor de sonidos
  AudioPlayer advancedPlayer2;
  AudioCache audioCacheBase; // Cache de los sonidos
  AudioCache audioCacheSonidos;
  bool _enableMusica = false;
  String _selectorMusicaString = "selectorMusica";
  // Variable de control de los anuncios video de recompensa
  bool anuncios = false; // Controla el muestreo de los anuncios
  int _vida = 0;
  bool _loaded = false;
  bool _videoVisto = false;
  bool _isButtonDisabled = false;
  // Constructor de la clase
  _SnakePageState({this.anuncios});

  @override
  void initState() {
    if(anuncios){
      AdMobService.showBannerAd();
    }else{
      AdMobService.hideBannerAd();
    }
    _loadPared();
    _loadTuberia();
    _loadSettings();
    _nuevaManzana();
    _loadVideoReward();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        drawer: MenuLateral(),
        appBar: AppBar(
          title: Text("Snake Page"),
        ),
        body: Container(
          child: _dibujarTablero(context),
        ));
  }

  ///Método que se encarga de dibujar el tablero del snake
  Widget _dibujarTablero(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          // Hacemos que ocupe toda la pantalla con un Expanded
          Expanded(
            flex: 8,
            // EL tablero tiene que estar dentro del gesture para detectar los cambios
            child: GestureDetector(
              // Controlamos acciones que se hacen en la pantalla del tablero
              onTap:
                  _iniciarJuego, // Sin parentesis para que se haga solo una vez el tap
              onVerticalDragUpdate: (details) {
                _controlVertical(details);
              },
              onHorizontalDragUpdate: (details) {
                _controlHorizontal(details);
              },
              // Dibujamos el tablero
              child: Container(
                child: GridView.builder(
                  shrinkWrap: true,
                  // Definimos el número de columnas del grid
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _nCol,
                  ),
                  // Evitamos que se pueda hacer scroll en pantalla
                  physics: NeverScrollableScrollPhysics(),
                  // Crea las casillas del tablero por defecto
                  itemCount: 580,
                  itemBuilder: (BuildContext context, int index) {
                    return _pintar(index);
                  },
                ),
              ), // Tablero
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Theme.of(context).primaryColor,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(Icons.star),
                  Text("Puntuación: $_puntuacion"),
                  /*FlatButton(
                    color: Theme.of(context).textSelectionHandleColor,
                    onPressed: () {
                      setState(() {
                        _restartGame();
                      });
                    },
                    child: Text(
                      "Restart Game",
                    ),
                  )*/
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  ///Método que se encarga de iniciar el juego
  void _iniciarJuego() {
    // Controlamos si ya estamos inGame
    if (!_inGame) {
      _inGame = true;

      //Temporizador que actualiza la pantalla, segun la _velocidad
      Timer.periodic(_velocidad, (Timer timer) {
        if (_gameOver()) {
          timer.cancel();
          _final();
        } else {
          _moverSerpiente();
        }
      });
    }
  }

  ///Método que controla el DragUpdate Vertical
  _controlVertical(DragUpdateDetails details) {
    if (_dir != "arriba" && details.delta.dy > 0) {
      _dir = "abajo";
    } else if (_dir != "abajo" && details.delta.dy < 0) {
      _dir = "arriba";
    }
  }

  ///Método que controla El DragUpdate Horizontal
  _controlHorizontal(DragUpdateDetails details) {
    if (_dir != "izq" && details.delta.dx > 0) {
      _dir = "der";
    } else if (_dir != "der" && details.delta.dx < 0) {
      _dir = "izq";
    }
  }

  ///Método para dar nuevos valores a la mazana una vez sea comida
  void _nuevaManzana() {
    _indexManzana = _semilla.nextInt(_maxIndexManzana);
    // Miramos si la manzana esta dentro de la serpiente
    while (_serpiente.contains(_indexManzana) ||
        _pared.contains(_indexManzana) ||
        _bloques.contains(_indexManzana)) {
      _indexManzana = _semilla.nextInt(_maxIndexManzana);
    }
  }

  ///Método para pintar cada una de las casillas del tablero
  Widget _pintar(int index) {
    // Variable para pintar el color del grid
    Color colorFondo;
    
    String imgUrl = "https://i.imgur.com/5NINkEr.png";
    String imgLocal = 'assets/img/original2.gif';
    /// TODO: Mejorar esto
    Map<int, String> mapFood = {
      0: "https://media.giphy.com/media/LMt9638dO8dftAjtco/giphy.gif", //python
      1: "https://media.giphy.com/media/Ri2TUcKlaOcaDBxFpY/giphy.gif", // Firebase
      2: "https://media.giphy.com/media/ln7z2eWriiQAllfVcn/giphy.gif", //JavaScript
      3: "https://media.giphy.com/media/XEDIHHp3i8bVoEdxd7/giphy.gif", //Angular
      4: "https://media.giphy.com/media/Sr8xDpMwVKOHUWDVRD/giphy.gif", //Bootstrap
      5: "https://media.giphy.com/media/XAxylRMCdpbEWUAvr8/giphy.gif", //html,
      6: "https://media.giphy.com/media/KzJkzjggfGN5Py6nkT/giphy.gif", //github
    };

    /*Map<int, String> mapFoodLocal = {
      0: "assets/img/food/python.gif", //python
      1: "assets/img/food/firebase.gif", // Firebase
      2: "assets/img/food/javascript.gif", //JavaScript
      3: "assets/img/food/angular.gif", //Angular
      4: "assets/img/food/bootstrap.gif", //Bootstrap
      5: "assets/img/food/html.gif", //html,
      6: "assets/img/food/github.gif", //github
      7: "assets/img/food/vscode.gif", //vscode
    };*/

    Map<String, String> mapTuberiaDir = {
      "arriba": "https://i.imgur.com/cXSpz6c.png", //arriba
      "der": "https://i.imgur.com/S3kmQqH.png", // der
      "abajo": "https://i.imgur.com/SIqUFVj.png", //abajo
      "izq": "https://i.imgur.com/j5P2eAa.png", //Angular
    };

    Map<String, String> mapTuberiaDirLocal = {
      "arriba": "assets/tuberia_suelo_arriba.png", //arriba
      "der": "assets/tuberia_suelo_der.png", // der
      "abajo": "assets/tuberia_suelo_abajo.png", //abajo
      "izq": "assets/tuberia_suelo_izq.png", //Angular
    };

    //Miramos que index es, para saber el contenido de la casilla
    // FOOD
    if (_indexManzana == index) {
      colorFondo = Colors.green[300];
      int nImg = _puntuacion;
      if (_puntuacion >= mapFood.length) {
        nImg = _puntuacion % mapFood.length;
      }
      imgLocal = 'assets/img/seta.gif';
      imgUrl = mapFood[nImg];
    // SERPIENTE
    } else if (_serpiente.contains(index)) {
      colorFondo = Colors.green[900];
      if (_bloques.contains(index) || _pared.contains(index)) {
        colorFondo = Colors.brown[300];
        imgUrl =
            "https://lh3.googleusercontent.com/ZWSW33OuzBbl1lwheWx3pAhvLLP6aNZFEZZEl644dOp1acrXE-IcV8oxvWHITExiu9q5vTcPvoAme9n03Y_mEu4=s400";
      }
      if (_tuberia.contains(index)) {
        colorFondo = Colors.green[300];
        imgUrl = mapTuberiaDir[_tuberiaDir[_tuberia.indexOf(index)]];
      }
    //BLOQUES
    } else if (_pared.contains(index) || _bloques.contains(index)) {
      colorFondo = Colors.brown[300];
      imgUrl =
          "https://lh3.googleusercontent.com/ZWSW33OuzBbl1lwheWx3pAhvLLP6aNZFEZZEl644dOp1acrXE-IcV8oxvWHITExiu9q5vTcPvoAme9n03Y_mEu4=s400";
    //TUBERIA
    } else if(_tuberia.contains(index)){
      colorFondo = Colors.green[300];
      imgUrl = mapTuberiaDir[_tuberiaDir[_tuberia.indexOf(index)]];
      imgLocal = mapTuberiaDirLocal[_tuberiaDir[_tuberia.indexOf(index)]];
    }else{
      colorFondo = Colors.green[300];
    }

    if (_end == true) {
      colorFondo = colorFondo = Colors.green[200];
    }

    return Container(
      padding: EdgeInsets.all(0),
      child: ClipRRect(
        //borderRadius: _radio,
        child: Container(
          child: FadeInImage(
            placeholder: AssetImage(imgLocal),
            image: NetworkImage(imgUrl.toString()),
            height: 15,
          ),
          color: colorFondo,
        ),
      ),
    );
  }

  ///Método que sirve para actualizar la posición de la serpiente
  void _moverSerpiente() {
    setState(() {
      if (_end) {
        _gameOver();
      }
      _cola = _serpiente.first;
      switch (_dir) {
        case 'der':
          _cabeza += 1;
          _serpiente.add(_cabeza);
          break;

        case 'abajo':
          _cabeza += _nCol;
          _serpiente.add(_cabeza);
          break;

        case 'arriba':
          _cabeza -= _nCol;
          _serpiente.add(_cabeza);
          break;

        case 'izq':
          _cabeza -= 1;
          _serpiente.add(_cabeza);
          break;
      }
    });
    //Entramos por la tuberia
    if(_tuberia.contains(_cabeza)){
      print("DENTRO TUBERIA");
      print(_serpiente);
      _serpiente.remove(_cabeza);
      print("SERPIENTE MENOS CABE = $_serpiente");
      // Miramos origen, para saber el destino
      int origen = _tuberia.indexOf(_cabeza);
      int destino = null;
      origen == 1 ? destino = 0 : destino = 1; 
      int posTubDestino = _tuberia[destino];
      String dirTubDestino = _tuberiaDir[destino]; 
      
      if (dirTubDestino == "der"){
        _cabeza = posTubDestino+1;
        _dir = "der";
      }
      if (dirTubDestino == "izq"){
        _cabeza = posTubDestino-1;
        _dir = "izq";
      } 
      if (dirTubDestino == "arriba"){
        _cabeza = posTubDestino-_nCol;
        _dir = "arriba";
      } 
      if (dirTubDestino == "abajo"){
        _cabeza = posTubDestino+_nCol;
        _dir = "abajo";
      }    
    
      _serpiente.add(_cabeza); 
    }
    print(_serpiente);
    print(_cabeza);
    
    if(_cola == auxTubSerp){
      print("serpiente $_serpiente");
      print("cola  $_cola");
      print("REMOVE COLA");

      //_serpiente.remove(_cola);
      //_serpiente.remove(_serpiente.first);
      //_cola = _serpiente.first;
      print("serpiente $_serpiente");
      print("cola  $_cola");
    }
    // Cuando come la serpiente
    if (_cabeza == _indexManzana) {
      _nuevaManzana();
      _puntuacion += 1;
      // Sonido de que comemos la manzana
      audioCacheSonidos.play("eat.mp3");
    } else {
      _serpiente.remove(_cola);
    }
  }

  ///Método que controla si se produce un fallo y como consecuencia el final de la partida
  bool _gameOver() {
    bool terminar = false;
    terminar = _controlChoque(_cabeza,_dir);

    if (terminar) {
      _end = true;
      if (_enableMusica) {
        audioCacheSonidos.play("impact.mp3");
        advancedPlayer.stop();
      }
    }
    return terminar;
  }

  ///Mostrar la ventana de que se ha terminado la partida
  void _final() async {
    // Primero tenemos que validar si se produce una mejora de la puntuación
    Firestore firestoreDB = Firestore.instance;
    bool mejoraPuntos = false;
    int puntosMejores = 0;
    String texto = "Ranking";
    String cabecera = "You\'re score is: $_puntuacion";

    // Hacemos la consulta de los datos del usuario
    try {
      await firestoreDB
          .collection("ranking")
          .document(emailGoogle)
          .get()
          .then((doc) {
        if (doc.exists) {
          puntosMejores = doc.data["puntos"];
        }
      });
    } catch (e) {
      mejoraPuntos = false;
    }

    if (puntosMejores == null || puntosMejores < _puntuacion) {
      mejoraPuntos = true;
      if (puntosMejores == null){
        puntosMejores = 0;
      }
      cabecera =
          "You\'re score is: $_puntuacion, you\'ve improved he previous one by ${_puntuacion - puntosMejores} points";
      texto = "Submit Score";
    }

    // Una vez tenemos validado la mejora, mostramos el showdialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('GAME OVER'),
            content: Text(cabecera),
            actions: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  FadeInImage(
                    placeholder: AssetImage("assets/img/gameover.png"),
                    image: NetworkImage(
                        "http://pngimg.com/uploads/game_over/game_over_PNG38.png"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Text('Play Again'),
                    onPressed: () {
                      setState(() {
                        _restartGame();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 15,),
                  FlatButton(
                    child: Text(texto),
                    hoverColor: Theme.of(context).toggleableActiveColor,
                    onPressed: () {
                      if (mejoraPuntos) {
                        // Nos movemos a la página de formulario
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              RankFromPage(value: _puntuacion),
                        ));
                      } else {
                        Navigator.pushNamed(context, "rank");
                      }
                    },
                  ),
                  SizedBox(width: 15,),
                  //Botón que en el caso de que sea la primera vez estará disponible
                  __crearBotonReward(context),
                  SizedBox(width: 15,),

                  
                ],
              ),
            ],
          );
        });
  }

  ///Método que se encarga de generar los bloques en el tablero
  void _rellenarBloques() {
    setState(() {
      if (_selectorBloques) {
        int pos;
        _bloques.clear();
        List<int> listaValidacion = [];
        listaValidacion.addAll(_serpiente);
        listaValidacion.add(_indexManzana);
        listaValidacion.addAll(_pared);
        listaValidacion.addAll(_tuberia);
        for (var i = 0; i < _nBloques; i++) {
          do {
            pos = _semilla.nextInt(_maxIndexManzana - (_nCol * 2));
            // En la primera fila no puede haber bloques porque superponen a la serpiente
            pos += _nCol * 2;
          } while (listaValidacion.contains(pos));

          listaValidacion.add(pos);
          _bloques.add(pos);
        }
      }
    });
  }

  /// Método que reinicia el contenido de las variables
  void _restartGame() {// Mirar lo que pasa cuando damos al boton de restart
    /*if(!_inGame){*/
      _dir = "der";
      _cabeza = 23;
      _cola = 21;
      _serpiente = [21, 22, 23];
      _inGame = false;
      _end = false;
      _puntuacion = 0;
      _videoVisto = false;
      _nuevaManzana();
      _rellenarBloques();
      _loadTuberia();
      _iniciarJuego();
      _loadMusic();
      _loadVideoReward();
    /*} */
  }

  /// Método que carga las opciones de la base de datos local
  void _loadSettings() async {
    // Carga de la velocidad de la serpiente
    final VariablesPersistentes variableVelocidad =
        await dbService.getVar("selectorVelocidad");
    if (variableVelocidad == null || variableVelocidad.value == 0) {
      _velocidad = Duration(milliseconds: 500);
    } else {
      _velocidad = Duration(milliseconds: 250);
    }

    // Carga bloques en mitad del camino
    final VariablesPersistentes variableBloques =
        await dbService.getVar(_selectorBloquesString);
    if (variableBloques == null || variableBloques.value == 0) {
      _selectorBloques = false;
    } else {
      _selectorBloques = true;
      _rellenarBloques();
    }

    final VariablesPersistentes variableMusica =
        await dbService.getVar(_selectorMusicaString);
    if (variableMusica == null || variableMusica.value == 0) {
      _enableMusica = false;
    } else {
      _enableMusica = true;
      _loadMusic();
    }
  }

  ///Método que coloca los bloques en la pared
  void _loadPared() {
    for (var i = 0; i <= _maxIndexManzana; i++) {
      if (i <= _nCol - 1 ||
          i >= _maxIndexManzana - _nCol + 1 ||
          i % _nCol == 0 ||
          i == _maxIndexManzana) {
        if (i % _nCol == 0) {
          _pared.add(i - 1);
        }
        _pared.add(i);
      }
    }
  }

  ///Método que coloca las tuberias
  void _loadTuberia() {
    _tuberia = [];
    _tuberiaDir = [];
    int ale = _semilla.nextInt(_maxIndexManzana);
    while (_controlChoque(ale,null) || ale < (_nCol * 2 ) || _controlChoque(ale+1,null) || _controlChoque(ale-1,null) || _controlChoque(ale+_nCol,null) || _controlChoque(ale-_nCol,null)) {
      ale = _semilla.nextInt(_maxIndexManzana);
    }
    _tuberia.add(ale);
    ale = _semilla.nextInt(_maxIndexManzana);
    while (_controlChoque(ale,null) || ale < (_nCol * 2 ) || _controlChoque(ale+1,null) || _controlChoque(ale-1,null) || _controlChoque(ale+_nCol,null) || _controlChoque(ale-_nCol,null)) {

      ale = _semilla.nextInt(_maxIndexManzana);
    }
    _tuberia.add(ale);
    List<String> direccionesPosibles = [];
    // Calculamos las direcciones para la tueria
    for (var pipe in _tuberia) {
      direccionesPosibles = [];
      if(!_controlChoque(pipe+1,null)){
        direccionesPosibles.add("der");
      }
      if(!_controlChoque(pipe-1,null)){
        direccionesPosibles.add("izq");
      }
      if(!_controlChoque(pipe+_nCol,null)){
        direccionesPosibles.add("arriba");
      }
      if(!_controlChoque(pipe-_nCol,null)){
        direccionesPosibles.add("abajo");
      }
      int posicionAle = _semilla.nextInt(direccionesPosibles.length);
      _tuberiaDir.add(direccionesPosibles[posicionAle]);
    }
  }



  ///Método que se encarga de reporducir la música al iniciar el juego
  void _loadMusic() {
    setState(() {
      // Creamos el reproductor de audio del sistema
      advancedPlayer = new AudioPlayer();
      advancedPlayer2 = new AudioPlayer();
      // Creamos la cache, que tiene las cancioens
      audioCacheBase =
          new AudioCache(fixedPlayer: advancedPlayer, prefix: 'audio/');
      audioCacheSonidos =
          new AudioCache(fixedPlayer: advancedPlayer2, prefix: 'audio/');
      // Limpiamos por si acaso
      audioCacheBase.clearCache();
      advancedPlayer.stop();
      audioCacheSonidos.clearCache();
      if (_enableMusica == true) {
        // Cogemos las canciones que vamos a usar
        audioCacheBase.loadAll(["snake_short.mp3"]);
        // Comenzamos con el juego de la serpiente
        audioCacheBase.loop("snake_short.mp3");
        // Cargamos el resto de sonidos
        audioCacheSonidos.loadAll(["eat.mp3", "impact.mp3"]);
      }
    });
  }

  // Carga los datos para continuar con el juego en el caso de que se vea video
  void _continuar(){
    setState(() {
      _end = false;
      _inGame = false;
      int colision = _serpiente.removeLast();
      _cabeza = _serpiente.last;
      // Cambiamos la dirección
      _cambiarDir(colision);
    });
  }

  // Método que nos devuelve el botón para ver videos reward
  Widget __crearBotonReward(BuildContext context) {
    return new RaisedButton(
      child: new Container(
        child: Row(
          children: [
            new Text(_isButtonDisabled ? "Not Video" : "Video"),
            SizedBox(width: 10,),
            Icon(_isButtonDisabled ? Icons.lock_outline  :  Icons.ondemand_video)
          ],
        ),
      ),
      onPressed: () async {
        if (!_videoVisto ) {
          // En el caso de que no hubiera visto el video tenemos que mostrarlo
          await RewardedVideoAd.instance.show().catchError((e) => print("error in showing ad: ${e.toString()}"));
          _loaded = false;
        } else {
          print("no mostramos el video!");
        } 
      });
  }

  // Método que se encarga de cargar un video
  void _loadVideoReward(){
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print("RewardedVideoAd event $event");
      if (event == RewardedVideoAdEvent.closed){
        setState(() {
          _continuar();
          Future.delayed(const Duration(milliseconds: 1000), () {    
              _iniciarJuego();
          });
          Navigator.of(context).pop();
        });
      }
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          _vida += rewardAmount;
          _videoVisto = true;
        });
      }
    };
    RewardedVideoAd.instance
      .load(adUnitId: RewardedVideoAd.testAdUnitId, targetingInfo: AdMobService.getMobileTargetInfo())
      .catchError((e) => print("error in loading 1st time"))
      .then((v) => setState(() => _loaded = true));
  }

  // Método que cambia la dirección despues de que se produce una colision
  void _cambiarDir(int colison){
    String nuevaDir = "";
    // Miramos que pasa dependiendo de la dir (eje en el que se mueve), primero eje y
    if (_dir == "arriba" || _dir == "abajo"){
      int cabezaIzq = _cabeza-1;
      int cabezaDer = _cabeza +1;
      if(_cabeza<=(_nCol/2)){
        if (!_controlChoque(cabezaDer,null)){
          nuevaDir = "der";
        }else if(!_controlChoque(cabezaIzq,null)){
          nuevaDir = "izq";
        }
      }else{
        if (!_controlChoque(cabezaIzq,null)){
          nuevaDir = "izq";
        }else if(!_controlChoque(cabezaDer,null)){
          nuevaDir = "der";
        }
      }
    }

    if (_dir == "der" || _dir == "izq"){
      int cabezaArriba = _cabeza-_nCol;
      int cabezaAbajo = _cabeza +_nCol;
      
      if(_cabeza<=(_maxIndexManzana/2)){
        if (!_controlChoque(cabezaAbajo,null)){
          nuevaDir = "abajo";
        }else if(!_controlChoque(cabezaArriba,null)){
          nuevaDir = "arriba";
        }
      }else{
        if (!_controlChoque(cabezaArriba,null)){
          nuevaDir = "arriba";
        }else if(!_controlChoque(cabezaAbajo,null)){
          nuevaDir = "abajo";
        }
      }
    }
    // Cambiamos el valor de la dirección
    _dir = nuevaDir;
    // Volvemos a pintar la nueva manzana
    _nuevaManzana();
  }

  /// Método para controlar si se produce un impacto con algo
  bool _controlChoque(int p, String dir ){
    if (_pared.contains(p) || _bloques.contains(p)) {
      return true;
    }
    // Choque contra la propia serpiente
    if (_serpiente.sublist(0, _serpiente.length - 2).contains(p)) {
      return true;
    }
    // Control de choque contra tuberia
    if(_tuberia.contains(p) && dir == null){
      return true;
    }

    //Creamos el mapa de los opuestos
    Map<String,String> opuestos = {
      "arriba" : "abajo",
      "abajo" : "arriba",
      "izq" : "der",
      "der" : "izq"
    };

    if(_tuberia.contains(p) && opuestos[_dir] != _tuberiaDir[_tuberia.indexOf(p)]){
      return true;
    }
    return false;
  }

  
}
