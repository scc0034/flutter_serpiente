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
  var _dir = "";          // Controla la dirección del juego
  bool _inGame = false;   // Controla si tenemos el juego iniciado
  final int _nCol = 20;   // Número de columnas que tiene el grid
  final int _nFil = 38;   // Número de filas del tablero
  final double _escala = 1.9;
  static int _maxIndexManzana = 700;
  int _indexManzana = _semilla.nextInt(_maxIndexManzana);
  static Random _semilla = Random();

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
      child: Column(children: <Widget>[
        // Hacemos que ocupe toda la pantalla con un Expanded
        Expanded(
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
        Padding(
            padding: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                alignment: Alignment.center,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text('Your widget at the end'))
              ],
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
  }

  /**
   * Método para pintar cada una de las casillas del tablero
   */
  Widget _pintar(int index){
    // Variable para pintar el color del grid
    Color colorFondo;
    print(index);
    //Miramos que index es, para saber el contenido de la casilla
    if(_indexManzana == index){
      colorFondo = Colors.redAccent;
    }else {
      colorFondo = Colors.green[300];
    }
    return Container(
      padding: EdgeInsets.all(1.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          color : colorFondo,
        ),
      ),
    );
  }
}