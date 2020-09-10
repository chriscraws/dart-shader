part of '../expr.dart';

/// [Scalar] that can be modified at runtime.
class ScalarUniform extends Scalar {
  /// Current value of the uniform. Returned by [evaluate], and
  /// bound to shaders using this uniform each frame.
  double value = 0;

  ScalarUniform() : super._(Node.scalarUniform(() => value));
}

/// [Vec2] that can be modified at runtime.
class Vec2Uniform extends Vec2 {
  /// Current value of the uniform. Returned by [evaluate], and
  /// bound to shaders using this uniform each frame.
  Vector2 value = Vector2.zero();

  Vec2Uniform() : super._(Node.vec2Uniform(() => value));
}

/// [Vec3] that can be modified at runtime.
class Vec3Uniform extends Vec3 {
  /// Current value of the uniform. Returned by [evaluate], and
  /// bound to shaders using this uniform each frame.
  Vector3 value = Vector3.zero();

  Vec3Uniform() : super._(Node.vec3Uniform(() => value));
}

/// [Vec4] that can be modified at runtime.
class Vec4Uniform extends Vec4 {
  /// Current value of the uniform. Returned by [evaluate], and
  /// bound to shaders using this uniform each frame.
  Vector4 value = Vector4.zero();

  Vec4Uniform() : super._(Node.vec4Uniform(() => value));
}
