part of '../../expr.dart';

/// Sample from an [Image]
class Sampler {
  Image _image;
  FutureOr<ByteData> _data;
  ShaderFunction _function;

  Sampler(Image image) {
    setImage(image);
    _function = ShaderFunction(_evaluator);
  }

  Vec4 sample(Vec2 pos) => Vec4._(_function(pos._node));

  Future<void> get ready async => _data;

  Future<void> setImage(Image image) async {
    assert(image != null);
    _image = image;
    _data = image.toByteData();
    await _data;
  }

  void _evaluator(double x, double y, List<double> result) {
    if (_data == null || _data is Future<ByteData>) {
      return;
    }
    final bytes = _data as ByteData;
    final xi = (x * _image.width).floor() % _image.width;
    final yi = (y * _image.height).floor() % _image.height;
    final byteIndex = (xi + yi * _image.width) * 4;
    assert(byteIndex < bytes.lengthInBytes);
    result[0] = bytes.getUint8(byteIndex + 0).toDouble() / 255.0;
    result[1] = bytes.getUint8(byteIndex + 1).toDouble() / 255.0;
    result[2] = bytes.getUint8(byteIndex + 2).toDouble() / 255.0;
    result[3] = bytes.getUint8(byteIndex + 3).toDouble() / 255.0;
  }
}
