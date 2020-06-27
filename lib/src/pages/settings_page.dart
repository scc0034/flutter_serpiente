import 'package:flutter/material.dart';
import 'package:flutter_snake/src/utils/theme.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_snake/src/models/variables_persistentes.dart';
import 'package:flutter_snake/src/services/database_service.dart';


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

  // Servicios de la base de datos
  //Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  DatabaseService dbService = DatabaseService.instance;
  // Variable que controla el botón de darkMode
  bool _selectorColor = false;
  Map<int,bool> _mapaValores = {
    0 : true,
    1: false,
  };

  @override
  void initState() {
    super.initState();
    _loadVarFromDb("selectorColor");
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
      value: _selectorColor,
      title: Text('Dark Mode'),
      subtitle: Text('This app helps to activate the Android night mode on devices that do not provide this option in the system settings.'),
      onChanged: (valor) {
        setState(() {
          print("valor del selector = $valor");
          if(valor){
            _saveVarToDb(1, "selectorColor");
            _themeChanger.setTheme(ThemeData.dark());
          }else{
            _saveVarToDb(0, "selectorColor");
            _themeChanger.setTheme(ThemeData.light());
          }
          print("Que tenemos dentro del selectorColor");
          print(_selectorColor);
        });
      },
    );
  }

  void _saveVarToDb(int valor, String nombre) async {
    print("Valor al guardar $valor");
    // Creamos la variable que tenemos que insertar
    final variable = VariablesPersistentes.fromMap({
      "value": valor,
      "nombre" : nombre,
      "createdTime": DateTime.now()
    });

    // Hacemos el update, en el caso de que sea 0, tenemos que insertar
    final int filasCambiadas = await dbService.updateVar(nombre, valor);
    print("filas cambiadas");
    print(filasCambiadas);
    if (filasCambiadas == 0){
      final int id = await dbService.insertVar(variable);
    }
    setState(() {
      if(nombre.compareTo("selectorColor") == 0){

        _selectorColor = _mapaValores[valor];
      }
    });
  }

  void _loadVarFromDb(String nombre) async {
    final VariablesPersistentes variable = await dbService.getVar(nombre);
    setState(() {
      if(nombre.compareTo("selectorColor") == 0){
        if (variable == null){
        _selectorColor = false;
        }else{
          _selectorColor = _mapaValores[variable.value];
        }  
      }
    });
  }

}