import 'dart:async';
import 'dart:math';
//import 'package:admob_flutter/admob_flutter.dart'; //Publicidad
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // Atributos de la clase para controlar los estados
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
  List<int> _tuberia =
      []; // Posible tuberia para mover la serpiente entre origen y destino
  //Variables de control musical, https://pub.dev/packages/audioplayers#-example-tab-
  AudioPlayer advancedPlayer; // Reproductor de sonidos
  AudioPlayer advancedPlayer2;
  AudioCache audioCacheBase; // Cache de los sonidos
  AudioCache audioCacheSonidos;
  bool _enableMusica = false;
  String _selectorMusicaString = "selectorMusica";
  bool anuncios = false; // Controla el muestreo de los anuncios

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
                  FlatButton(
                    color: Theme.of(context).textSelectionHandleColor,
                    onPressed: () {
                      setState(() {
                        _restartGame();
                      });
                    },
                    child: Text(
                      "Restart Game",
                    ),
                  )
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

    //Miramos que index es, para saber el contenido de la casilla
    if (_indexManzana == index) {
      colorFondo = Colors.green[300];
      int nImg = _puntuacion;
      if (_puntuacion >= mapFood.length) {
        nImg = _puntuacion % mapFood.length;
      }
      imgLocal = 'assets/img/seta.gif';
      imgUrl = mapFood[nImg];
    } else if (_serpiente.contains(index)) {
      colorFondo = Colors.green[900];
      if (_bloques.contains(index) || _pared.contains(index)) {
        colorFondo = Colors.brown[300];
        imgUrl =
            "https://lh3.googleusercontent.com/ZWSW33OuzBbl1lwheWx3pAhvLLP6aNZFEZZEl644dOp1acrXE-IcV8oxvWHITExiu9q5vTcPvoAme9n03Y_mEu4=s400";
      }
    } else if (_pared.contains(index) || _bloques.contains(index)) {
      colorFondo = Colors.brown[300];
      imgUrl =
          "https://lh3.googleusercontent.com/ZWSW33OuzBbl1lwheWx3pAhvLLP6aNZFEZZEl644dOp1acrXE-IcV8oxvWHITExiu9q5vTcPvoAme9n03Y_mEu4=s400";
    } else {
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
          _cabeza += 20;
          _serpiente.add(_cabeza);
          break;

        case 'arriba':
          _cabeza -= 20;
          _serpiente.add(_cabeza);
          break;

        case 'izq':
          _cabeza -= 1;
          _serpiente.add(_cabeza);
          break;
      }
    });

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
    if (_pared.contains(_cabeza) || _bloques.contains(_cabeza)) {
      terminar = true;
    }
    if (_serpiente.sublist(0, _serpiente.length - 2).contains(_cabeza)) {
      terminar = true;
    }
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
                  )
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
  void _restartGame() {
    _dir = "der";
    _cabeza = 23;
    _cola = 21;
    _serpiente = [21, 22, 23];
    _inGame = false;
    _end = false;
    _puntuacion = 0;
    _nuevaManzana();
    _rellenarBloques();
    _iniciarJuego();
    _loadMusic();
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
    int ale = _semilla.nextInt(_maxIndexManzana);
    while (_pared.contains(ale) || ale < (_nCol * 2)) {
      ale = _semilla.nextInt(_maxIndexManzana);
    }
    _tuberia.add(ale);
    ale = _semilla.nextInt(_maxIndexManzana);
    while (_pared.contains(ale) || ale < (_nCol * 2)) {
      ale = _semilla.nextInt(_maxIndexManzana);
    }
    _tuberia.add(ale);

    print("tuberia = $_tuberia");
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
}
