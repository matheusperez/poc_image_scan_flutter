import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
//import 'package:flutter/services.dart' show rootBundle;
//import 'package:exif/exif.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'image_scan_preview.dart';
import 'painters/crop_painter.dart';
import 'painters/image_painter.dart';
import 'widgets/button_action_widget.dart';
import 'widgets/loading_widget.dart';

const double X = 52;
const double YT = 120;
const double YB = 80;

enum StatusImage { loading, rotate, done }

class ImageScanCrop extends StatefulWidget {
  final File file;
  final bool cropAgain;

  ImageScanCrop(this.file, {this.cropAgain = false});
  _ImageScanCropState createState() => _ImageScanCropState();
}

class _ImageScanCropState extends State<ImageScanCrop> {
  final GlobalKey key = GlobalKey();

  Size get _size => MediaQuery.of(context).size;
  double get scale => (_displayImage != null) ? _size.width / _displayImage.width : 1;
  StatusImage state = StatusImage.rotate;
  File _currentFile;
  ui.Image _displayImage;

  double widgetWidth;
  double widgetHeight;
  double get imageWidth => (_displayImage != null) ? _displayImage.width.toDouble() : _size.width;
  double get imageHeight => (_displayImage != null) ? _displayImage.height.toDouble() : _size.width;

  // NOTE Crop
  Offset tl, tr, bl, br;

  // NOTE rotação
  double _angle = 0.0;

  @override
  void initState() {
    super.initState();
    _currentFile = widget.file;
    _rotate();
  }

  _rotate() async {
    try {
      _displayImage = await _rotateImage(_angle);
      _setState(StatusImage.loading);
      await _createLineCrop();
      _setState(StatusImage.done);
    } catch (e, stack) {
      log(' Erro! $e');
      log(stack.toString());
    }
  }

  _setState(StatusImage value) => setState(() => state = value);
  //

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          alignment: Alignment.center,
          child: (state == StatusImage.rotate)
              ? LoadingWidget()
              : Stack(
                  children: <Widget>[
                    GestureDetector(
                      onPanDown: _dragDownDetails,
                      onPanUpdate: _dragUpDetails,
                      child: SizedBox(
                        child: (_displayImage != null)
                            ? CustomPaint(
                                key: key,
                                painter: ImagePainter(image: _displayImage, scale: scale),
                                size: Size(imageWidth * scale, imageHeight * scale),
                              )
                            : null,
                      ),
                    ),
                    if (state == StatusImage.done) ...{
                      CustomPaint(painter: CropPainter(tl, tr, bl, br)),
                      _bottomSheet(),
                    },
                    if (state == StatusImage.rotate) ...{
                      Positioned(bottom: 0, top: 0, left: 0, right: 0, child: LoadingWidget())
                    },
                  ],
                ),
        ),
      ),
    );
  }

  // NOTE componentes
  Widget _bottomSheet() => Positioned(
        bottom: 10,
        right: 0,
        left: 0,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ButtonActionWidget(label: Icon(Icons.arrow_back, color: Colors.white), onTap: () => Navigator.pop(context)),
              // ButtonActionWidget(
              //     label: Icon(Icons.rotate_90_degrees_ccw, color: Colors.white),
              //     onTap: () {
              //       _setState(StatusImage.rotate);
              //       log('== LOGX angulo antigo = $_angle || ${math.pi / 98}');
              //       _angle = 100;
              //       //_angle += math.pi / 20;
              //       log('== LOGX angulo novo = $_angle');
              //       _rotate();
              //     }),
              ButtonActionWidget(
                label: Icon(Icons.save, color: Colors.white),
                onTap: () async {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ImageScanPreview(
                        tl: tl,
                        tr: tr,
                        bl: bl,
                        br: br,
                        widgetW: widgetWidth,
                        widgetH: widgetHeight,
                        imageW: imageWidth,
                        imageH: imageHeight,
                        file: _currentFile,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );

  // NOTE functions

  Future<ui.Image> _rotateImage(double angle) async {
    try {
      // NOTE converte a imagem em UI
      var bytesFile = await widget.file.readAsBytes();
      var codecFile = await ui.instantiateImageCodec(bytesFile);
      var nextFrame = await codecFile.getNextFrame();
      var image = nextFrame.image;

      var pictureRecorder = ui.PictureRecorder();
      Canvas canvas = Canvas(pictureRecorder);
      log('## ROTAÇÃO ## $angle');
      final double r = math.sqrt(image.width * image.width + image.height * image.height) / 2;
      final alpha = math.atan(image.height / image.width);
      final gama = alpha + angle;
      final shiftY = r * math.sin(gama);
      final shiftX = r * math.cos(gama);
      final translateX = image.width / 2 - shiftX;
      final translateY = image.height / 2 - shiftY;
      canvas.translate(translateX, translateY);
      canvas.rotate(angle);
      canvas.drawImage(image, Offset.zero, Paint());

      var imageRotated = await pictureRecorder.endRecording().toImage(image.width, image.height);

      var byteData = await imageRotated.toByteData(format: ui.ImageByteFormat.png);
      var buffer = byteData.buffer.asUint8List();

      // NOTE atualiza imagem
      Directory _dir = await getTemporaryDirectory();
      var d = DateTime.now();
      String temp = '${_dir.path}/tmp_scan_${d.year}${d.month}${d.day}.jpeg';

      _currentFile = await File(temp).writeAsBytes(buffer);
      return imageRotated;
    } catch (e) {
      log('LOGX == ERRO DETECTADO $e');
      return null;
    }
  }

  //
  // final double increment = pi / 18; // 10 degrees

  // NOTE crop
  _dragDownDetails(DragDownDetails details) => _changePositionCrop(details.localPosition);
  _dragUpDetails(DragUpdateDetails details) => _changePositionCrop(details.localPosition);
  _changePositionCrop(Offset localPosition) {
    double x1 = localPosition.dx;
    double y1 = localPosition.dy;
    double x2 = tl.dx;
    double y2 = tl.dy;
    double x3 = tr.dx;
    double y3 = tr.dy;
    double x4 = bl.dx;
    double y4 = bl.dy;
    double x5 = br.dx;
    double y5 = br.dy;
    if (math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) < 30 && x1 >= 0 && y1 >= 0 && x1 < widgetWidth / 2 && y1 < widgetHeight / 2) {
      setState(() {
        tl = localPosition;
      });
    } else if (math.sqrt((x3 - x1) * (x3 - x1) + (y3 - y1) * (y3 - y1)) < 30 && x1 >= widgetWidth / 2 && y1 >= 0 && x1 < widgetWidth && y1 < widgetHeight / 2) {
      setState(() {
        tr = localPosition;
      });
    } else if (math.sqrt((x4 - x1) * (x4 - x1) + (y4 - y1) * (y4 - y1)) < 30 && x1 >= 0 && y1 >= widgetHeight / 2 && x1 < widgetWidth / 2 && y1 < widgetHeight) {
      setState(() {
        bl = localPosition;
      });
    } else if (math.sqrt((x5 - x1) * (x5 - x1) + (y5 - y1) * (y5 - y1)) < 30 && x1 >= widgetWidth / 2 && y1 >= widgetHeight / 2 && x1 < widgetWidth && y1 < widgetHeight) {
      setState(() {
        br = localPosition;
      });
    }
  }

  _createLineCrop() async {
    // SE Não tiver carregado o imagem, fica em loop ate carregar o widget da imagem
    if (key.currentContext == null) {
      await Future.delayed(Duration(milliseconds: 50));
      await _createLineCrop();
      return;
    }
    RenderBox imageBox = key.currentContext.findRenderObject();
    widgetWidth = imageBox.size.width;
    widgetHeight = imageBox.size.height;

    tl = Offset(X, YT);
    tr = Offset(_size.width - X, YT);
    bl = Offset(X, widgetHeight - YB);
    br = Offset(_size.width - X, widgetHeight - YB);
  }
}
