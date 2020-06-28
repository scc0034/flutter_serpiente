import 'package:flutter/material.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';

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