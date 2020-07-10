import 'package:flutter/material.dart';
import 'package:flutter_snake/src/providers/menu_provider.dart';
import 'package:flutter_snake/src/utils/icon_string_util.dart';
import 'package:flutter_snake/src/services/sing_in_service.dart';
import "package:flutter_snake/src/pages/login_page.dart";

/*
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

  /*
   * Método que nos devuelve el Widget de la cabecera,
   * este tiene que ir el primero de la lista
  */
  Widget _createHeader(BuildContext context) {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill, image: AssetImage('assets/img/snake.jpg'))),
        child: Stack(children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(),
            accountEmail: Text(emailGoogle,
                style: TextStyle(fontWeight: FontWeight.bold)),
            accountName:
                Text(nameGoogle, style: TextStyle(fontWeight: FontWeight.bold)),
            currentAccountPicture: GestureDetector(
              onTap: () {
                _mostrarAlerta(context);
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  imageUrlGoogle,
                ),
              ),
            ),
          ),
        ]));
  }

  ///Método que se encarga de crear la lista con los elementos
  Widget _createMenu(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        _createHeader(context),
        _createListaMenu(context),
      ],
    );
  }

  /*
   * Método que crea la lista de las opciones de menú a partir de los datos del json con el contenido del mismo
   */
  Widget _createListaMenu(BuildContext context) {
    return FutureBuilder(
      // Lo que esperamos
      future: menuProvider.cargarData(),
      // Info que tiene por defecto hasta el future devuelve
      initialData: [],
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        return ListView(
          shrinkWrap: true,
          children: _crearListaItems(snapshot.data, context),
        );
      },
    );
  }

  ///Método que crea una lista de ListTile a partir del contenido del json
  List<Widget> _crearListaItems(List<dynamic> data, BuildContext context) {
    //Creamos la lista que devolvemos
    final List<Widget> opciones = [];

    // Iteramos sobre los datos
    data.forEach((op) {
      // Creamos un Widget temporal
      final widgetTemp = ListTile(
        title: Text(op['texto']),
        leading: getIcon(op['icon']),
        onTap: () {
          Navigator.pushNamed(context, op['ruta']);
        }, // Sin definir el método
      );

      opciones
        ..add(widgetTemp)
        ..add(Divider(
          color: Colors.blueGrey,
        ));
    });

    opciones.add(
      Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ListTile(
            title: Text('Version:'),
            subtitle: Text('5.0.0'),
            onTap: () {},
          ),
        ],
      ),
    );

    return opciones;
  }

  ///Método para mostrar la alerta
  void _mostrarAlerta(BuildContext context) {
    // Tenemos que pasar el context para que la función sepa de que va la cosa
    showDialog(
        context: context,
        barrierDismissible: false, // Permite pulsar fuera para salir
        builder: (context) {
          return AlertDialog(
            title: Text('Sign Out'),
            content: Column(
              mainAxisSize: MainAxisSize
                  .min, // Controla que la ventana se ajuste al contenido
              children: <Widget>[
                CircleAvatar(
                  maxRadius: 50,
                  minRadius: 25,
                  backgroundImage: NetworkImage(
                    imageUrlGoogle,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Image.asset(
                      "assets/img/google_logo.png",
                      height: 14,
                    ),
                    SizedBox(),
                    Text(emailGoogle),
                  ],
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                // Funcionalidad para volver atrás de la ventana
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text('Sign Out'),
                onPressed: () {
                  signOutGoogle();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) {
                    return LoginPage(ads: false);
                  }), ModalRoute.withName('/'));
                },
              ),
            ],
          );
        });
  }
}
