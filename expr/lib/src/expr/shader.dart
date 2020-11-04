part of '../../expr.dart';

/// Shader can be used to construct a spir-v module
/// compatible with Flutter.
abstract class Shader {
  Shader() {
    _module = Module();
    final pos = Vec2._(Module.position);
    _module.color = color(pos)._node;
    _spirv = _module.encode();
  }

  final _position = Vec2Uniform();

  Vec4 _cachedExpression;
  Module _module;
  ByteBuffer _spirv;

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

  void writeUniformData(void Function(int, double) setter) {
    _module.writeUniformData(setter);
  }

  /// Encode the shader as Flutter-compatible SPIR-V.
  ByteBuffer toSPIRV() {
    return _spirv;
  }
}
