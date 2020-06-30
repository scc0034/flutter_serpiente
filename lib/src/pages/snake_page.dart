import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_snake/src/models/variables_persistentes.dart';
import 'package:flutter_snake/src/pages/rank_form.dart';
import 'package:flutter_snake/src/services/database_service.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';

/**
 * Clase que contiene información relevante sobre la aplicación.
 * Esta página tiene que ser statefulWidget porque tenemos 
 * que hacer muchos cambios en la pantalla.
 */
class SnakePage extends StatefulWidget {

  @override
  _SnakePageState createState() => _SnakePageState();
}

/**
 * Clase que se encarga de controlar 
 */
class _SnakePageState extends State<SnakePage>{

  // Atributos de la clase para controlar los estados
  var _dir = "der";          // Controla la dirección del juego
  bool _inGame = false;   // Controla si tenemos el juego iniciado
  bool _end = false;      // Guarda si se ha terminado la partida
  final int _nCol = 20;   // Número de columnas que tiene el grid
  final int _nFil = 29;   // Número de filas del tablero
  final double _escala = 1.45;  // Relación entre el numero de col y de filas
  static int _maxIndexManzana = 579;  // Número de casillas
  int _indexManzana = _semilla.nextInt(_maxIndexManzana); //Indice de la manzana inicial
  static Random _semilla = Random();  // Semilla para generar aleaatorios
  int _puntuacion = 0;    // Puntuación de la partida
  List<int> _serpiente = [0,1,2,3]; // Posición de las partes de la serpiente
  int _cabeza = 3;        // Cabeza serpiente
  int _cola = 0;          // Cola serpiente
  int _nBloques = 10 ;    // Número de bloques en el tablero
  List<int> _bloques = [];     // Bloques aleatorios como dificultad
  bool _selectorBloques = false;  // Controla si la opción de velocidad se ha seleccionado
  String _selectorBloquesString = "selectorBloques";// String de la variable en la base de datos
  Duration _velocidad ;   // Variable que mide el tiempo en el que se actualiza la pantalla
  DatabaseService dbService = DatabaseService.instance; // Instancia de la base de datos local


  // Constructor de la clase
  _SnakePageState(){}

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
          child : _dibujarTablero(context),
        )
      );
  }

  /**
   * Método que se encarga de dibujar el tablero del snake
   */
  Widget _dibujarTablero(BuildContext context){
    return Container(
      child: Column(
        children: <Widget>[
        // Hacemos que ocupe toda la pantalla con un Expanded
        Expanded(
          flex: 8,
          // EL tablero tiene que estar dentro del gesture para detectar los cambios
          child: GestureDetector(
            // Controlamos acciones que se hacen en la pantalla del tablero
            onTap: _iniciarJuego, // Sin parentesis para que se haga solo una vez el tap
            onVerticalDragUpdate: (details){
              _controlVertical(details);
            },
            onHorizontalDragUpdate: (details){
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
            ),// Tablero
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
                Text("Puntuación:  ${_puntuacion}"),
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
      ],),
    );
  }

  /**
   * Método que se encarga de iniciar el juego
   */
  void _iniciarJuego(){
    //_serpiente = [1,2,3,4];
    // Controlamos si ya estamos inGame
    if(!_inGame){
      _inGame = true;
      
      Timer.periodic(_velocidad, (Timer timer) {
        if (_gameOver()){
          timer.cancel();
          _final();
        }else{
          _moverSerpiente();
        }
       });
    }
  }

  /**
   * Método que controla el DragUpdate Vertical
   */
  _controlVertical(DragUpdateDetails details){
    if (_dir != "arriba" && details.delta.dy > 0){
      _dir = "abajo";
    }else if (_dir != "abajo" && details.delta.dy < 0){
      _dir = "arriba";
    }
  }

  /**
   * Método que controla El DragUpdate Horizontal
   */
  _controlHorizontal(DragUpdateDetails details){
    if (_dir != "izq" && details.delta.dx > 0){
      _dir = "der";
    }else if (_dir != "der" && details.delta.dx < 0){
      _dir = "izq";
    }
  }
  
  /**
   * Método para dar nuevos valores a la mazana una vez sea comida
   */
  void _nuevaManzana (){
    _indexManzana = _semilla.nextInt(_maxIndexManzana);
    // Miramos si la manzana esta dentro de la serpiente
    while(_serpiente.contains(_indexManzana) ){
      _indexManzana = _semilla.nextInt(_maxIndexManzana);
    }
  }

  /**
   * Método para pintar cada una de las casillas del tablero
   */
  Widget _pintar(int index){
    // Variable para pintar el color del grid
    Color colorFondo;
    BorderRadius _radio;
    String image = "";
    Image img;
    //Miramos que index es, para saber el contenido de la casilla
    if (_indexManzana == index){
      colorFondo = Colors.redAccent;
      //_radio = BorderRadius.circular(0);
    }else if(_serpiente.contains(index)){
      colorFondo = Colors.green;
      if(_bloques.contains(index)){
        colorFondo = Colors.brown[200];
        image = "block.png";
      }
      //_radio = BorderRadius.circular(0);
    }else if(_bloques.contains(index)){
      colorFondo = Colors.brown[200];
      //_radio = BorderRadius.circular(0);
    }else{
      colorFondo = Colors.green[200];
      //_radio = BorderRadius.circular(0);
    }

    if(_end == true){
      colorFondo = colorFondo = Colors.green[200];
    }

    return Container(

      padding: EdgeInsets.all(0),
      child: ClipRRect(
        //borderRadius: _radio,
        child: Container(
          /*child: FadeInImage(
            placeholder: AssetImage('assets/original.gif'), 
            image: NetworkImage('https://picsum.photos/500/300/?image=1'),
          ),*/
          color : colorFondo,
        ),
      ),
    );
  }

  /**
   * Método que sirve para actualizar la posición de la serpiente
   */
  void _moverSerpiente(){
    setState(() {
      if(_end){
        _gameOver();
      }
      _cola = _serpiente.first;
      switch (_dir) {
        case 'der':
          _cabeza +=1;
          _serpiente.add(_cabeza);
        break;

        case 'abajo':
          _cabeza +=20;
          _serpiente.add(_cabeza);
        break;

        case 'arriba':
          _cabeza -=20;
          _serpiente.add(_cabeza);
        break;

        case 'izq':
          _cabeza -=1;
          _serpiente.add(_cabeza);
        break;

      }
    });

    if(_cabeza == _indexManzana){
      _nuevaManzana();
      _puntuacion+=1;
    }else{
      _serpiente.remove(_cola);
    }
  }

  /**
   * Método que controla si se produce un fallo y como consecuencia el final de la partida
   */
  bool _gameOver(){
    print("cabeza = $_cabeza");
    //Pared izquierda
    if((_cabeza< 0 || _cabeza % (_nCol-1)==0) && _dir.compareTo("izq") == 0){
      _end = true;
      print("fallo izquierda _cabeza = $_cabeza");
      return true;
    }else
    //Pared derecha
    if((_cabeza > _maxIndexManzana || _cabeza % (_nCol)==0) && _dir.compareTo("der") == 0){
      _end = true;
      print("fallo der");
      return true;
    }else
    // Control de abajo
    if(_cabeza>_maxIndexManzana){
      _end = true;
      print("fallo abajo");
      return true;
    }else
    // Control de arriba
    if (_cabeza< 0){
      _end = true;
      print("fallo arriba");
      return true;
    }else
    //Colision consigo misma
    if (_serpiente.sublist(0,_serpiente.length-2).contains(_cabeza)){
      _end = true;
      print("fallo serpiente");
      return true;
    }else if(_bloques.contains(_cabeza)){
      _end = true;
      print("fallo BLOQUE");
      return true;
    }

    return false;
  }
  
  /**
   * Mostrar la ventana de que se ha terminado la partida
   */
  void _final(){
    showDialog(context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('GAME OVER'),
        content: Text('You\'re score: $_puntuacion'),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/gameover2.gif'),
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
                child: Text('Submit Score'),
                onPressed: () {
                  // Nos movemos a la página de formulario
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RankFromPage(value : _puntuacion),
                  ));
                },
              )
            ],
          ),
          
        ],
        );
    }
    );
  }
  
  /**
   * Método que se encarga de generar los bloques en el tablero
   */
  void  _rellenarBloques(){
    setState(() {
      if (_selectorBloques){
        int pos;
        _bloques.clear();
        List<int> listaValidacion = [];
        listaValidacion.addAll(_serpiente);
        listaValidacion.add(_indexManzana);
        for (var i = 0; i < _nBloques; i++) {
          do {
            pos = _semilla.nextInt(_maxIndexManzana-_nCol);
            // En la primera fila no puede haber bloques porque superponen a la serpiente
            pos += _nCol;
          } while (listaValidacion.contains(pos));

          listaValidacion.add(pos);
          _bloques.add(pos);
        }
      }
    });
  }

  /**
   * Método que reinicia el contenido de las variables
   */
  void _restartGame(){
    _dir = "der";
    _cabeza = 3;
    _cola = 0;
    _serpiente = [1,2,3,4];
    _inGame = false;
    _end = false;
    _puntuacion = 0;
    _nuevaManzana();
    _rellenarBloques();
    _iniciarJuego();
  }

  void _loadSettings() async {
    // Carga de la velocidad de la serpiente
    final VariablesPersistentes variableVelocidad = await dbService.getVar("selectorVelocidad");
    if(variableVelocidad == null || variableVelocidad.value== 0){
      _velocidad = Duration(milliseconds: 500);
    }else{
      _velocidad = Duration(milliseconds: 250);
    }

    // Carga de si tenemos bloques en mitad del camino
    final VariablesPersistentes variableBloques = await dbService.getVar(_selectorBloquesString);
    if(variableBloques == null || variableBloques.value== 0){
      _selectorBloques = false;
    }else{
      _selectorBloques = true;
      print("dentro de if de rellenar los bloques");
      _rellenarBloques();
    }

    print("Dentro del load del juego");
    print("Lo que tenemos dentro de la variable de bloques = $_selectorBloques");
  }
}