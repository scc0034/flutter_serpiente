import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UnirPage extends StatefulWidget {
  @override
  _UnirPageState createState() => _UnirPageState();
}

class _UnirPageState extends State<UnirPage> {

  ///Base de datos de firebase
  Firestore firestoreDB;
  final String _coleccionDB = "cuatrorows";
  String _codigoUnirse = "";
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        excludeHeaderSemantics: true,

        title: Text("Invitar amigo"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(30),
            child: _textFieldCodigo(),
          ),
          SizedBox(height: 20,),
          _crearBoton(),
        ],
      ),
      
    );
  }

  Widget _textFieldCodigo() {
    return TextField(
      enabled: true,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          labelText: "Code",
          hintText: "XxXxXxXxXxX",
      ),
      onChanged: (value) {
        setState(() {
          _codigoUnirse = value;
        });
      },
    );
  }

  RaisedButton _crearBoton() {
    return RaisedButton(
      color: Colors.blue,
      onPressed: () {
        _validateCode();
        /*Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            Navigator.pushNamed(context, "rank");
          });
        });*/
      },
      child: Text(
        "Connect",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _validateCode()async {
    DocumentReference docPartida = await firestoreDB.collection(_coleccionDB).document();
    docPartida.get().then((d) {
      if(d.exists){
        docPartida.updateData(data);
      }
    });
    
  }



}

