import 'package:flutter/material.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';

class RankFromPage extends StatefulWidget {
  @override
  _RankFromPageState createState() => _RankFromPageState();
}

class _RankFromPageState extends State<RankFromPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuLateral(),
        appBar: AppBar(
          title : Text("RankForm Page"),
        ),
        body: Scaffold(
          body : Container(),
        )
    );
  }
  }
}