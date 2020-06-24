import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  /**
   * Tenemos que sobreescribir el método build, que nos retorna un widget
   * con el fin de rellenar la pantalla.
   * Tambien es necesario que para este primer widget se le pase el contesto
   * que no es más que la configuración.
   */
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      // Quitamos el banner que aparece de debug en el movil
      debugShowCheckedModeBanner: false,
      // Center lo que hace es centrar el contenido
      home : Center(
        child : Scaffold(
          appBar: AppBar(
            title: Text('Primera ventana'),
          ),
        ),
      )
    );
  }

}

