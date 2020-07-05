import 'package:flutter/material.dart';

class SnakeModel {

  ///Numero de casillas del tablero dependiendo de la pantalla
  static Map<String,int> pixelRatio = {
    "20:9" : 649,
    "19:9" : 639,
    "18:9" : 579, 
    "defecto" : 559,
  };

  /// Mapa para saber los opuestos de cada dirección
  static Map<String,String> dirOpuesta = {
    "arriba" : "abajo",
    "abajo" : "arriba",
    "izq" : "der",
    "der" : "izq"
  };

  /// Mapa de la fodo imagenet
  static Map<int, String> mapFoodUrl = {
    0: "https://media.giphy.com/media/LMt9638dO8dftAjtco/giphy.gif", //python
    1: "https://media.giphy.com/media/Ri2TUcKlaOcaDBxFpY/giphy.gif", // Firebase
    2: "https://media.giphy.com/media/ln7z2eWriiQAllfVcn/giphy.gif", //JavaScript
    3: "https://media.giphy.com/media/XEDIHHp3i8bVoEdxd7/giphy.gif", //Angular
    4: "https://media.giphy.com/media/Sr8xDpMwVKOHUWDVRD/giphy.gif", //Bootstrap
    5: "https://media.giphy.com/media/XAxylRMCdpbEWUAvr8/giphy.gif", //html,
    6: "https://media.giphy.com/media/KzJkzjggfGN5Py6nkT/giphy.gif", //github
  };

  /// Mapa de la food en local
  static Map<int, String> mapFoodLocal = {
      0: "assets/img/snake/food/python.gif", //python
      1: "assets/img/snake/food/firebase.gif", // Firebase  
      2: "assets/img/snake/food/javascript.gif", //JavaScript
      3: "assets/img/snake/food/angular.gif", //Angular
      4: "assets/img/snake/food/bootstrap.gif", //Bootstrap
      5: "assets/img/snake/food/html.gif", //html,
      6: "assets/img/snake/food/github.gif", //github
      7: "assets/img/snake/food/vscode.gif", //vscode
  };

  /// Mapa de las imagenes de tuberias Url
  static Map<String, String> mapTuberiaUrl = {
    "arriba": "https://i.imgur.com/cXSpz6c.png", //arriba
    "der": "https://i.imgur.com/S3kmQqH.png", // der
    "abajo": "https://i.imgur.com/SIqUFVj.png", //abajo
    "izq": "https://i.imgur.com/j5P2eAa.png", //Angular
  };

  /// Mapa de las imagenes en de tuberias en local
  static Map<String, String> mapTuberiaLocal = {
    "arriba": "assets/img/snake/tuberia_suelo_arriba.png", //arriba
    "der": "assets/img/snake/tuberia_suelo_der.png", // der
    "abajo": "assets/img/snake/tuberia_suelo_abajo.png", //abajo
    "izq": "assets/img/snake/tuberia_suelo_izq.png", //Angular
  };

  static Map<String, String> mapBlock = {
    "local" : "assets/img/snake/block.png",
    "url" : "https://lh3.googleusercontent.com/ZWSW33OuzBbl1lwheWx3pAhvLLP6aNZFEZZEl644dOp1acrXE-IcV8oxvWHITExiu9q5vTcPvoAme9n03Y_mEu4=s400",
  };

  static Map<String,Color> mapColor = {
    "food" : Colors.green[300],
    "serpiente" : Colors.green[900],
    "block" : Colors.brown[300],
    "par" : Colors.green[100],
    "impar" : Colors.green[400],
    "end" : Colors.green[200]

  };
}