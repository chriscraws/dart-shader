part of '../expr.dart';

/// Vector [Expression] with four components.
class Vec4 extends Expression {
  Vec4._(Node child) : super._(child);

  /// Construct a constant Vec4 with value [x, y, z, w].
  Vec4(double x, double y, double z, double w) : super._(Node.vec4(x, y, z, w));

  /// Construct a constant Vec4 with value [x, x, x, x].
  Vec4.all(double x) : super._(Node.vec4(x, x, x, x));

  /// Construct Vec4 from existing expressions. The total number
  /// of elements in the expressions in [components] must be 4.
  Vec4.of(List<Expression> components)
      : super._(Node.compositeVec4(components.map((c) => c._node).toList()));

  /// Return the inverse tangent of `x / y`. Component-wise.
  factory Vec4.aTan2(Vec4 x, Vec4 y) => Vec4._(Node.atan2(x._node, y._node));

  /// Return the minimum value between x and y. Component-wise.
  factory Vec4.min(Vec4 x, Vec4 y) => Vec4._(Node.min(x._node, y._node));

  /// Return the maximum value between x and y. Component-wise.
  factory Vec4.max(Vec4 x, Vec4 y) => Vec4._(Node.max(x._node, y._node));

  /// Returns the sum of this vector and [b].
  Vec4 operator +(Vec4 b) => Vec4._(Node.add(this._node, b._node));

  /// Returns the difference of this vector and [b].
  Vec4 operator -(Vec4 b) => Vec4._(Node.subtract(this._node, b._node));

  /// Equivalent to `this * Vec4.all(-1)`.
  Vec4 operator -() => Vec4._(Node.negate(this._node));

  /// Multiply by [b]. Component-wise.
  Vec4 operator *(Vec4 b) => Vec4._(Node.multiply(this._node, b._node));

  /// Divide by [b]. Component-wise.
  Vec4 operator /(Vec4 b) => Vec4._(Node.divide(this._node, b._node));

  /// Modulo by [b]. Component-wise.
  Vec4 operator %(Vec4 b) => Vec4._(Node.mod(this._node, b._node));

  /// Raise to the power of [b]. Component-wise.
  Vec4 operator ^(Vec4 b) => Vec4._(Node.pow(this._node, b._node));

  /// Length.
  Scalar length() => Scalar._(Node.length(this._node));

  /// Dot product.
  Scalar dot(Vec4 b) => Scalar._(Node.dot(this._node, b._node));

  /// Scale by [s].
  Vec4 scale(Scalar s) => Vec4._(Node.scale(this._node, s._node));

  /// Truncate. Component-wise.
  Vec4 truncate() => Vec4._(Node.truncate(this._node));

  /// Absolute value. Component-wise.
  Vec4 abs() => Vec4._(Node.abs(this._node));

  /// Returns [1] for postive values and [-1] for negative values.
  /// Component-wise.
  Vec4 sign() => Vec4._(Node.sign(this._node));

  /// Strip decimals. Component-wise.
  Vec4 floor() => Vec4._(Node.floor(this._node));

  /// Round up. Component-wise.
  Vec4 ceil() => Vec4._(Node.ceil(this._node));

  /// Isolate the fractional (decimal) value. Component-wise.
  Vec4 fract() => Vec4._(Node.fract(this._node));

  /// Converts degrees to radians. Component-wise.
  Vec4 radians() => Vec4._(Node.radians(this._node));

  /// Converts radians to degrees. Component-wise.
  Vec4 degrees() => Vec4._(Node.degrees(this._node));

  /// Interprets value as theta and calculates the sine. Component-wise.
  Vec4 sin() => Vec4._(Node.sin(this._node));

  /// Interprets value as theta and calculates the cosine. Component-wise.
  Vec4 cos() => Vec4._(Node.cos(this._node));

  /// Interprets value as theta and calculates the tangent. Component-wise.
  Vec4 tan() => Vec4._(Node.tan(this._node));

  /// Inverse-sine. Component-wise.
  Vec4 asin() => Vec4._(Node.asin(this._node));

  /// Inverse-cosine. Component-wise.
  Vec4 acos() => Vec4._(Node.acos(this._node));

  /// Inverse-tangent. Component-wise.
  Vec4 atan() => Vec4._(Node.atan(this._node));

  /// Natural exponent, e raised to the power of this value. Component-wise.
  Vec4 exp() => Vec4._(Node.exp(this._node));

  /// Natural logarithm, base e. Component-wise.
  Vec4 log() => Vec4._(Node.log(this._node));

  /// 2 raised to the power of this value. Component-wise.
  Vec4 exp2() => Vec4._(Node.exp2(this._node));

  /// Base-2 logarithm. Component-wise.
  Vec4 log2() => Vec4._(Node.log2(this._node));

  /// Square root. Component-wise.
  Vec4 sqrt() => Vec4._(Node.sqrt(this._node));

  /// Inverse square root. [1 / sqrt(this._node)]. Component-wise.
  Vec4 isqrt() => Vec4._(Node.isqrt(this._node));

  /// Normalize the vector. Divide all components by vector length.
  Vec4 normalize() => Vec4._(Node.normalize(this._node));

  /// Step returns 0 if value is less than [edge], 1 otherwise. Component-wise.
  Vec4 step(Vec4 edge) => Vec4._(Node.step(edge._node, this._node));

  /// Clamp restricts the value to be between min and max. Component-wise.
  Vec4 clamp(Vec4 min, Vec4 max) =>
      Vec4._(Node.clamp(this._node, min._node, max._node));

  /// Mix linearly interpolates between [a] and [b] as this value ranges from 0
  /// to 1. Component-wise.
  Vec4 mix(Vec4 a, Vec4 b) => Vec4._(Node.mix(a._node, b._node, this._node));

  /// Performs smooth Hermite interpolation between 0 and 1 as this value ranges
  /// from [a] to [b]. Component-wise.
  Vec4 smoothStep(Vec4 a, Vec4 b) =>
      Vec4._(Node.smoothStep(a._node, b._node, this._node));

  /// Orients the vector to point away from a surface as defined by its normal.
  /// Returns the vector unchanged if `dot(reference, incident)` is below zero.
  /// Otherwise return the vector scaled by -1.
  Vec4 faceForward(Vec4 incident, Vec4 reference) =>
      Vec4._(Node.faceForward(this._node, incident._node, reference._node));

  /// Calculate the reflection direction for an incident vector.
  /// Returns `this - 2.0 * dot(normal, this) * normal`.
  Vec4 reflect(Vec4 normal) => Vec4._(Node.reflect(this._node, normal._node));

  vm.Vector4 evaluate() => vm.Vector4.array(_node.evaluate());
}
