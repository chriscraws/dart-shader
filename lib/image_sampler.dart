import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:expr/expr.dart';
import 'package:vector_math/vector_math_64.dart';

/// Sample from an [Image]
class ImageSampler extends Sampler<ui.Shader> {
  ui.Image _image;
  Future<ByteData> _dataFuture;
  ByteData _resolvedData;

  ImageSampler(
    ui.Image image, {
    ui.TileMode tmx = ui.TileMode.repeated,
    ui.TileMode tmy = ui.TileMode.repeated,
    Matrix4 matrix4,
  }) : super(ui.ImageShader(image, tmx, tmy,
            matrix4 == null ? Matrix4.identity().storage : matrix4.storage)) {
    setImage(image);
  }

  Future<void> get ready async => _dataFuture;

  Future<void> setImage(ui.Image image) async {
    assert(image != null);
    _image = image;
    _dataFuture = image.toByteData();
    _resolvedData = await _dataFuture;
  }

  double evaluate(double x, double y, int channel) {
    if (_resolvedData == null) {
      return 0;
    }
    final xi = (x * _image.width).floor() % _image.width;
    final yi = (y * _image.height).floor() % _image.height;
    final byteIndex = (xi + yi * _image.width) * 4;
    assert(byteIndex < _resolvedData.lengthInBytes);
    assert(channel < 4);
    return _resolvedData.getUint8(byteIndex + channel).toDouble() / 255.0;
  }
}
