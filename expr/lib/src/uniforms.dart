part of '../expr.dart';

/// [Scalar] that can be modified at runtime.
class ScalarUniform extends Scalar {
  ScalarUniform() : super._(OpLoad(OpVariable.scalarUniform()));

  /// Current value of the uniform. Returned by [evaluate], and
  /// bound to shaders using this uniform each frame.
  double get value => _node.variable[0];

  /// Set the current value of the uniform. Will be returned by
  /// [evaluate] and bound to shaders that use this uniform.
  set value(double x) => _node.variable[0] = x;
}

/// [Vec2] that can be modified at runtime.
class Vec2Uniform extends Vec2 {
  Vec2Uniform() : super._(OpLoad(OpVariable.vec2Uniform()));

  /// Current value of the uniform. Returned by [evaluate], and
  /// bound to shaders using this uniform each frame.
  vm.Vector2 get value =>
      vm.Vector2.fromFloat32List(Float32List.fromList(_node.variable));

  /// Set the current value of the uniform. Will be returned by
  /// [evaluate] and bound to shaders that use this uniform.
  set value(vm.Vector2 val) {
    _node.variable[0] = val.x;
    _node.variable[1] = val.y;
  }
}

/// [Vec3] that can be modified at runtime.
class Vec3Uniform extends Vec3 {
  Vec3Uniform() : super._(OpLoad(OpVariable.vec3Uniform()));

  /// Current value of the uniform. Returned by [evaluate], and
  /// bound to shaders using this uniform each frame.
  vm.Vector3 get value =>
      vm.Vector3.fromFloat32List(Float32List.fromList(_node.variable));

  /// Set the current value of the uniform. Will be returned by
  /// [evaluate] and bound to shaders that use this uniform.
  set value(vm.Vector3 val) {
    _node.variable[0] = val.x;
    _node.variable[1] = val.y;
    _node.variable[2] = val.z;
  }
}

/// [Vec4] that can be modified at runtime.
class Vec4Uniform extends Vec4 {
  Vec4Uniform() : super._(OpLoad(OpVariable.vec4Uniform()));

  /// Current value of the uniform. Returned by [evaluate], and
  /// bound to shaders using this uniform each frame.
  vm.Vector4 get value =>
      vm.Vector4.fromFloat32List(Float32List.fromList(_node.variable));

  /// Set the current value of the uniform. Will be returned by
  /// [evaluate] and bound to shaders that use this uniform.
  set value(vm.Vector4 val) {
    _node.variable[0] = val.x;
    _node.variable[1] = val.y;
    _node.variable[2] = val.z;
    _node.variable[3] = val.w;
  }
}
