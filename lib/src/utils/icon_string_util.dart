import 'package:flutter/material.dart';

// Mapa de los iconos
final _icons = <String, IconData>{
  'home': Icons.home,
  'snake': Icons.videogame_asset,
  'about': Icons.info_outline,
  'settings': Icons.settings,
  'rank': Icons.format_list_numbered,
};

///Método para conseguir los iconos del menu
Icon getIcon(String nombreIcono) {
  return Icon(
    _icons[nombreIcono],
    color: Colors.blue,
  );
}
