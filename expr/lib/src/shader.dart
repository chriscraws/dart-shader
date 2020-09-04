part of '../expr.dart';

/// Shader can be used to construct a spir-v module
/// compatible with Flutter.
class Shader {
  /// The color of each fragment position.
  final Vec4 color;

  Shader({this.color}) : assert(color != null);

  /// Encode the shader as Flutter-compatible SPIR-V.
  ByteBuffer toSPIRV() {
    final module = spirv.Module();
    module.color = color._instruction;
    return module.encode();
  }
}
