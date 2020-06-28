import 'package:flutter/material.dart';
import 'package:flutter_snake/src/pages/about_page.dart';
import 'package:flutter_snake/src/pages/home_page.dart';
import 'package:flutter_snake/src/pages/login_page.dart';
import 'package:flutter_snake/src/pages/snake_page.dart';
import 'package:flutter_snake/src/pages/settings_page.dart';

/**
 * Método que se encarga de devolver un mapa de las rutas que tenemos en la app
 */
Map<String,WidgetBuilder> getAplicationRoutes(){
  return <String,WidgetBuilder>{
    '/' : (BuildContext context) => HomePage(),
    'snake' : (BuildContext context) => SnakePage(),
    'about' : (BuildContext context) => AboutPage(),
    'settings' : (BuildContext context) => SettingsPage(),
    "login" : (BuildContext context) => LoginPage(),
    
  };
}
