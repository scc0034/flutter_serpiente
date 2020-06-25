import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
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
  final int _nCol = 20;   // Número de columnas que tiene el grid
  final int _nFil = 29;   // Número de filas del tablero
  final double _escala = 1.45;
  static int _maxIndexManzana = 580;
  int _indexManzana = _semilla.nextInt(_maxIndexManzana);
  static Random _semilla = Random();
  int _puntuacion = 0;
  List<int> _serpiente = [0,1,2,3];
  int _cabeza = 3;
  int _cola = 0;

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
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.star),
                  title: Text("Puntuación:  ${_puntuacion}"),
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
    // Controlamos si ya estamos inGame
    if(!_inGame){
      _inGame = true;
      // Creamos el temporizador para que se mueva la serpiete cada x tiempo
      final _tiempo = const Duration(milliseconds: 500);
      Timer.periodic(_tiempo, (Timer timer) {
        if (_gameOver()){
          timer.cancel();
          _puntuacion=636131517;
          _alerta();
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
    _indexManzana = _semilla.nextInt(_indexManzana);

    // Miramos si la manzana esta dentro de la serpiente
    while(_serpiente.contains(_indexManzana)){
      _indexManzana = _semilla.nextInt(_indexManzana);
    }
  }

  /**
   * Método para pintar cada una de las casillas del tablero
   */
  Widget _pintar(int index){
    // Variable para pintar el color del grid
    Color colorFondo;
    BorderRadius _radio;

    //Miramos que index es, para saber el contenido de la casilla
    if (_indexManzana == index){
      colorFondo = Colors.redAccent;
      _radio = BorderRadius.circular(0);
    }else if(_serpiente.contains(index)){
      colorFondo = Colors.green;
      _radio = BorderRadius.circular(0);
    }else {
      colorFondo = Colors.green[200];
      _radio = BorderRadius.circular(0);
    }

    return Container(

      padding: EdgeInsets.all(0),
      child: ClipRRect(
        borderRadius: _radio,
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

  bool _gameOver(){
    print(_cola);
    //Pared izquierda
    if((_cabeza< 0 || _cabeza % (19)==0) && _dir.compareTo("izq") == 0){
      return true;
    }else
    //Pared derecha
    if((_cabeza > _maxIndexManzana || _cabeza % (20)==0) && _dir.compareTo("der") == 0){
      return true;
    }else
    // Control de abajo
    if(_cabeza>_maxIndexManzana){
      return true;
    }else
    // Control de arriba
    if (_cabeza< 0){
      return true;
    }else
    //Colision consigo misma
    if (_serpiente.sublist(0,_serpiente.length-2).contains(_cabeza)){
      return true;
    }
    return false;
  }
  
}