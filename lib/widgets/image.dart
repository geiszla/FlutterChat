import 'package:flutter/material.dart';

class ImageViewer extends StatefulWidget {
  @override
  ImageViewerState createState() => new ImageViewerState();
}

class ImageViewerState extends State<ImageViewer> {
  bool _isJPG = true;
  bool _isVeryDamaged = false;

  AssetImage peppersJpg = const AssetImage('assets/peppers.jpg');
  AssetImage damagedPeppersJpg = const AssetImage('assets/damagedpeppers.jpg');
  AssetImage peppersBmp = const AssetImage('assets/peppers.bmp');
  AssetImage damagedPeppersBmp = const AssetImage('assets/damagedpeppers.bmp');
  AssetImage veryDamagedPeppersBmp = const AssetImage('assets/verydamagedpeppers.bmp');

  Widget _buildImage(AssetImage image, double imageSize) {
    return new Image(
      image: image,
      width: imageSize,
      height: imageSize
    );
  }

  @override
  Widget build(BuildContext context) {
    const double imageSize = 315.0;

    List<Widget> images;
    if (_isJPG) {
      images = <Widget> [
        _buildImage(peppersJpg, imageSize),
        _buildImage(damagedPeppersJpg, imageSize)
      ];
    } else {
      images = <Widget> [
        _buildImage(peppersBmp, imageSize),
        _isVeryDamaged
            ? _buildImage(veryDamagedPeppersBmp, imageSize)
            : _buildImage(damagedPeppersBmp, imageSize)
      ];
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Image Viewer (${_isJPG ? 'JPG' : 'BMP'})'),
        actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.broken_image),
            onPressed: !_isJPG
                ? () => setState(() => _isVeryDamaged = !_isVeryDamaged)
                : null
          ),
          new IconButton(
            icon: const Icon(Icons.image),
            onPressed: () => setState(() => _isJPG = !_isJPG)
          ),
        ]
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: images
        )
      )
    );
  }
}
