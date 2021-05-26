import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'image_scan_crop.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Scan"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(child: Text('Camera'), onPressed: () => chooseImage(ImageSource.camera)),
            RaisedButton(child: Text('Galeria'), onPressed: () => chooseImage(ImageSource.gallery))
          ],
        ),
      ),
    );
  }

  void chooseImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ImageScanCrop(File(pickedFile.path))),
      );
    }
  }
}
