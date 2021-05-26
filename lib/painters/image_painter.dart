import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ImagePainter extends CustomPainter {
  final ui.Image image;
  final double scale;
  ImagePainter({this.image, this.scale});

  @override
  void paint(Canvas canvas, Size size) async {
    canvas.scale(scale);
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
