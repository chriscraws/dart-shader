part of '../../expr.dart';

/// Sample from an [Image]
class Sampler {
  Image _image;
  Future<ByteData> _dataFuture;
  ByteData _resolvedData;
  ShaderFunction _function;

  Sampler(Image image) {
    setImage(image);
    _function = ShaderFunction(_evaluator);
  }

  Vec4 sample(Vec2 pos) => Vec4._(_function(pos._node));

  Future<void> get ready async => _dataFuture;

  Future<void> setImage(Image image) async {
    assert(image != null);
    _image = image;
    _dataFuture = image.toByteData();
    _resolvedData = await _dataFuture;
  }

  void _evaluator(double x, double y, List<double> result) {
    if (_resolvedData == null) {
      return;
    }
    final xi = (x * _image.width).floor() % _image.width;
    final yi = (y * _image.height).floor() % _image.height;
    final byteIndex = (xi + yi * _image.width) * 4;
    assert(byteIndex < _resolvedData.lengthInBytes);
    result[0] = _resolvedData.getUint8(byteIndex + 0).toDouble() / 255.0;
    result[1] = _resolvedData.getUint8(byteIndex + 1).toDouble() / 255.0;
    result[2] = _resolvedData.getUint8(byteIndex + 2).toDouble() / 255.0;
    result[3] = _resolvedData.getUint8(byteIndex + 3).toDouble() / 255.0;
  }
}
