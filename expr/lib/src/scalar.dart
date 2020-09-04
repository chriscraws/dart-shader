part of '../expr.dart';

class Scalar extends Expression {
  Scalar._(Expression child) : super.from(child);

  Scalar(double x) : super.scalar(x);

  Scalar operator +(Scalar b) => Scalar._(Expression.add(this, b));
  Scalar operator -(Scalar b) => Scalar._(Expression.subtract(this, b));
  Scalar operator -() => Scalar._(Expression.negate(this));
  Scalar operator *(Scalar b) => Scalar._(Expression.multiply(this, b));
  Scalar operator /(Scalar b) => Scalar._(Expression.divide(this, b));
  Scalar operator %(Scalar b) => Scalar._(Expression.mod(this, b));
  Scalar operator ^(Scalar b) => Scalar._(Expression.pow(this, b));

  /// Return the inverse tangent of `x / y`.
  factory Scalar.aTan2(Scalar x, Scalar y) => Scalar._(Expression.atan2(x, y));

  /// Return the minimum value between x and y.
  factory Scalar.min(Scalar x, Scalar y) => Scalar._(Expression.min(x, y));

  /// Return the maximum value between x and y.
  factory Scalar.max(Scalar x, Scalar y) => Scalar._(Expression.max(x, y));

  /// Truncate.
  Scalar truncate() => Scalar._(Expression.truncate(this));

  /// Absolute value.
  Scalar abs() => Scalar._(Expression.abs(this));

  /// Returns [1] for postive values and [-1] for negative values.
  ///
  Scalar sign() => Scalar._(Expression.sign(this));

  /// Strip decimals.
  Scalar floor() => Scalar._(Expression.floor(this));

  /// Round up.
  Scalar ceil() => Scalar._(Expression.ceil(this));

  /// Isolate the fractional (decimal) value.
  Scalar fract() => Scalar._(Expression.fract(this));

  /// Converts degrees to radians.
  Scalar radians() => Scalar._(Expression.radians(this));

  /// Converts radians to degrees.
  Scalar degrees() => Scalar._(Expression.degrees(this));

  /// Interprets value as theta and calculates the sine.
  Scalar sin() => Scalar._(Expression.sin(this));

  /// Interprets value as theta and calculates the cosine.
  Scalar cos() => Scalar._(Expression.cos(this));

  /// Interprets value as theta and calculates the tangent.
  Scalar tan() => Scalar._(Expression.tan(this));

  /// Inverse-sine.
  Scalar asin() => Scalar._(Expression.asin(this));

  /// Inverse-cosine.
  Scalar acos() => Scalar._(Expression.acos(this));

  /// Inverse-tangent.
  Scalar atan() => Scalar._(Expression.atan(this));

  /// Natural exponent, e raised to the power of this value.
  Scalar exp() => Scalar._(Expression.exp(this));

  /// Natural logarithm, base e.
  Scalar log() => Scalar._(Expression.log(this));

  /// 2 raised to the power of this value.
  Scalar exp2() => Scalar._(Expression.exp2(this));

  /// Base-2 logarithm.
  Scalar log2() => Scalar._(Expression.log2(this));

  /// Square root.
  Scalar sqrt() => Scalar._(Expression.sqrt(this));

  /// Inverse square root. [1 / sqrt(this)].
  Scalar isqrt() => Scalar._(Expression.isqrt(this));

  /// Step returns 0 if value is less than [edge], 1 otherwise.
  Scalar step(Scalar edge) => Scalar._(Expression.step(edge, this));

  /// Clamp restricts the value to be between min and max.
  Scalar clamp(Scalar min, Scalar max) =>
      Scalar._(Expression.clamp(this, min, max));

  /// Mix linearly interpolates between [a] and [b] as this value ranges from 0
  /// to 1.
  Scalar mix(Scalar a, Scalar b) => Scalar._(Expression.mix(a, b, this));

  /// Performs smooth Hermite interpolation between 0 and 1 as this value ranges
  /// from [a] to [b].
  Scalar smoothStep(Scalar a, Scalar b) =>
      Scalar._(Expression.smoothStep(a, b, this));

  double evaluate() => _evaluate()[0];
}
