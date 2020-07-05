import 'package:flutter/material.dart';
import 'package:flutter_snake/src/services/admob_service.dart';
import 'package:flutter_snake/src/utils/theme.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';
import 'package:provider/provider.dart';
import 'package:flutter_snake/src/models/variables_persistentes.dart';
import 'package:flutter_snake/src/services/database_service.dart';

/*
 * Clase que para controlar algunas de las opciones de la app
 * Página persistencia de datos:
 * https://pusher.com/tutorials/local-data-flutter
 */
// ignore: must_be_immutable
class SettingsPage extends StatefulWidget {
  bool ads = false;
  SettingsPage({this.ads});

  @override
  _SettingsPageState createState() => _SettingsPageState(ads : this.ads);
}

class _SettingsPageState extends State<SettingsPage> with ChangeNotifier {

  bool ads = false;

  _SettingsPageState({this.ads});

  // Servicios de la base de datos
  DatabaseService dbService = DatabaseService.instance;

  // Atributos de la clase
  Map<int, bool> _mapaValores = {
    0: false,
    1: true,
  }; // Mapa de valores
  // Variables de cada uno de los selectores
  bool _selectorColor = false;
  bool _selectorVelocidad = false;
  bool _selectorBloques = false;
  bool _selectorMusica = false;
  bool _selectorTuberias = false;

  // Vables con el nombre en el que se guarda en la base de datos
  String _selectorBloquesString = "selectorBloques";
  String _selectorColorString = "selectorColor";
  String _selectorVelocidadString = "selectorVelocidad";
  String _selectorMusicaString = "selectorMusica";
  String _selectorTuberiasString = "selectorTuberias";

  @override
  void initState() {
    super.initState();
    if(ads){
      AdMobService.showBannerAd();
    }else{
      AdMobService.hideBannerAd();
    }
    // Carga de los valores
    _loadVarFromDb(_selectorColorString, context);
    _loadVarFromDb(_selectorVelocidadString, context);
    _loadVarFromDb(_selectorBloquesString, context);
    _loadVarFromDb(_selectorMusicaString, context);
    _loadVarFromDb(_selectorTuberiasString, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuLateral(),
      appBar: AppBar(
        title: Text("Settings Page"),
      ),
      body: Container(
          padding: EdgeInsets.only(top: 25),
          child: Column(
            children: <Widget>[
              _crearSwitch(context),
              Divider(),
              _crearSwitchVelocidad(context),
              Divider(),
              _crearSwitchBloques(context),
              Divider(),
              _crearSwitchMusica(context),
              Divider(),
              _crearSwitchTuberia(context),
            ],
          )),
    );
  }

  ///Método que crea el switch para controlar el darkMode
  Widget _crearSwitch(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);

    return SwitchListTile(
      value: _selectorColor,
      title: Text('Dark Mode'),
      subtitle: Text(
          'This app helps to activate the Android night mode on devices that do not provide this option in the system settings.'),
      onChanged: (valor) {
        setState(() {
          if (valor) {
            _saveVarToDb(1, _selectorColorString);
            _themeChanger.setTheme(ThemeData.dark());
          } else {
            _saveVarToDb(0, _selectorColorString);
            _themeChanger.setTheme(ThemeData.light());
          }
        });
      },
    );
  }

  ///Método que añade a la lista de opciones la de Velocidad de la serpiente
  Widget _crearSwitchVelocidad(BuildContext context) {
    return SwitchListTile(
      value: _selectorVelocidad,
      title: Text('Hard mode'),
      subtitle: Text('Increase the speed of the snake by two.'),
      onChanged: (valor) {
        setState(() {
          if (valor) {
            _saveVarToDb(1, _selectorVelocidadString);
          } else {
            _saveVarToDb(0, _selectorVelocidadString);
          }
        });
      },
    );
  }

  ///Método que se encarga de crear el switch de selección de bloques
  Widget _crearSwitchBloques(BuildContext context) {
    return SwitchListTile(
      value: _selectorBloques,
      title: Text('Bloks mode'),
      subtitle: Text('Place repatted blocks across the board.'),
      onChanged: (valor) {
        setState(() {
          if (valor) {
            _saveVarToDb(1, _selectorBloquesString);
          } else {
            _saveVarToDb(0, _selectorBloquesString);
          }
        });
      },
    );
  }

  ///Método que devuelve el switch de la selección de la música
  Widget _crearSwitchMusica(BuildContext context) {
    return SwitchListTile(
      value: _selectorMusica,
      title: Text('Music'),
      subtitle: Text('Enable or disable game music'),
      onChanged: (valor) {
        setState(() {
          if (valor) {
            _saveVarToDb(1, _selectorMusicaString);
          } else {
            _saveVarToDb(0, _selectorMusicaString);
          }
        });
      },
    );
  }

  Widget _crearSwitchTuberia(BuildContext context) {
    return SwitchListTile(
      value: _selectorTuberias,
      title: Text('Pipes'),
      subtitle: Text('Enable or disable game pipes.'),
      onChanged: (valor) {
        setState(() {
          if (valor) {
            _saveVarToDb(1, _selectorTuberiasString);
          } else {
            _saveVarToDb(0, _selectorTuberiasString);
          }
        });
      },
    );
  }

  /// Método que guarga los datos en la base de datos local
  void _saveVarToDb(int valor, String nombre) async {
    // Creamos la variable que tenemos que insertar
    final variable = VariablesPersistentes.fromMap(
        {"value": valor, "nombre": nombre, "createdTime": DateTime.now()});

    // Hacemos el update, en el caso de que sea 0, tenemos que insertar
    final int filasCambiadas = await dbService.updateVar(nombre, valor);
    if (filasCambiadas == 0) {
      await dbService.insertVar(variable);
    }
    // Dependiendo de la variable que se guarda actualizamos el campo
    setState(() {
      if (nombre.compareTo(_selectorColorString) == 0) {
        _selectorColor = _mapaValores[valor];
      }
      if (nombre.compareTo(_selectorVelocidadString) == 0) {
        _selectorVelocidad = _mapaValores[valor];
      }
      if (nombre.compareTo(_selectorBloquesString) == 0) {
        _selectorBloques = _mapaValores[valor];
      }
      if (nombre.compareTo(_selectorMusicaString) == 0) {
        _selectorMusica = _mapaValores[valor];
      }
      if (nombre.compareTo(_selectorTuberiasString) == 0) {
        _selectorTuberias = _mapaValores[valor];
      }
    });
  }

  ///  Método que carga variables de la base de datos local
  void _loadVarFromDb(String nombre, BuildContext context) async {
    final VariablesPersistentes variable = await dbService.getVar(nombre);
    setState(() {
      if (nombre.compareTo(_selectorColorString) == 0) {
        if (variable == null || variable.value == 0) {
          _selectorColor = false;
          Provider.of<ThemeChanger>(context).setTheme(ThemeData.light());
        } else {
          _selectorColor = _mapaValores[variable.value];
          Provider.of<ThemeChanger>(context).setTheme(ThemeData.dark());
        }
      }

      if (nombre.compareTo(_selectorVelocidadString) == 0) {
        if (variable == null || variable.value == 0) {
          _selectorVelocidad = false;
        } else {
          _selectorVelocidad = _mapaValores[variable.value];
        }
      }

      if (nombre.compareTo(_selectorBloquesString) == 0) {
        if (variable == null || variable.value == 0) {
          _selectorBloques = false;
        } else {
          _selectorBloques = _mapaValores[variable.value];
        }
      }
      if (nombre.compareTo(_selectorMusicaString) == 0) {
        if (variable == null || variable.value == 0) {
          _selectorMusica = false;
        } else {
          _selectorMusica = _mapaValores[variable.value];
        }
      }
      if (nombre.compareTo(_selectorTuberiasString) == 0) {
        if (variable == null || variable.value == 0) {
          _selectorTuberias = false;
        } else {
          _selectorTuberias = _mapaValores[variable.value];
        }
      }
    });
  }
}
