part of '../expr.dart';

/// Vector [Expression] with two components.
class Vec2 extends Expression {
  Vec2._(Node child) : super._(child);

  /// Construct a constant Vec2 with value [x, y].
  Vec2(double x, double y) : super._(Node.vec2(x, y));

  /// Construct a constant Vec2 with value [x, x].
  Vec2.all(double x) : super._(Node.vec2(x, x));

  /// Construct from existing [Scalar] expressions.
  Vec2.of(Scalar x, Scalar y) : super._(Node.compositeVec2([x._node, y._node]));

  /// Return the inverse tangent of `x / y`. Component-wise.
  factory Vec2.aTan2(Vec2 x, Vec2 y) => Vec2._(Node.atan2(x._node, y._node));

  /// Return the minimum value between x and y. Component-wise.
  factory Vec2.min(Vec2 x, Vec2 y) => Vec2._(Node.min(x._node, y._node));

  /// Return the maximum value between x and y. Component-wise.
  factory Vec2.max(Vec2 x, Vec2 y) => Vec2._(Node.max(x._node, y._node));

  /// Returns the sum of this vector and [b].
  Vec2 operator +(Vec2 b) => Vec2._(Node.add(this._node, b._node));

  /// Returns the difference of this vector and [b].
  Vec2 operator -(Vec2 b) => Vec2._(Node.subtract(this._node, b._node));

  /// Equivalent to `this * Vec2.all(-1)`.
  Vec2 operator -() => Vec2._(Node.negate(this._node));

  /// Multiply by [b]. Component-wise.
  Vec2 operator *(Vec2 b) => Vec2._(Node.multiply(this._node, b._node));

  /// Divide by [b]. Component-wise.
  Vec2 operator /(Vec2 b) => Vec2._(Node.divide(this._node, b._node));

  /// Modulo by [b]. Component-wise.
  Vec2 operator %(Vec2 b) => Vec2._(Node.mod(this._node, b._node));

  /// Raise to the power of [b]. Component-wise.
  Vec2 operator ^(Vec2 b) => Vec2._(Node.pow(this._node, b._node));

  /// Length.
  Scalar length() => Scalar._(Node.length(this._node));

  /// Dot product.
  Scalar dot(Vec2 b) => Scalar._(Node.dot(this._node, b._node));

  /// Scale by [s].
  Vec2 scale(Scalar s) => Vec2._(Node.scale(this._node, s._node));

  /// Truncate. Component-wise.
  Vec2 truncate() => Vec2._(Node.truncate(this._node));

  /// Absolute value. Component-wise.
  Vec2 abs() => Vec2._(Node.abs(this._node));

  /// Returns [1] for postive values and [-1] for negative values.
  /// Component-wise.
  Vec2 sign() => Vec2._(Node.sign(this._node));

  /// Strip decimals. Component-wise.
  Vec2 floor() => Vec2._(Node.floor(this._node));

  /// Round up. Component-wise.
  Vec2 ceil() => Vec2._(Node.ceil(this._node));

  /// Isolate the fractional (decimal) value. Component-wise.
  Vec2 fract() => Vec2._(Node.fract(this._node));

  /// Converts degrees to radians. Component-wise.
  Vec2 radians() => Vec2._(Node.radians(this._node));

  /// Converts radians to degrees. Component-wise.
  Vec2 degrees() => Vec2._(Node.degrees(this._node));

  /// Interprets value as theta and calculates the sine. Component-wise.
  Vec2 sin() => Vec2._(Node.sin(this._node));

  /// Interprets value as theta and calculates the cosine. Component-wise.
  Vec2 cos() => Vec2._(Node.cos(this._node));

  /// Interprets value as theta and calculates the tangent. Component-wise.
  Vec2 tan() => Vec2._(Node.tan(this._node));

  /// Inverse-sine. Component-wise.
  Vec2 asin() => Vec2._(Node.asin(this._node));

  /// Inverse-cosine. Component-wise.
  Vec2 acos() => Vec2._(Node.acos(this._node));

  /// Inverse-tangent. Component-wise.
  Vec2 atan() => Vec2._(Node.atan(this._node));

  /// Natural exponent, e raised to the power of this value. Component-wise.
  Vec2 exp() => Vec2._(Node.exp(this._node));

  /// Natural logarithm, base e. Component-wise.
  Vec2 log() => Vec2._(Node.log(this._node));

  /// 2 raised to the power of this value. Component-wise.
  Vec2 exp2() => Vec2._(Node.exp2(this._node));

  /// Base-2 logarithm. Component-wise.
  Vec2 log2() => Vec2._(Node.log2(this._node));

  /// Square root. Component-wise.
  Vec2 sqrt() => Vec2._(Node.sqrt(this._node));

  /// Inverse square root. [1 / sqrt(this._node)]. Component-wise.
  Vec2 isqrt() => Vec2._(Node.isqrt(this._node));

  /// Normalize the vector. Divide all components by vector length.
  Vec2 normalize() => Vec2._(Node.normalize(this._node));

  /// Step returns 0 if value is less than [edge], 1 otherwise. Component-wise.
  Vec2 step(Vec2 edge) => Vec2._(Node.step(edge._node, this._node));

  /// Clamp restricts the value to be between min and max. Component-wise.
  Vec2 clamp(Vec2 min, Vec2 max) =>
      Vec2._(Node.clamp(this._node, min._node, max._node));

  /// Mix linearly interpolates between [a] and [b] as this value ranges from 0
  /// to 1. Component-wise.
  Vec2 mix(Vec2 a, Vec2 b) => Vec2._(Node.mix(a._node, b._node, this._node));

  /// Performs smooth Hermite interpolation between 0 and 1 as this value ranges
  /// from [a] to [b]. Component-wise.
  Vec2 smoothStep(Vec2 a, Vec2 b) =>
      Vec2._(Node.smoothStep(a._node, b._node, this._node));

  /// Orients the vector to point away from a surface as defined by its normal.
  /// Returns the vector unchanged if `dot(reference, incident)` is below zero.
  /// Otherwise return the vector scaled by -1.
  Vec2 faceForward(Vec2 incident, Vec2 reference) =>
      Vec2._(Node.faceForward(this._node, incident._node, reference._node));

  /// Calculate the reflection direction for an incident vector.
  /// Returns `this - 2.0 * dot(normal, this) * normal`.
  Vec2 reflect(Vec2 normal) => Vec2._(Node.reflect(this._node, normal._node));

  vm.Vector2 evaluate() => vm.Vector2.array(_node.evaluate());
}
