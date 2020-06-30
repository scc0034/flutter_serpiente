import 'package:flutter/material.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';

class RankPage extends StatefulWidget {
  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuLateral(),
        appBar: AppBar(
          title : Text("RankForm Page"),
        ),
        body: Container()
    );
  }
}