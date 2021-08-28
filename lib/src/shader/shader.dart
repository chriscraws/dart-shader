part of '../../shader.dart';

/// Shader is a process that returns a color given a position and
/// uniform values. 
abstract class Shader<T> {
  Shader() {
    _module = Module();
    final pos = Vec2._(Module.position);
    _module.color = color(pos)._node;
    _spirv = _module.encode();
  }


  /// The color of each fragment position.
  Vec4 color(Vec2 position);

  vm.Vector4 evaluate(vm.Vector2 position) {
    if (_cachedExpression == null) {
      _cachedExpression = color(_position);
    }
    _position.value = position;
    return _cachedExpression!.evaluate();
  }

  List<double> packUniformValues() => _module.packUniformValues();

  /// Encode the shader as Flutter-compatible SPIR-V.
  ByteBuffer toSPIRV() {
    return _spirv;
  }

  final _position = Vec2Uniform();

  Vec4? _cachedExpression;
  late Module _module;
  late ByteBuffer _spirv;
}
