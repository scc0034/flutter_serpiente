// Utilidad que sirve para devolver iconos a partir el string

import 'package:flutter/material.dart';

// Mapa de los iconos
final _icons = <String, IconData> {
  'home' : Icons.home,
  'snake' : Icons.videogame_asset,
  'about' : Icons.info_outline,

};

Icon getIcon( String nombreIcono){
  return Icon(_icons[nombreIcono], color: Colors.blue,);
}