import 'package:flutter/material.dart';
import 'package:flutter_snake/src/pages/home_page.dart';

/**
 * Método que se encarga de devolver un mapa de las rutas que tenemos en la app
 */
Map<String,WidgetBuilder> getAplicationRoutes(){
  return <String,WidgetBuilder>{
    '/' : (BuildContext context) => HomePage(),
  };
}
