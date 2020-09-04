part of '../expr.dart';

/// Vector [Expression] with three components.
class Vec3 extends Expression {
  Vec3._(Node child) : super._(child);

  /// Construct a constant Vec3 with value [x, y, z].
  Vec3(double x, double y, double z) : super._(Node.vec3(x, y, z));

  /// Construct a constant Vec3 with value [x, x, x].
  Vec3.all(double x) : super._(Node.vec3(x, x, x));

  /// Construct a Vec3 from existing Expressions. The total
  /// number of elements provided in [components] must be
  /// equal to 3.
  Vec3.of(List<Expression> components)
      : super._(Node.compositeVec3(components.map((c) => c._node).toList()));

  /// Return the inverse tangent of `x / y`. Component-wise.
  factory Vec3.aTan2(Vec3 x, Vec3 y) => Vec3._(Node.atan2(x._node, y._node));

  /// Return the minimum value between x and y. Component-wise.
  factory Vec3.min(Vec3 x, Vec3 y) => Vec3._(Node.min(x._node, y._node));

  /// Return the maximum value between x and y. Component-wise.
  factory Vec3.max(Vec3 x, Vec3 y) => Vec3._(Node.max(x._node, y._node));

  /// Returns the sum of this vector and [b].
  Vec3 operator +(Vec3 b) => Vec3._(Node.add(this._node, b._node));

  /// Returns the difference of this vector and [b].
  Vec3 operator -(Vec3 b) => Vec3._(Node.subtract(this._node, b._node));

  /// Equivalent to `this * Vec3.all(-1)`.
  Vec3 operator -() => Vec3._(Node.negate(this._node));

  /// Multiply by [b]. Component-wise.
  Vec3 operator *(Vec3 b) => Vec3._(Node.multiply(this._node, b._node));

  /// Divide by [b]. Component-wise.
  Vec3 operator /(Vec3 b) => Vec3._(Node.divide(this._node, b._node));

  /// Modulo by [b]. Component-wise.
  Vec3 operator %(Vec3 b) => Vec3._(Node.mod(this._node, b._node));

  /// Raise to the power of [b]. Component-wise.
  Vec3 operator ^(Vec3 b) => Vec3._(Node.pow(this._node, b._node));

  /// Length.
  Scalar length() => Scalar._(Node.length(this._node));

  /// Dot product.
  Scalar dot(Vec3 b) => Scalar._(Node.dot(this._node, b._node));

  /// Scale by [s].
  Vec3 scale(Scalar s) => Vec3._(Node.scale(this._node, s._node));

  /// Truncate. Component-wise.
  Vec3 truncate() => Vec3._(Node.truncate(this._node));

  /// Absolute value. Component-wise.
  Vec3 abs() => Vec3._(Node.abs(this._node));

  /// Returns [1] for postive values and [-1] for negative values.
  /// Component-wise.
  Vec3 sign() => Vec3._(Node.sign(this._node));

  /// Strip decimals. Component-wise.
  Vec3 floor() => Vec3._(Node.floor(this._node));

  /// Round up. Component-wise.
  Vec3 ceil() => Vec3._(Node.ceil(this._node));

  /// Isolate the fractional (decimal) value. Component-wise.
  Vec3 fract() => Vec3._(Node.fract(this._node));

  /// Converts degrees to radians. Component-wise.
  Vec3 radians() => Vec3._(Node.radians(this._node));

  /// Converts radians to degrees. Component-wise.
  Vec3 degrees() => Vec3._(Node.degrees(this._node));

  /// Interprets value as theta and calculates the sine. Component-wise.
  Vec3 sin() => Vec3._(Node.sin(this._node));

  /// Interprets value as theta and calculates the cosine. Component-wise.
  Vec3 cos() => Vec3._(Node.cos(this._node));

  /// Interprets value as theta and calculates the tangent. Component-wise.
  Vec3 tan() => Vec3._(Node.tan(this._node));

  /// Inverse-sine. Component-wise.
  Vec3 asin() => Vec3._(Node.asin(this._node));

  /// Inverse-cosine. Component-wise.
  Vec3 acos() => Vec3._(Node.acos(this._node));

  /// Inverse-tangent. Component-wise.
  Vec3 atan() => Vec3._(Node.atan(this._node));

  /// Natural exponent, e raised to the power of this value. Component-wise.
  Vec3 exp() => Vec3._(Node.exp(this._node));

  /// Natural logarithm, base e. Component-wise.
  Vec3 log() => Vec3._(Node.log(this._node));

  /// 2 raised to the power of this value. Component-wise.
  Vec3 exp2() => Vec3._(Node.exp2(this._node));

  /// Base-2 logarithm. Component-wise.
  Vec3 log2() => Vec3._(Node.log2(this._node));

  /// Square root. Component-wise.
  Vec3 sqrt() => Vec3._(Node.sqrt(this._node));

  /// Inverse square root. [1 / sqrt(this._node)]. Component-wise.
  Vec3 isqrt() => Vec3._(Node.isqrt(this._node));

  /// Normalize the vector. Divide all components by vector length.
  Vec3 normalize() => Vec3._(Node.normalize(this._node));

  /// Step returns 0 if value is less than [edge], 1 otherwise. Component-wise.
  Vec3 step(Vec3 edge) => Vec3._(Node.step(edge._node, this._node));

  /// Clamp restricts the value to be between min and max. Component-wise.
  Vec3 clamp(Vec3 min, Vec3 max) =>
      Vec3._(Node.clamp(this._node, min._node, max._node));

  /// Mix linearly interpolates between [a] and [b] as this value ranges from 0
  /// to 1. Component-wise.
  Vec3 mix(Vec3 a, Vec3 b) => Vec3._(Node.mix(a._node, b._node, this._node));

  /// Performs smooth Hermite interpolation between 0 and 1 as this value ranges
  /// from [a] to [b]. Component-wise.
  Vec3 smoothStep(Vec3 a, Vec3 b) =>
      Vec3._(Node.smoothStep(a._node, b._node, this._node));

  /// Orients the vector to point away from a surface as defined by its normal.
  /// Returns the vector unchanged if `dot(reference, incident)` is below zero.
  /// Otherwise return the vector scaled by -1.
  Vec3 faceForward(Vec3 incident, Vec3 reference) =>
      Vec3._(Node.faceForward(this._node, incident._node, reference._node));

  /// Calculate the reflection direction for an incident vector.
  /// Returns `this - 2.0 * dot(normal, this) * normal`.
  Vec3 reflect(Vec3 normal) => Vec3._(Node.reflect(this._node, normal._node));

  vm.Vector3 evaluate() => vm.Vector3.array(_node.evaluate());
}
