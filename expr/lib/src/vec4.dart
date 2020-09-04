part of '../expr.dart';

class Vec4 extends Expression {
  Vec4._(Expression child) : super.from(child);

  Vec4(double x, double y, double z, double w) : super.vec4(x, y, z, w);

  Vec4.of(List<Expression> components)
      : super.composite(components, spirv.vec4T);

  Vec4 operator +(Vec4 b) => Vec4._(Expression.add(this, b));
  Vec4 operator -(Vec4 b) => Vec4._(Expression.subtract(this, b));
  Vec4 operator -() => Vec4._(Expression.negate(this));
  Vec4 operator *(Vec4 b) => Vec4._(Expression.multiply(this, b));
  Vec4 operator /(Vec4 b) => Vec4._(Expression.divide(this, b));
  Vec4 operator %(Vec4 b) => Vec4._(Expression.mod(this, b));
  Vec4 operator ^(Vec4 b) => Vec4._(Expression.pow(this, b));

  /// Return the inverse tangent of `x / y`. Component-wise.
  factory Vec4.aTan2(Vec4 x, Vec4 y) => Vec4._(Expression.atan2(x, y));

  /// Return the minimum value between x and y. Component-wise.
  factory Vec4.min(Vec4 x, Vec4 y) => Vec4._(Expression.min(x, y));

  /// Return the maximum value between x and y. Component-wise.
  factory Vec4.max(Vec4 x, Vec4 y) => Vec4._(Expression.max(x, y));

  /// Length.
  Scalar length() => Scalar._(Expression.length(this));

  /// Dot product.
  Scalar dot(Vec4 b) => Scalar._(Expression.dot(this, b));

  /// Scale by [s].
  Vec4 scale(Scalar s) => Vec4._(Expression.scale(this, s));

  /// Truncate. Component-wise.
  Vec4 truncate() => Vec4._(Expression.truncate(this));

  /// Absolute value. Component-wise.
  Vec4 abs() => Vec4._(Expression.abs(this));

  /// Returns [1] for postive values and [-1] for negative values.
  /// Component-wise.
  Vec4 sign() => Vec4._(Expression.sign(this));

  /// Strip decimals. Component-wise.
  Vec4 floor() => Vec4._(Expression.floor(this));

  /// Round up. Component-wise.
  Vec4 ceil() => Vec4._(Expression.ceil(this));

  /// Isolate the fractional (decimal) value. Component-wise.
  Vec4 fract() => Vec4._(Expression.fract(this));

  /// Converts degrees to radians. Component-wise.
  Vec4 radians() => Vec4._(Expression.radians(this));

  /// Converts radians to degrees. Component-wise.
  Vec4 degrees() => Vec4._(Expression.degrees(this));

  /// Interprets value as theta and calculates the sine. Component-wise.
  Vec4 sin() => Vec4._(Expression.sin(this));

  /// Interprets value as theta and calculates the cosine. Component-wise.
  Vec4 cos() => Vec4._(Expression.cos(this));

  /// Interprets value as theta and calculates the tangent. Component-wise.
  Vec4 tan() => Vec4._(Expression.tan(this));

  /// Inverse-sine. Component-wise.
  Vec4 asin() => Vec4._(Expression.asin(this));

  /// Inverse-cosine. Component-wise.
  Vec4 acos() => Vec4._(Expression.acos(this));

  /// Inverse-tangent. Component-wise.
  Vec4 atan() => Vec4._(Expression.atan(this));

  /// Natural exponent, e raised to the power of this value. Component-wise.
  Vec4 exp() => Vec4._(Expression.exp(this));

  /// Natural logarithm, base e. Component-wise.
  Vec4 log() => Vec4._(Expression.log(this));

  /// 2 raised to the power of this value. Component-wise.
  Vec4 exp2() => Vec4._(Expression.exp2(this));

  /// Base-2 logarithm. Component-wise.
  Vec4 log2() => Vec4._(Expression.log2(this));

  /// Square root. Component-wise.
  Vec4 sqrt() => Vec4._(Expression.sqrt(this));

  /// Inverse square root. [1 / sqrt(this)]. Component-wise.
  Vec4 isqrt() => Vec4._(Expression.isqrt(this));

  /// Normalize the vector. Divide all components by vector length.
  Vec4 normalize() => Vec4._(Expression.normalize(this));

  /// Step returns 0 if value is less than [edge], 1 otherwise. Component-wise.
  Vec4 step(Vec4 edge) => Vec4._(Expression.step(edge, this));

  /// Clamp restricts the value to be between min and max. Component-wise.
  Vec4 clamp(Vec4 min, Vec4 max) => Vec4._(Expression.clamp(this, min, max));

  /// Mix linearly interpolates between [a] and [b] as this value ranges from 0
  /// to 1. Component-wise.
  Vec4 mix(Vec4 a, Vec4 b) => Vec4._(Expression.mix(a, b, this));

  /// Performs smooth Hermite interpolation between 0 and 1 as this value ranges
  /// from [a] to [b]. Component-wise.
  Vec4 smoothStep(Vec4 a, Vec4 b) => Vec4._(Expression.smoothStep(a, b, this));

  /// Orients the vector to point away from a surface as defined by its normal.
  /// Returns the vector unchanged if `dot(reference, incident)` is below zero.
  /// Otherwise return the vector scaled by -1.
  Vec4 faceForward(Vec4 incident, Vec4 reference) =>
      Vec4._(Expression.faceForward(this, incident, reference));

  /// Calculate the reflection direction for an incident vector.
  /// Returns [this - 2.0 * dot(normal, this) * normal].
  Vec4 reflect(Vec4 normal) => Vec4._(Expression.reflect(this, normal));

  vm.Vector4 evaluate() => vm.Vector4.array(_evaluate());
}
