import 'package:flutter/material.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';

/**
 * Clase que contiene información relevante sobre la aplicación.
 */
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuLateral(),
        appBar: AppBar(
          title: Text("About Page"),
          ),
        body: Container()
      );
  }
}