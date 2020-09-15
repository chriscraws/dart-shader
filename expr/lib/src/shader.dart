part of '../expr.dart';

/// Shader can be used to construct a spir-v module
/// compatible with Flutter.
abstract class Shader {
  final _position = Vec2Uniform();

  Vec4 _cachedExpression;

  /// The color of each fragment position.
  ///
  /// This function should be a pure function and should have
  /// no side effects.
  Vec4 color(Vec2 position);

  vm.Vector4 evaluate(vm.Vector2 position) {
    if (_cachedExpression == null) {
      _cachedExpression = color(_position);
    }
    _position.value = position;
    return _cachedExpression.evaluate();
  }

  /// Encode the shader as Flutter-compatible SPIR-V.
  ByteBuffer toSPIRV() {
    final module = Module();
    final pos = Vec2._(Module.position);
    module.color = color(pos)._node;
    return module.encode();
  }
}
