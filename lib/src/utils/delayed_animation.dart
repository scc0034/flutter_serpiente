import 'dart:async';
import 'package:flutter/material.dart';

/**
 * Clase que controla las animaciones de Flutter
 */
class DelayedAnimation extends StatefulWidget {
  // Atributos de la clase
  final Widget child;
  final int delay;

  // Constructor de la clase
  DelayedAnimation({@required this.child, this.delay});

  @override
  _DelayedAnimationState createState() => _DelayedAnimationState();
}

/**
 * Clase con estado
 */
class _DelayedAnimationState extends State<DelayedAnimation>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _animOffset;

  // Al iniciar
  @override
  void initState() {
    super.initState();

    // Controlador de las animaciones
    _controller =
        AnimationController(vsync:this, duration: Duration(milliseconds: 800));
    final curve =
        CurvedAnimation(curve: Curves.decelerate, parent: _controller);
    _animOffset =
        Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero)
            .animate(curve);

    // en el caso de que el delay sea nulo, no hay animación
    if (widget.delay == null) {
      _controller.forward();
    } else {
      // retrasamos la animación x delay
      Timer(Duration(milliseconds: widget.delay), () {
        _controller.forward();
      });
    }
  }

  // Al cerrar
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: SlideTransition(
        position: _animOffset,
        child: widget.child,
      ),
      opacity: _controller,
    );
  }
}