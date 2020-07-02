// Importamos el fichero que maneja json, con el show cogemos lo necesario
import 'dart:convert'; // Libreria para que podamos trabajar con json
import 'package:flutter/services.dart' show rootBundle;

/*
* Clase que lee el fichero con las opciones el menu, rellenando las fields del menu
*/
class _MenuProvider {
  List<dynamic> opciones = [];

  // Lo hacemos privado porque solo tenemos que hacer una instancia de la misma, para eso el final de abajo
  _MenuProvider();

  Future<List<dynamic>> cargarData() async {
    final resp = await rootBundle.loadString('data/menu_opts.json');

    // Creamos el mapa, ya que tenemos un String
    Map dataMap = json.decode(resp);

    // Cogemos las opciones que tenemos dentro del json
    opciones = dataMap['rutas'];

    return opciones;
  }
}

// Creamos una instancia del menu, slo una en toda la app
final menuProvider = new _MenuProvider();
