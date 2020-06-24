import 'package:flutter/material.dart';
import 'package:flutter_snake/src/providers/menu_provider.dart';
import 'package:flutter_snake/src/utils/icon_string_util.dart';

/**
 * Clase encargada de generar el menu lateral para toda la apliación.
 * Esta sacado de la documentación de flutter :
 * https://flutter.dev/docs/cookbook/design/drawer
 */
class MenuLateral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Contenedor del menu lateral
    return Drawer(
      // Lista de los items
      child: _createMenu(context),
    );
  }

  /**
   * Método que nos devuelve el Widget de la cabecera,
   * este tiene que ir el primero de la lista
  */
  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('assets/snake.jpg'))),
        child: Stack(children: <Widget>[
          Positioned(
              bottom: 12.0,
              left: 16.0,
              child: Text("Flutter Snake",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500))),
        ]));
  }

  /**
   * Método que se encarga de crear la lista con los elementos
   */
  Widget _createMenu(BuildContext context){
    return ListView(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          _createHeader(),
          _createListaMenu(context),
        ],
      );
  }

  /**
   * Método que crea la lista de las opciones de menú a partir de los datos del json con el contenido del mismo
   */
  Widget _createListaMenu(BuildContext context) {

    return FutureBuilder(
      // Lo que esperamos
      future : menuProvider.cargarData(),
      // Info que tiene por defecto hasta el future devuelve
      initialData: [],
      builder:  (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        return ListView(
          shrinkWrap: true,
          children: _crearListaItems(snapshot.data, context),
        );
      },
    );
  }
  
  /**
   * Método que crea una lista de ListTile a partir del contenido del json
   */
  List<Widget> _crearListaItems( List<dynamic> data, BuildContext context) {
    
    //Creamos la lista que devolvemos
    final List<Widget> opciones = [];

    // Iteramos sobre los datos
    data.forEach((op) {

      // Creamos un Widget temporal
      final widgetTemp = ListTile(
        title : Text(op['texto']),
        leading : getIcon(op['icon']), 
        onTap: (){
          Navigator.pushNamed(context, op['ruta']);
        }, // Sin definir el método
      );

      opciones..add(widgetTemp)
              ..add(Divider(color: Colors.blueGrey,));
    });

    opciones.add(Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        ListTile(
          title: Text('Version:'),
          subtitle: Text('0.0.1'),
          onTap: () {},
        ),
      ],
    ),);

    return opciones;
  }
}
