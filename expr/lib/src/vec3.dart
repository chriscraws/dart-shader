part of '../expr.dart';

class Vec3 extends Expression {
  Vec3._(Expression child) : super.from(child);

  Vec3(double x, double y, double z) : super.vec3(x, y, z);

  Vec3.of(List<Expression> components)
      : super.composite(components, spirv.vec3T);

  Vec3 operator +(Vec3 b) => Vec3._(Expression.add(this, b));
  Vec3 operator -(Vec3 b) => Vec3._(Expression.subtract(this, b));
  Vec3 operator -() => Vec3._(Expression.negate(this));
  Vec3 operator *(Vec3 b) => Vec3._(Expression.multiply(this, b));
  Vec3 operator /(Vec3 b) => Vec3._(Expression.divide(this, b));
  Vec3 operator %(Vec3 b) => Vec3._(Expression.mod(this, b));
  Vec3 operator ^(Vec3 b) => Vec3._(Expression.pow(this, b));

  /// Return the inverse tangent of `x / y`. Component-wise.
  factory Vec3.aTan2(Vec3 x, Vec3 y) => Vec3._(Expression.atan2(x, y));

  /// Return the minimum value between x and y. Component-wise.
  factory Vec3.min(Vec3 x, Vec3 y) => Vec3._(Expression.min(x, y));

  /// Return the maximum value between x and y. Component-wise.
  factory Vec3.max(Vec3 x, Vec3 y) => Vec3._(Expression.max(x, y));

  /// Length.
  Scalar length() => Scalar._(Expression.length(this));

  /// Dot product.
  Scalar dot(Vec3 b) => Scalar._(Expression.dot(this, b));

  /// Scale by [s].
  Vec3 scale(Scalar s) => Vec3._(Expression.scale(this, s));

  /// Truncate. Component-wise.
  Vec3 truncate() => Vec3._(Expression.truncate(this));

  /// Absolute value. Component-wise.
  Vec3 abs() => Vec3._(Expression.abs(this));

  /// Returns [1] for postive values and [-1] for negative values.
  /// Component-wise.
  Vec3 sign() => Vec3._(Expression.sign(this));

  /// Strip decimals. Component-wise.
  Vec3 floor() => Vec3._(Expression.floor(this));

  /// Round up. Component-wise.
  Vec3 ceil() => Vec3._(Expression.ceil(this));

  /// Isolate the fractional (decimal) value. Component-wise.
  Vec3 fract() => Vec3._(Expression.fract(this));

  /// Converts degrees to radians. Component-wise.
  Vec3 radians() => Vec3._(Expression.radians(this));

  /// Converts radians to degrees. Component-wise.
  Vec3 degrees() => Vec3._(Expression.degrees(this));

  /// Interprets value as theta and calculates the sine. Component-wise.
  Vec3 sin() => Vec3._(Expression.sin(this));

  /// Interprets value as theta and calculates the cosine. Component-wise.
  Vec3 cos() => Vec3._(Expression.cos(this));

  /// Interprets value as theta and calculates the tangent. Component-wise.
  Vec3 tan() => Vec3._(Expression.tan(this));

  /// Inverse-sine. Component-wise.
  Vec3 asin() => Vec3._(Expression.asin(this));

  /// Inverse-cosine. Component-wise.
  Vec3 acos() => Vec3._(Expression.acos(this));

  /// Inverse-tangent. Component-wise.
  Vec3 atan() => Vec3._(Expression.atan(this));

  /// Natural exponent, e raised to the power of this value. Component-wise.
  Vec3 exp() => Vec3._(Expression.exp(this));

  /// Natural logarithm, base e. Component-wise.
  Vec3 log() => Vec3._(Expression.log(this));

  /// 2 raised to the power of this value. Component-wise.
  Vec3 exp2() => Vec3._(Expression.exp2(this));

  /// Base-2 logarithm. Component-wise.
  Vec3 log2() => Vec3._(Expression.log2(this));

  /// Square root. Component-wise.
  Vec3 sqrt() => Vec3._(Expression.sqrt(this));

  /// Inverse square root. [1 / sqrt(this)]. Component-wise.
  Vec3 isqrt() => Vec3._(Expression.isqrt(this));

  /// Normalize the vector. Divide all components by vector length.
  Vec3 normalize() => Vec3._(Expression.normalize(this));

  /// Step returns 0 if value is less than [edge], 1 otherwise. Component-wise.
  Vec3 step(Vec3 edge) => Vec3._(Expression.step(edge, this));

  /// Clamp restricts the value to be between min and max. Component-wise.
  Vec3 clamp(Vec3 min, Vec3 max) => Vec3._(Expression.clamp(this, min, max));

  /// Mix linearly interpolates between [a] and [b] as this value ranges from 0
  /// to 1. Component-wise.
  Vec3 mix(Vec3 a, Vec3 b) => Vec3._(Expression.mix(a, b, this));

  /// Performs smooth Hermite interpolation between 0 and 1 as this value ranges
  /// from [a] to [b]. Component-wise.
  Vec3 smoothStep(Vec3 a, Vec3 b) => Vec3._(Expression.smoothStep(a, b, this));

  /// Orients the vector to point away from a surface as defined by its normal.
  /// Returns the vector unchanged if `dot(reference, incident)` is below zero.
  /// Otherwise return the vector scaled by -1.
  Vec3 faceForward(Vec3 incident, Vec3 reference) =>
      Vec3._(Expression.faceForward(this, incident, reference));

  /// Calculate the reflection direction for an incident vector.
  /// Returns [this - 2.0 * dot(normal, this) * normal].
  Vec3 reflect(Vec3 normal) => Vec3._(Expression.reflect(this, normal));

  vm.Vector3 evaluate() => vm.Vector3.array(_evaluate());
}
