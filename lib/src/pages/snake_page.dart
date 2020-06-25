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
                // Controlador del grid
                gridDelegate: null,
                // Crea las casillas del tablero 
                itemBuilder: null
              ),
            ),// Tablero
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
  
}