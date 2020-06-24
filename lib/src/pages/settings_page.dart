import 'package:flutter/material.dart';
import 'package:flutter_snake/src/utils/theme.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/**
 * Clase que para controlar algunas de las opciones de la app
 * Página persistencia de datos:
 * https://pusher.com/tutorials/local-data-flutter
 */
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}


class _SettingsPageState extends State<SettingsPage> with ChangeNotifier {

  // Variable que controla el botón de darkMode
  bool _cambiarColor = false;

  @override
  void initState() {
    super.initState();
    _loadCambiarColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuLateral(),
        appBar: AppBar(
          title: Text("Settings Page"),
          ),
          body: Container(
          padding: EdgeInsets.only(top:25),
          child: Column(
            children: <Widget>[

            _crearSwitch(context),

          ],
        )  
      ),
    );
  }

  /**
   * Método que crea el switch para controlar el darkMode
   */
  Widget _crearSwitch(BuildContext context){

    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    
    return SwitchListTile(
      value: _cambiarColor,
      title: Text('Dark Mode'),
      subtitle: Text('This app helps to activate the Android night mode on devices that do not provide this option in the system settings.'),
      onChanged: (valor) {
        setState(() {
          _cambiarColor = valor;
          _storeCambiarColor();
          if (valor){
            _themeChanger.setTheme(ThemeData.dark());
          }else{
            _themeChanger.setTheme(ThemeData.light());
          };
        });
      },
    );
  }

  /**
   * Función de persistencia, carga
   */
  _loadCambiarColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _cambiarColor = (prefs.getBool('cambiarColor') ?? false);
    });
  }

  /**
   * Función de persistencia, guarda.
   */
  _storeCambiarColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('cambiarColor', _cambiarColor);
    });
  }
}