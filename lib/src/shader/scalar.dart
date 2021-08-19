part of '../../shader.dart';

/// Floating-point [Expression].
class Scalar extends Expression with Vec2OrScalar, Vec3OrScalar, Vec4OrScalar {
  Scalar._(Evaluable child) : super._(child);

  Scalar _construct(Evaluable node) {
    return Scalar._(node);
  }

  /// Constructs a constant Scalar with value [x].
  Scalar(double x) : super._(OpConstant(x));

  /// Construct a Vec2 with all members set to this value.
  Vec2 vec2() => Vec2(this, this);

  /// Alias for [vec2]
  Vec2 get v2 => vec2();

  /// Construct a Vec3 with all members set to this value.
  Vec3 vec3() => Vec3(this, this, this);

  /// Alias for [vec3]
  Vec3 get v3 => vec3();

  /// Construct a Vec4 with all members set to this value.
  Vec4 vec4() => Vec4(this, this, this, this);

  /// Alias for [vec4];
  Vec4 get v4 => vec4();

  /// Return the inverse tangent of `x / y`.
  static Scalar aTan2(Scalar x, Scalar y) => Scalar._(ATan2(x._node, y._node));

  /// Return the minimum value between x and y.
  static Scalar min(Scalar x, Scalar y) => Scalar._(FMin(x._node, y._node));

  /// Return the maximum value between x and y.
  static Scalar max(Scalar x, Scalar y) => Scalar._(FMax(x._node, y._node));

  /// Returns the sum of this and [b].
  Scalar operator +(Scalar b) => Scalar._(OpFAdd(this._node, b._node));

  /// Returns the difference of this and [b].
  Scalar operator -(Scalar b) => Scalar._(OpFSub(this._node, b._node));

  /// Equivalent to `this * Scalar(-1)`.
  Scalar operator -() => Scalar._(OpFNegate(this._node));

  /// Multiply by [b].
  Scalar operator *(Scalar b) => Scalar._(OpFMul(this._node, b._node));

  /// Divide by [b].
  Scalar operator /(Scalar b) => Scalar._(OpFDiv(this._node, b._node));

  /// Modulo by [b].
  Scalar operator %(Scalar b) => Scalar._(OpFMod(this._node, b._node));

  /// Raise to the power of [b].
  Scalar operator ^(Scalar b) => Scalar._(Pow(this._node, b._node));

  /// Truncate.
  Scalar truncate() => Scalar._(Trunc(this._node));

  /// Absolute value.
  Scalar abs() => Scalar._(FAbs(this._node));

  /// Returns [1] for postive values and [-1] for negative values.
  Scalar sign() => Scalar._(FSign(this._node));

  /// Strip decimals.
  Scalar floor() => Scalar._(Floor(this._node));

  /// Round up.
  Scalar ceil() => Scalar._(Ceil(this._node));

  /// Isolate the fractional (decimal) value.
  Scalar fract() => Scalar._(Fract(this._node));

  /// Converts degrees to radians.
  Scalar radians() => Scalar._(Radians(this._node));

  /// Converts radians to degrees.
  Scalar degrees() => Scalar._(Degrees(this._node));

  /// Interprets value as theta and calculates the sine.
  Scalar sin() => Scalar._(Sin(this._node));

  /// Interprets value as theta and calculates the cosine.
  Scalar cos() => Scalar._(Cos(this._node));

  /// Interprets value as theta and calculates the tangent.
  Scalar tan() => Scalar._(Tan(this._node));

  /// Inverse-sine.
  Scalar asin() => Scalar._(ASin(this._node));

  /// Inverse-cosine.
  Scalar acos() => Scalar._(ACos(this._node));

  /// Inverse-tangent.
  Scalar atan() => Scalar._(ATan(this._node));

  /// Natural exponent, e raised to the power of this value.
  Scalar exp() => Scalar._(Exp(this._node));

  /// Natural logarithm, base e.
  Scalar log() => Scalar._(Log(this._node));

  /// 2 raised to the power of this._node value.
  Scalar exp2() => Scalar._(Exp2(this._node));

  /// Base-2 logarithm.
  Scalar log2() => Scalar._(Log2(this._node));

  /// Square root.
  Scalar sqrt() => Scalar._(Sqrt(this._node));

  /// Inverse square root. [1 / sqrt(this._node)].
  Scalar isqrt() => Scalar._(InverseSqrt(this._node));

  /// Step returns 0 if value is less than [edge], 1 otherwise.
  Scalar step(Scalar edge) => Scalar._(Step(edge._node, this._node));

  /// Clamp restricts the value to be between min and max.
  Scalar clamp(Scalar min, Scalar max) =>
      Scalar._(FClamp(this._node, min._node, max._node));

  /// Mix linearly interpolates between [a] and [b] as this value ranges from 0
  /// to 1.
  T mix<T extends Expression>(T a, T b) =>
      a._construct(FMix(a._node, b._node, this._node));

  /// Performs smooth Hermite interpolation between 0 and 1 as this value ranges
  /// from [a] to [b].
  T smoothStep<T extends Expression>(T a, T b) =>
      a._construct(SmoothStep(a._node, b._node, this._node));

  double evaluate() {
    _node.evaluate();
    return _node.value[0];
  }

  bool get _isVec4 => false;
  bool get _isVec3 => false;
  bool get _isVec2 => false;
}
