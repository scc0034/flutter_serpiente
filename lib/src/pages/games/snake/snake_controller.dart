import 'dart:async';
import 'dart:math' show Random;
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_snake/src/services/database_service.dart';
/*
class SnakeController extends Con {

  //TABLERO
  static List<int> serpiente = [21, 22, 23];      // Vector la serpiente
  static int cabeza = 23;                         // Cabeza serpiente
  static int cola = 21;                           // Cola serpiente
  static List<int> bloques = [];                  // Vector de los bloques
  static int nBloques = 15;                       // Número de bloques en el tablero
  static List<int> pared = [];                    // Vector pared borde tablero
  static List<int> tuberia = [];                  // Vector tuberias
  static List<String> tuberiaDir = [];            // Vector dir de la tuberia
  static int nCol = 20;                           // Número de columnas
  static int nFil = 29;                           // Número de filas 
  static int nCasillas = 579;                     // Número de casillas
  static int indexFood = -1;                      //Indice de la manzana inicial
  final Random semilla = Random();                // Semilla para generar aleaatorios
  static int puntuacion = 0;                      // Puntuación de la partida

  // PARAMETROS DE CONTROL DE JUEGO
  String _dir = "der"; 
  bool _inGame = false; // Controla si tenemos el juego iniciado
  bool _end = false; // Guarda si se ha terminado la partida

  //BASE DE DATOS LOCAL
  DatabaseService _dbService = DatabaseService.instance;
  bool _selectorBloques = false;            // Bloques
  bool _selectorMusica = false;
  Duration _velocidad; // Variable que mide el tiempo en el que se actualiza la pantalla

  //CONTROL MUSICAL, https://pub.dev/packages/audioplayers#-example-tab-
  AudioPlayer advancedPlayer;               // Reproductor de sonidos
  AudioPlayer advancedPlayer2;
  AudioCache audioCacheBase;                // Cache de los sonidos
  AudioCache audioCacheSonidos;

  // ANUNCIOS 
  int _vida = 0;
  bool _loaded = false;
  bool _videoVisto = false;
  bool _isButtonDisabled = false;

  // CONSTRUCTOR
  SnakeController() :  super();

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
}*/