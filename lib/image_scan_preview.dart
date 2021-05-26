import 'dart:io';

import 'package:flutter/material.dart';

import 'image_scan_crop.dart';
import 'image_scan_store.dart';

class ImageScanPreview extends StatefulWidget {
  final File file;
  final double widgetW;
  final double widgetH;
  final double imageW;
  final double imageH;
  final Offset tl, tr, bl, br;

  ImageScanPreview({
    this.file,
    this.bl,
    this.br,
    this.tl,
    this.tr,
    this.widgetW,
    this.widgetH,
    this.imageW,
    this.imageH,
  });
  @override
  _ImageScanPreviewState createState() => _ImageScanPreviewState();
}

class _ImageScanPreviewState extends State<ImageScanPreview> {
  ImageScanStore store;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    store = ImageScanStore(
      file: widget.file,
      widgetW: widget.widgetW,
      widgetH: widget.widgetH,
      imageW: widget.imageW,
      imageH: widget.imageH,
      tl: widget.tl,
      tr: widget.tr,
      bl: widget.bl,
      br: widget.br,
    );
    store.init();
    store.convertToGray().then((value) => _setLoading(!value));
  }

  @override
  void dispose() {
    super.dispose();
  }

  _setLoading(bool value) => setState(() => isLoading = value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                isLoading
                    ? Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height * .8,
                          alignment: Alignment.center,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      )
                    : Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                        //   padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        child: Image.memory(store.currentFileBytes),
                      ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: IconButton(
          icon: Icon(
            Icons.crop,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => ImageScanCrop(store.file),
            ));
          },
        ));
  }
}
