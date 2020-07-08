import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake/src/models/variables_persistentes.dart';
import 'package:flutter_snake/src/pages/games/snake/snake_model.dart';
import 'package:flutter_snake/src/pages/rank_form.dart';
import 'package:flutter_snake/src/services/admob_service.dart';
import 'package:flutter_snake/src/services/database_service.dart';
import 'package:flutter_snake/src/services/sing_in_service.dart';
import 'package:flutter_snake/src/widget/go_back.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'dart:ui' show window;


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
  _SnakePageState createState() => _SnakePageState(ads: ads);
}

/*
 * Clase que se encarga de controlar 
 */
class _SnakePageState extends State<SnakePage> {

  //ATRIBUTOS DE LA CLASE SNAKEPAGESTATE
  //TABLERO
  List<int> _serpiente = [21, 22, 23];      // Vector la serpiente
  int _cabeza = 23;                         // Cabeza serpiente
  int _cola = 21;                           // Cola serpiente
  List<int> _bloques = [];                  // Vector de los bloques
  int _nBloques = 15;                       // Número de bloques en el tablero
  List<int> _pared = [];                    // Vector pared borde tablero
  List<int> _tuberia = [];                  // Vector tuberias
  List<String> _tuberiaDir = [];            // Vector dir de la tuberia
  static final int _nCol = 20;              // Número de columnas
  static final int _nFil = 25;              // Número de filas 
  static int _nCasillas =0;             // Número de casillas
  int _indexFood = -1;                      //Indice de la manzana inicial
  static final Random _semilla = Random();  // Semilla para generar aleaatorios
  int _puntuacion = 0; // Puntuación de la partida

  // CONTROL JUEGO
  String _dir = "der";                      // Direccion
  bool _inGame = false;                     // En juego?
  bool _end = false;                        // Partida end ?
  Timer timer;                              // Temporizador
  
  //BASE DE DATOS LOCAL
  DatabaseService dbService = DatabaseService.instance;
  bool _selectorBloques = false;            // Bloques
  bool _selectorMusica = false;             //Musica
  Duration _velocidad = Duration(milliseconds: 500);                      // Velocidad
  bool _selectorTuberias = false;           //Tuberias

  //CONTROL MUSICAL, https://pub.dev/packages/audioplayers#-example-tab-
  AudioPlayer advancedPlayer;               // Reproductor de sonidos
  AudioPlayer advancedPlayer2;
  AudioCache audioCacheBase;                // Cache de los sonidos
  AudioCache audioCacheSonidos;

  // ADMOB PUBLICIDAD
  bool ads = false; 
  bool _loaded = false;
  bool _videoVisto = false;
  bool _isButtonDisabled = false;

  // Constructor de la clase
  _SnakePageState({this.ads});

  @override
  void initState() {
    //Mostramos anuncios segun ads
    ads ?AdMobService.showBannerAd() : AdMobService.hideBannerAd();
    _loadRatio();
    _loadPared();
    _loadSettings();
    _loadTuberia();
    _nuevaManzana();
    _loadVideoReward();
    super.initState();
  }

  @override
  void dispose() {
    audioCacheBase.clearCache();
    advancedPlayer.stop();
    audioCacheSonidos.clearCache();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        drawer: MenuLateral(),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: GoBack.volverAtras(context),
          title: Text("Snake Page"),
          actions: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 15),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(child: child,opacity: animation);
                  },
                  child: Text("Points $_puntuacion",
                    key: ValueKey<int>(_puntuacion),
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    
                  ),
          ),
            )
          ),
          ]
        ),
        body: Container(
          child: _dibujarTablero(context),
        ));
  }

  void _loadRatio(){
        ///Método para calcular el ratio de pixeles
    double alto = window.physicalSize.height.toDouble();
    double ancho = window.physicalSize.width.toDouble();
    double ratio = (alto/ancho);
    if(ratio > 1.78 && ratio<1.93){
       _nCasillas =  SnakeModel.pixelRatio["18:9"];
    } else if(ratio<2.12){
      _nCasillas = SnakeModel.pixelRatio["19:9"];
    } else if(ratio<2.4){
      _nCasillas = SnakeModel.pixelRatio["20:9"];
    }else{
      _nCasillas = SnakeModel.pixelRatio["defecto"];
    }
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
              onTap:() => _iniciarJuego(), // Sin parentesis para que se haga solo una vez el tap
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
                  itemCount: _nCasillas+1,
                  itemBuilder: (BuildContext context, int index) {
                    return _pintar(index);
                  },
                ),
              ), // Tablero
            ),
          ),  
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
      Timer.periodic(_velocidad, (timer) {
        if (_gameOver() ) {
          timer.cancel();
          _final();
        } else {
          if(_moverSerpiente()){
            timer.cancel();
            _final();
          }
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
    _indexFood = _semilla.nextInt(_nCasillas);
    // Miramos si la manzana esta dentro de la serpiente
    while (_controlChoque(_indexFood, null)) {
      _indexFood = _semilla.nextInt(_nCasillas);
    }
  }

  ///Método para pintar cada una de las casillas del tablero
  Widget _pintar(int index) {
    // Variable para pintar el color del grid
    String colorBack;
    bool paridad = false;
    String imgUrl = "https://i.imgur.com/5NINkEr.png";
    String imgLocal = 'assets/img/snake/transparente.png';

    //Miramos que index es, para saber el contenido de la casilla
    // FOOD
    if (_indexFood == index) {
      paridad ?  colorBack = "par" : colorBack = "impar"; 
      int nImg = _puntuacion;
      if (_puntuacion >= SnakeModel.mapFoodUrl.length) {
        nImg = _puntuacion % SnakeModel.mapFoodUrl.length;
      }
      imgLocal = SnakeModel.mapFoodLocal[nImg];
      imgUrl = SnakeModel.mapFoodUrl[nImg];
    // SERPIENTE
    } else if (_serpiente.contains(index)) {
      colorBack = "serpiente";
      if (_bloques.contains(index) || _pared.contains(index)) {
        colorBack = "block";
        imgLocal = SnakeModel.mapBlock["local"];  
        imgUrl = SnakeModel.mapBlock["url"];            
      }else if (_tuberia.contains(index)) {
        colorBack = "block";
        imgLocal = SnakeModel.mapTuberiaLocal[_tuberiaDir[_tuberia.indexOf(index)]];  
        imgUrl = SnakeModel.mapTuberiaUrl[_tuberiaDir[_tuberia.indexOf(index)]];
      }
    //BLOQUES
    } else if (_pared.contains(index) || _bloques.contains(index)) {
      colorBack = "block";
      imgUrl = SnakeModel.mapBlock["url"];
      imgLocal = SnakeModel.mapBlock["local"];
    //TUBERIA
    } else if(_tuberia.contains(index)){
      colorBack = "block";
      imgLocal = SnakeModel.mapTuberiaLocal[_tuberiaDir[_tuberia.indexOf(index)]];  
      imgUrl = SnakeModel.mapTuberiaUrl[_tuberiaDir[_tuberia.indexOf(index)]];
    }else{
      paridad ?  colorBack = "par" : colorBack = "impar"; 
    }

    paridad = !paridad;
    // ignore: unnecessary_statements
    _end==true ? colorBack= "end" : null;

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
          color: SnakeModel.mapColor[colorBack],
        ),
      ),
    );
  }

  ///Método que sirve para actualizar la posición de la serpiente
  bool _moverSerpiente() {
    setState(() {
      if (_end || _controlChoque(_cabeza, _dir)) {
        _gameOver();
      }
      _cola = _serpiente.first;
      switch (_dir) {
        case 'der':
          _cabeza += 1;
          break;

        case 'abajo':
          _cabeza += _nCol;
          break;

        case 'arriba':
          _cabeza -= _nCol;
          break;

        case 'izq':
          _cabeza -= 1;
          break;
      }

      _serpiente.add(_cabeza);

      //Entramos por la tuberia
      if(_tuberia.contains(_cabeza)){
        if(_controlChoque(_cabeza, _dir)){
          return true;
        }
        _serpiente.remove(_cabeza);
        // Miramos origen, para saber el destino
        int origen = _tuberia.indexOf(_cabeza);
        int destino;
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
      
      // Cuando come la serpiente
      if (_cabeza == _indexFood) {
        _nuevaManzana();
        _puntuacion += 1;
        // Sonido de que comemos la manzana
        // ignore: unnecessary_statements
        _selectorMusica? audioCacheSonidos.play("eat.mp3") :null;
      } else {
        _serpiente.remove(_cola);
      }
    });
    return false;
  }

  ///Método que controla si se produce un fallo y como consecuencia el final de la partida
  bool _gameOver() {
    bool terminar = false;
    terminar = _controlChoque(_cabeza,_dir);

    if (terminar) {
      _end = true;
      if (_selectorMusica) {
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
    showGeneralDialog(
      transitionBuilder: (context, a1, a2, widget) {
      final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
      return Transform(
        transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
        child: Opacity(
          opacity: a1.value,
          child: AlertDialog(
            title: Text('GAME OVER'),
            content: Text(cabecera),
            actions: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset("assets/img/snake/gameover.png"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  SizedBox(width: 5,),
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
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  __crearBotonReward(context),
                ],
              )
            ],
          )
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {});
  }

  ///Método que se encarga de generar los bloques en el tablero
  void _rellenarBloques() {
    setState(() {
      if (_selectorBloques) {
        int pos;
        _bloques.clear();
        List<int> listaValidacion = [];
        listaValidacion.addAll(_serpiente);
        listaValidacion.add(_indexFood);
        listaValidacion.addAll(_pared);
        listaValidacion.addAll(_tuberia);
        for (var i = 0; i < _nBloques; i++) {
          do {
            pos = _semilla.nextInt(_nCasillas - (_nCol * 2));
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
    final String _selectorBloquesString = "selectorBloques"; 
    final String _selectorMusicaString = "selectorMusica";
    final String _selectorVelocidadString = "selectorVelocidad";
    final String _selectorTuberiasString = "selectorTuberias";
    
    // Carga de la velocidad de la serpiente
    final VariablesPersistentes variableVelocidad =
        await dbService.getVar(_selectorVelocidadString);
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
      _selectorMusica = false;
    } else {
      _selectorMusica = true;
      _loadMusic();
    }

    final VariablesPersistentes variablePipe =
        await dbService.getVar(_selectorTuberiasString);
    if (variablePipe == null || variablePipe.value == 0) {
      _selectorTuberias = false;
    } else {
       _selectorTuberias = true;
       _loadTuberia();
    }
  }

  ///Método que coloca los bloques en la pared
  _loadPared() async{
    for (var i = 0; i <= _nCasillas; i++) {
      if (i <= _nCol - 1 ||
          i >= _nCasillas - _nCol + 1 ||
          i % _nCol == 0 ||
          i == _nCasillas) {
        if (i % _nCol == 0) {
          _pared.add(i - 1);
        }
        _pared.add(i);
      }
    }
  }

  ///Método que coloca las tuberias
  _loadTuberia() {
    setState(() {
      if(_selectorTuberias){
        _tuberia = [];
        _tuberiaDir = [];
         
        for (var i = 0; i < 2; i++) {
          int ale = _semilla.nextInt(_nCasillas);
          while (_controlChoque(ale,null) || ale < (_nCol * 2 ) || _controlChoque(ale+1,null) || _controlChoque(ale-1,null) || _controlChoque(ale+_nCol,null) || _controlChoque(ale-_nCol,null)) {
            ale = _semilla.nextInt(_nCasillas);
          }
          _tuberia.add(ale);
        }
        
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
    });
    
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
      if (_selectorMusica == true) {
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
      _loadMusic();
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
      
      if(_cabeza<=(_nCasillas/2)){
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
    if(dir!=null && _tuberia.contains(p) ){
      if(SnakeModel.dirOpuesta[dir] != _tuberiaDir[_tuberia.indexOf(p)]){
        return true;
      }
      
    }
    return false;
  }
}
