import 'package:flutter/material.dart';

class ButtonActionWidget extends StatelessWidget {
  final Widget label;
  final Function onTap;

  ButtonActionWidget({this.label, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.blue,
        ),
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: label,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
