import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_snake/src/widget/menu_lateral.dart';
import 'package:url_launcher/url_launcher.dart'; // Permite abrir el navegador web
import 'package:flutter_email_sender/flutter_email_sender.dart'; // Compose to
import 'package:flutter_snake/src/widget/carousel.dart'; // corousel imagenes
//import 'package:flutter_phone_state/flutter_phone_state.dart';// Pretendia usarlo para llamadas

/*
 * Clase que contiene información relevante sobre la aplicación.
 * 
 * La libreria que he usado para abrir las páginas en el navegador se 
 * encuentra en el siguiente enlace:
 * https://codemeals.com/flutter/launch-a-url-in-flutter/
 * 
 * Libreria para abrir el compose de email
 */
// ignore: must_be_immutable
class AboutPage extends StatelessWidget {
  //Atributos de la clase
  final Map<String, String> _mapaUrl = {
    "linkedin": "https://www.linkedin.com/in/samuel-casal-cantero-631022188/",
    "github": "https://github.com/scc0034/flutter_serpiente",
    "ubu": "https://www.ubu.es/",
    "gmail": ""
  };
  // Variables para el envio del correo
  bool isHTML = false;
  final _recipientController = TextEditingController(
    text: 'scc0034@alu.ubu.es',
  );
  final _subjectController = TextEditingController(text: 'Flutter snake');
  final _bodyController = TextEditingController(
    text: 'Me ha gustado mucho tu aplicación.',
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuLateral(),
      appBar: AppBar(
        title: Text("About Page"),
      ),
      // Contenido de la parte de about
      body: SingleChildScrollView(
          child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //Imagen personal
              CircleAvatar(
                backgroundColor: Colors.cyan[100],
                backgroundImage: AssetImage('assets/img/avatar.jpg'),
                radius: 75,
              ),
              _separador(),
              // Texto con mi nombre
              Text(
                'Samuel Casal',
                textScaleFactor: 3,
              ),
              _separador(),
              Container(
                child: Carousel(),
              ),
              _separador(),
              // Fila contenedora de los iconos
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _iconoBoton("linkedin"),
                  _iconoBoton("github"),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _iconoBoton("gmail"),
                  _iconoBoton("ubu"),
                ],
              ),
              /*FloatingActionButton(
                    onPressed: (){},//_initiateCall(),
                    child: Icon(Icons.phone)
                  ),*/
            ],
          ),
        ),
      )),
    );
  }

  /// Devuelve separador de 15 px altura
  Widget _separador() {
    return SizedBox(
      height: 15,
    );
  }

  /// Método que crea el iconoBoton
  Widget _iconoBoton(String k) {
    return FlatButton.icon(
      icon: SizedBox(
          width: 20, height: 20, child: Image.asset('assets/img/$k.png')),
      label: Text(k.toString()),
      onPressed: () {
        if (k.toString().compareTo("gmail") == 0) {
          send();
        } else {
          _launchURL(_mapaUrl[k]);
        }
      },
    );
  }

  ///Método que se encarga de abrir el navegador para llevarnos al enlace
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  ///Método para enviar correo
  Future<void> send() async {
    final Email email = Email(
      body: _bodyController.text,
      subject: _subjectController.text,
      recipients: [_recipientController.text],
      isHTML: isHTML,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      platformResponse = error.toString();
    }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(platformResponse),
    ));
  }

  /*_initiateCall() {
    FlutterPhoneState.startPhoneCall("636 13 15 17");
  }*/
}
