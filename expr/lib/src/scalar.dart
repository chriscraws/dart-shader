part of '../expr.dart';

/// Floating-point [Expression].
class Scalar extends Expression {
  Scalar._(Node child) : super._(child);

  /// Constructs a constant Scalar with value [x].
  Scalar(double x) : super._(Node.scalar(x));

  /// Return the inverse tangent of `x / y`.
  factory Scalar.aTan2(Scalar x, Scalar y) =>
      Scalar._(Node.atan2(x._node, y._node));

  /// Return the minimum value between x and y.
  factory Scalar.min(Scalar x, Scalar y) =>
      Scalar._(Node.min(x._node, y._node));

  /// Return the maximum value between x and y.
  factory Scalar.max(Scalar x, Scalar y) =>
      Scalar._(Node.max(x._node, y._node));

  /// Returns the sum of this and [b].
  Scalar operator +(Scalar b) => Scalar._(Node.add(this._node, b._node));

  /// Returns the difference of this and [b].
  Scalar operator -(Scalar b) => Scalar._(Node.subtract(this._node, b._node));

  /// Equivalent to `this * Scalar(-1)`.
  Scalar operator -() => Scalar._(Node.negate(this._node));

  /// Multiply by [b].
  Scalar operator *(Scalar b) => Scalar._(Node.multiply(this._node, b._node));

  /// Divide by [b].
  Scalar operator /(Scalar b) => Scalar._(Node.divide(this._node, b._node));

  /// Modulo by [b].
  Scalar operator %(Scalar b) => Scalar._(Node.mod(this._node, b._node));

  /// Raise to the power of [b].
  Scalar operator ^(Scalar b) => Scalar._(Node.pow(this._node, b._node));

  /// Truncate.
  Scalar truncate() => Scalar._(Node.truncate(this._node));

  /// Absolute value.
  Scalar abs() => Scalar._(Node.abs(this._node));

  /// Returns [1] for postive values and [-1] for negative values.
  ///
  Scalar sign() => Scalar._(Node.sign(this._node));

  /// Strip decimals.
  Scalar floor() => Scalar._(Node.floor(this._node));

  /// Round up.
  Scalar ceil() => Scalar._(Node.ceil(this._node));

  /// Isolate the fractional (decimal) value.
  Scalar fract() => Scalar._(Node.fract(this._node));

  /// Converts degrees to radians.
  Scalar radians() => Scalar._(Node.radians(this._node));

  /// Converts radians to degrees.
  Scalar degrees() => Scalar._(Node.degrees(this._node));

  /// Interprets value as theta and calculates the sine.
  Scalar sin() => Scalar._(Node.sin(this._node));

  /// Interprets value as theta and calculates the cosine.
  Scalar cos() => Scalar._(Node.cos(this._node));

  /// Interprets value as theta and calculates the tangent.
  Scalar tan() => Scalar._(Node.tan(this._node));

  /// Inverse-sine.
  Scalar asin() => Scalar._(Node.asin(this._node));

  /// Inverse-cosine.
  Scalar acos() => Scalar._(Node.acos(this._node));

  /// Inverse-tangent.
  Scalar atan() => Scalar._(Node.atan(this._node));

  /// Natural exponent, e raised to the power of this value.
  Scalar exp() => Scalar._(Node.exp(this._node));

  /// Natural logarithm, base e.
  Scalar log() => Scalar._(Node.log(this._node));

  /// 2 raised to the power of this._node value.
  Scalar exp2() => Scalar._(Node.exp2(this._node));

  /// Base-2 logarithm.
  Scalar log2() => Scalar._(Node.log2(this._node));

  /// Square root.
  Scalar sqrt() => Scalar._(Node.sqrt(this._node));

  /// Inverse square root. [1 / sqrt(this._node)].
  Scalar isqrt() => Scalar._(Node.isqrt(this._node));

  /// Step returns 0 if value is less than [edge], 1 otherwise.
  Scalar step(Scalar edge) => Scalar._(Node.step(edge._node, this._node));

  /// Clamp restricts the value to be between min and max.
  Scalar clamp(Scalar min, Scalar max) =>
      Scalar._(Node.clamp(this._node, min._node, max._node));

  /// Mix linearly interpolates between [a] and [b] as this value ranges from 0
  /// to 1.
  Scalar mix(Scalar a, Scalar b) =>
      Scalar._(Node.mix(a._node, b._node, this._node));

  /// Performs smooth Hermite interpolation between 0 and 1 as this value ranges
  /// from [a] to [b].
  Scalar smoothStep(Scalar a, Scalar b) =>
      Scalar._(Node.smoothStep(a._node, b._node, this._node));

  double evaluate() => _node.evaluate()[0];
}
