import 'package:flutter/material.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';
import 'package:firebase_admob/firebase_admob.dart';
 
// Variable que va a contener el id del dispositivo
const String testDevice = "TEST_DEVICE_ID";

class HomePage extends StatefulWidget {
  @override
  HomePage_State createState() => HomePage_State();
}

class HomePage_State extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuLateral(),
        appBar: AppBar(
          title : Text("Home Page"),
        ),
        body: Container(
          
        )
    );
  }
}
class HomePage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: MenuLateral(),
        appBar: AppBar(
          title : Text("Home Page"),
        ),
        body: Container(
          
        )
    );
  }
}