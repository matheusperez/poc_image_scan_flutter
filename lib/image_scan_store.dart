import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageScanStore {
  final File file;
  final double widgetW;
  final double widgetH;

  final double imageW;
  final double imageH;
  final Offset tl, tr, bl, br;
  final MethodChannel channel = new MethodChannel('opencv');

  double tlX;
  double trX;
  double blX;
  double brX;
  double tlY;
  double trY;
  double blY;
  double brY;

  Uint8List currentFileBytes;
  int angle = 0;

  ImageScanStore({
    this.file,
    this.widgetW,
    this.widgetH,
    this.imageW,
    this.imageH,
    this.tl,
    this.tr,
    this.bl,
    this.br,
  });

  // NOTE

  init() {
    tlX = (imageW / widgetW) * tl.dx;
    trX = (imageW / widgetW) * tr.dx;
    blX = (imageW / widgetW) * bl.dx;
    brX = (imageW / widgetW) * br.dx;

    tlY = (imageH / widgetH) * tl.dy;
    trY = (imageH / widgetH) * tr.dy;
    blY = (imageH / widgetH) * bl.dy;
    brY = (imageH / widgetH) * br.dy;
  }

  Future<bool> convertToGray() async {
    try {
      // ?? NOTO
      // List<int> imageBytes = await file.readAsBytes();

      // final originalImage = img.decodeImage(imageBytes);

      // final height = originalImage.height;
      // final width = originalImage.width;

      // if (height <= width) {
      //   final exifData = await readExifFromBytes(imageBytes);
      //   img.Image fixedImage = img.copyRotate(originalImage, 90);
      //   final fixedFile = await file.writeAsBytes(img.encodeJpg(fixedImage));

      //   final aaaa = img.decodeImage(fixedFile.readAsBytesSync());
      //   log('## [$width] [$height]  || ${(height >= width)} || ${exifData['Image Orientation']} ##');
      //   log('### [${aaaa.width}] [${aaaa.height}]');
      // }

      // END
      var bytesArray = await channel.invokeMethod('convertToGray', {
        'filePath': file.path,
        'tl_x': tlX,
        'tl_y': tlY,
        'tr_x': trX,
        'tr_y': trY,
        'bl_x': blX,
        'bl_y': blY,
        'br_x': brX,
        'br_y': brY,
      });

      currentFileBytes = bytesArray;
      return true;
    } catch (e) {
      log('LOX ==> [$e]');
      return false;
    }
  }

  Future<bool> rotateScan() async {
    try {
      await Future.delayed(Duration(seconds: 1));

      currentFileBytes = await channel.invokeMethod('rotate', {
        'bytes': currentFileBytes
      });

      await Future.delayed(Duration(seconds: 4));

      angle = (angle == 360) ? 0 : angle + 90;
      currentFileBytes = await channel.invokeMethod('rotateCompleted', {
        'bytes': currentFileBytes
      });
      return true;
    } catch (e) {
      log('LOX ==> [$e]');
      return false;
    }
  }
}
