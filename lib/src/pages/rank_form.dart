import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake/src/widget/menu_lateral.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankFromPage extends StatefulWidget {
  @override
  _RankFromPageState createState() => _RankFromPageState();
}

/**
 * Clase para controlar los datos que se meten en la colección de la base de datos
 * de Ranking, el packete que uso es : 
 * https://pub.dev/packages/cloud_firestore
 * Video que he seguigo para saber como hacerlo:
 * https://www.youtube.com/watch?v=osp1WL7W9Wo
 */
class _RankFromPageState extends State<RankFromPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuLateral(),
        appBar: AppBar(
          title : Text("RankForm Page"),
        ),
        
    );
  }
}