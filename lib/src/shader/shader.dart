part of '../../shader.dart';

/// Shader can be used to construct a spir-v module
/// compatible with Flutter.
abstract class Shader<T> {
  Shader() {
    _module = Module<T>();
    final pos = Vec2._(Module.position);
    _module.color = color(pos)._node;
    _spirv = _module.encode();
  }

  final _position = Vec2Uniform();

  Vec4 _cachedExpression;
  Module<T> _module;
  ByteBuffer _spirv;

  /// The color of each fragment position.
  ///
  /// This function should be a pure function and should have
  /// no side effects.
  Vec4 color(Vec2 position);

  List<T> get children => List<T>.unmodifiable(_module.children);

  vm.Vector4 evaluate(vm.Vector2 position) {
    if (_cachedExpression == null) {
      _cachedExpression = color(_position);
    }
    _position.value = position;
    return _cachedExpression.evaluate();
  }

  List<double> get uniformData => _module.uniformData;

  /// Encode the shader as Flutter-compatible SPIR-V.
  ByteBuffer toSPIRV() {
    return _spirv;
  }
}
