part of '../expr.dart';

class Vec2 extends Expression {
  Vec2._(Expression child) : super.from(child);

  Vec2(double x, double y) : super.vec2(x, y);

  Vec2.of(List<Expression> components)
      : super.composite(components, spirv.vec2T);

  Vec2 operator +(Vec2 b) => Vec2._(Expression.add(this, b));
  Vec2 operator -(Vec2 b) => Vec2._(Expression.subtract(this, b));
  Vec2 operator -() => Vec2._(Expression.negate(this));
  Vec2 operator *(Vec2 b) => Vec2._(Expression.multiply(this, b));
  Vec2 operator /(Vec2 b) => Vec2._(Expression.divide(this, b));
  Vec2 operator %(Vec2 b) => Vec2._(Expression.mod(this, b));
  Vec2 operator ^(Vec2 b) => Vec2._(Expression.pow(this, b));

  /// Return the inverse tangent of `x / y`. Component-wise.
  factory Vec2.aTan2(Vec2 x, Vec2 y) => Vec2._(Expression.atan2(x, y));

  /// Return the minimum value between x and y. Component-wise.
  factory Vec2.min(Vec2 x, Vec2 y) => Vec2._(Expression.min(x, y));

  /// Return the maximum value between x and y. Component-wise.
  factory Vec2.max(Vec2 x, Vec2 y) => Vec2._(Expression.max(x, y));

  /// Length.
  Scalar length() => Scalar._(Expression.length(this));

  /// Dot product.
  Scalar dot(Vec2 b) => Scalar._(Expression.dot(this, b));

  /// Scale by [s].
  Vec2 scale(Scalar s) => Vec2._(Expression.scale(this, s));

  /// Truncate. Component-wise.
  Vec2 truncate() => Vec2._(Expression.truncate(this));

  /// Absolute value. Component-wise.
  Vec2 abs() => Vec2._(Expression.abs(this));

  /// Returns [1] for postive values and [-1] for negative values.
  /// Component-wise.
  Vec2 sign() => Vec2._(Expression.sign(this));

  /// Strip decimals. Component-wise.
  Vec2 floor() => Vec2._(Expression.floor(this));

  /// Round up. Component-wise.
  Vec2 ceil() => Vec2._(Expression.ceil(this));

  /// Isolate the fractional (decimal) value. Component-wise.
  Vec2 fract() => Vec2._(Expression.fract(this));

  /// Converts degrees to radians. Component-wise.
  Vec2 radians() => Vec2._(Expression.radians(this));

  /// Converts radians to degrees. Component-wise.
  Vec2 degrees() => Vec2._(Expression.degrees(this));

  /// Interprets value as theta and calculates the sine. Component-wise.
  Vec2 sin() => Vec2._(Expression.sin(this));

  /// Interprets value as theta and calculates the cosine. Component-wise.
  Vec2 cos() => Vec2._(Expression.cos(this));

  /// Interprets value as theta and calculates the tangent. Component-wise.
  Vec2 tan() => Vec2._(Expression.tan(this));

  /// Inverse-sine. Component-wise.
  Vec2 asin() => Vec2._(Expression.asin(this));

  /// Inverse-cosine. Component-wise.
  Vec2 acos() => Vec2._(Expression.acos(this));

  /// Inverse-tangent. Component-wise.
  Vec2 atan() => Vec2._(Expression.atan(this));

  /// Natural exponent, e raised to the power of this value. Component-wise.
  Vec2 exp() => Vec2._(Expression.exp(this));

  /// Natural logarithm, base e. Component-wise.
  Vec2 log() => Vec2._(Expression.log(this));

  /// 2 raised to the power of this value. Component-wise.
  Vec2 exp2() => Vec2._(Expression.exp2(this));

  /// Base-2 logarithm. Component-wise.
  Vec2 log2() => Vec2._(Expression.log2(this));

  /// Square root. Component-wise.
  Vec2 sqrt() => Vec2._(Expression.sqrt(this));

  /// Inverse square root. [1 / sqrt(this)]. Component-wise.
  Vec2 isqrt() => Vec2._(Expression.isqrt(this));

  /// Normalize the vector. Divide all components by vector length.
  Vec2 normalize() => Vec2._(Expression.normalize(this));

  /// Step returns 0 if value is less than [edge], 1 otherwise. Component-wise.
  Vec2 step(Vec2 edge) => Vec2._(Expression.step(edge, this));

  /// Clamp restricts the value to be between min and max. Component-wise.
  Vec2 clamp(Vec2 min, Vec2 max) => Vec2._(Expression.clamp(this, min, max));

  /// Mix linearly interpolates between [a] and [b] as this value ranges from 0
  /// to 1. Component-wise.
  Vec2 mix(Vec2 a, Vec2 b) => Vec2._(Expression.mix(a, b, this));

  /// Performs smooth Hermite interpolation between 0 and 1 as this value ranges
  /// from [a] to [b]. Component-wise.
  Vec2 smoothStep(Vec2 a, Vec2 b) => Vec2._(Expression.smoothStep(a, b, this));

  /// Orients the vector to point away from a surface as defined by its normal.
  /// Returns the vector unchanged if `dot(reference, incident)` is below zero.
  /// Otherwise return the vector scaled by -1.
  Vec2 faceForward(Vec2 incident, Vec2 reference) =>
      Vec2._(Expression.faceForward(this, incident, reference));

  /// Calculate the reflection direction for an incident vector.
  /// Returns [this - 2.0 * dot(normal, this) * normal].
  Vec2 reflect(Vec2 normal) => Vec2._(Expression.reflect(this, normal));

  vm.Vector2 evaluate() => vm.Vector2.array(_evaluate());
}
