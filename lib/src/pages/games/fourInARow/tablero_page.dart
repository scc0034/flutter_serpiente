import 'package:flutter/material.dart';

class TableroPage extends StatefulWidget {
  @override
  _TableroPageState createState() => _TableroPageState();
}

class _TableroPageState extends State<TableroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        excludeHeaderSemantics: true,

        title: Text("Invitar amigo"),
      ),
      body: Column()
      
    );
  }
}