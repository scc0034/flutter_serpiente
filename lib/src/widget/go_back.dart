import 'package:flutter/material.dart';

class GoBack{
  BuildContext context;
  GoBack({this.context});

  static Widget volverAtras(BuildContext context){ 
    return IconButton(
      icon: Icon(Icons.arrow_back), 
      onPressed: (){
        Navigator.pop(context);
      },
    );
  }
}