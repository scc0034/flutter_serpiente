import 'package:flutter/material.dart';
import 'package:flutter_snake/src/services/sing_in_service.dart';
import 'package:flutter_snake/src/widget/go_back.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class RankFromPage extends StatefulWidget {
  // Valor para pasar entre ventanas, es la puntuación del juego
  int value = 0;
  //Constructor
  RankFromPage({this.value});
  @override
  _RankFromPageState createState() => _RankFromPageState(value);
}

/*
* Clase que controla la entrada de los datos para la base de datos
*/
class _RankFromPageState extends State<RankFromPage> {
  // Atributos del fomulario
  final _formKey = GlobalKey<FormState>();
  String _correoForm = emailGoogle;
  String _nombreForm = nameGoogle;
  int _puntosForm = 0;
  Firestore firestoreDB;

  // Contructor
  _RankFromPageState(int p) {
    this._puntosForm = p;
  }

  @override
  void initState() {
    super.initState();
    firestoreDB = Firestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MenuLateral(),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: GoBack.volverAtras(context),
          title: Text("Rank Form"),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
          children: <Widget>[
            Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    CircleAvatar(
                      maxRadius: 60,
                      minRadius: 30,
                      backgroundImage: NetworkImage(
                        imageUrlGoogle,
                      ),
                    ),
                    Divider(),
                    _crearEmail(),
                    Divider(),
                    _crearPuntos(),
                    Divider(),
                    _crearNombre(),
                    Divider(),
                    _crearBoton(),
                  ],
                ))
          ],
        ));
  }

  ///Método que nos da el widget de entrada del correo
  Widget _crearEmail() {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      readOnly: true,
      enabled: false,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          labelText: _correoForm,
          hintText: "Email",
          suffixIcon: Icon(Icons.alternate_email),
          icon: Icon(Icons.email)),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  ///Métood que devuelve el widget de nick
  Widget _crearNombre() {
    return TextField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          hintText: _nombreForm,
          labelText: "Nick ",
          suffixIcon: Icon(Icons.person),
          icon: Icon(Icons.person_outline)),
      onChanged: (value) {
        setState(() {
          _nombreForm = value;
        });
      },
    );
  }

  /// Widget de los puntos no editable
  Widget _crearPuntos() {
    return TextField(
      enabled: false,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          labelText: "Puntos: ${_puntosForm.toString()}",
          hintText: "Puntuación",
          icon: Icon(Icons.sentiment_very_satisfied)),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  ///Método que devuelve el botón de submit
  RaisedButton _crearBoton() {
    return RaisedButton(
      color: Theme.of(context).primaryColor,
      onPressed: () {
        _guardarBD();
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            Navigator.pushNamed(context, "rank");
          });
        });
      },
      child: Text(
        "Submit",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  ///Métoo para guardar/actualizar los campos del usuario
  Future<void> _guardarBD() async {
    // Dentro de guardar mostrar
    print("Dentro de guardar");
    // COgemos el documento por el correo del user, en el caso de que no exista crea uno
    DocumentReference doc =
        firestoreDB.collection("ranking").document(_correoForm);
    Map<String, dynamic> data = {
      "imageUrl": imageUrlGoogle,
      "nombre": _nombreForm,
      "puntos": _puntosForm,
      "fecha": FieldValue.serverTimestamp() //Guarda la fecha del server
    };

    try {
      /*
       * Crea el documento en el caso de que no este en la base de datos, 
       * con los datos anteriores, de data.
       */
      doc.setData(data);
    } catch (err) {
      print("El error del update es: $err");
    }
  }
}
