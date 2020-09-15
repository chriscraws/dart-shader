part of '../expr.dart';

// Both [Scalar] and [Vec2] implement this mixin.
mixin Vec2OrScalar on Expression {
  bool get _isVec2;
}

/// Vector [Expression] with two components.
class Vec2 extends Expression with Vec2OrScalar {
  const Vec2._(Evaluable child) : super._(child);

  /// Construct a constant Vec2 with value [x, y].
  Vec2(double x, double y) : super._(OpConstantComposite.vec2(x, y));

  /// Construct a constant Vec2 with value [x, x].
  Vec2.all(double x) : super._(OpConstantComposite.vec2(x, x));

  /// Construct from existing [Scalar] expressions.
  Vec2.of(Scalar x, Scalar y)
      : super._(OpCompositeConstruct.vec2([x._node, y._node]));

  /// Return the inverse tangent of `x / y`.
  static Vec2 aTan2(Vec2 x, Vec2 y) => Vec2._(ATan2(x._node, y._node));

  /// Return the minimum value between x and y.
  static Vec2 min(Vec2 x, Vec2 y) => Vec2._(FMin(x._node, y._node));

  /// Return the maximum value between x and y.
  static Vec2 max(Vec2 x, Vec2 y) => Vec2._(FMax(x._node, y._node));

  /// Returns the sum of this and [b].
  Vec2 operator +(Vec2 b) => Vec2._(OpFAdd(this._node, b._node));

  /// Returns the difference of this and [b].
  Vec2 operator -(Vec2 b) => Vec2._(OpFSub(this._node, b._node));

  /// Equivalent to `this * Vec2(-1)`.
  Vec2 operator -() => Vec2._(OpFNegate(this._node));

  /// Multiply by [b].
  Vec2 operator *(Vec2OrScalar b) {
    if (b._isVec2) {
      return Vec2._(OpFMul(this._node, b._node));
    } else {
      return Vec2._(OpVectorTimesScalar(this._node, b._node));
    }
  }

  /// Divide by [b].
  Vec2 operator /(Vec2OrScalar b) {
    if (b._isVec2) {
      return Vec2._(OpFDiv(this._node, b._node));
    } else {
      return Vec2._(
          OpVectorTimesScalar(this._node, OpFDiv(OpConstant(1), b._node)));
    }
  }

  /// Modulo by [b].
  Vec2 operator %(Vec2 b) => Vec2._(OpFMod(this._node, b._node));

  /// Raise to the power of [b].
  Vec2 operator ^(Vec2 b) => Vec2._(Pow(this._node, b._node));

  /// Length.
  Scalar length() => Scalar._(Length(this._node));

  /// Dot product.
  Scalar dot(Vec2 b) => Scalar._(OpFDot(this._node, b._node));

  /// Truncate.
  Vec2 truncate() => Vec2._(Trunc(this._node));

  /// Absolute value.
  Vec2 abs() => Vec2._(FAbs(this._node));

  /// Returns [1] for postive values and [-1] for negative values.
  Vec2 sign() => Vec2._(FSign(this._node));

  /// Strip decimals.
  Vec2 floor() => Vec2._(Floor(this._node));

  /// Round up.
  Vec2 ceil() => Vec2._(Ceil(this._node));

  /// Isolate the fractional (decimal) value.
  Vec2 fract() => Vec2._(Fract(this._node));

  /// Converts degrees to radians.
  Vec2 radians() => Vec2._(Radians(this._node));

  /// Converts radians to degrees.
  Vec2 degrees() => Vec2._(Degrees(this._node));

  /// Interprets value as theta and calculates the sine.
  Vec2 sin() => Vec2._(Sin(this._node));

  /// Interprets value as theta and calculates the cosine.
  Vec2 cos() => Vec2._(Cos(this._node));

  /// Interprets value as theta and calculates the tangent.
  Vec2 tan() => Vec2._(Tan(this._node));

  /// Inverse-sine.
  Vec2 asin() => Vec2._(ASin(this._node));

  /// Inverse-cosine.
  Vec2 acos() => Vec2._(ACos(this._node));

  /// Inverse-tangent.
  Vec2 atan() => Vec2._(ATan(this._node));

  /// Natural exponent, e raised to the power of this value.
  Vec2 exp() => Vec2._(Exp(this._node));

  /// Natural logarithm, base e.
  Vec2 log() => Vec2._(Log(this._node));

  /// 2 raised to the power of this._node value.
  Vec2 exp2() => Vec2._(Exp2(this._node));

  /// Base-2 logarithm.
  Vec2 log2() => Vec2._(Log2(this._node));

  /// Square root.
  Vec2 sqrt() => Vec2._(Sqrt(this._node));

  /// Inverse square root. [1 / sqrt(this._node)].
  Vec2 isqrt() => Vec2._(InverseSqrt(this._node));

  /// Step returns 0 if value is less than [edge], 1 otherwise.
  Vec2 step(Vec2 edge) => Vec2._(Step(edge._node, this._node));

  /// Clamp restricts the value to be between min and max.
  Vec2 clamp(Vec2 min, Vec2 max) =>
      Vec2._(FClamp(this._node, min._node, max._node));

  /// Mix linearly interpolates between [a] and [b] as this value ranges from 0
  /// to 1.
  Vec2 mix(Vec2 a, Vec2 b) => Vec2._(FMix(a._node, b._node, this._node));

  /// Performs smooth Hermite interpolation between 0 and 1 as this value ranges
  /// from [a] to [b].
  Vec2 smoothStep(Vec2 a, Vec2 b) =>
      Vec2._(SmoothStep(a._node, b._node, this._node));

  /// Orients the vector to point away from a surface as defined by its normal.
  /// Returns the vector unchanged if `dot(reference, incident)` is below zero.
  /// Otherwise return the vector scaled by -1.
  Vec2 faceForward(Vec2 incident, Vec2 reference) =>
      Vec2._(FaceForward(this._node, incident._node, reference._node));

  /// Calculate the reflection direction for an incident vector.
  /// Returns `this - 2.0 * dot(normal, this) * normal`.
  Vec2 reflect(Vec2 normal) => Vec2._(Reflect(this._node, normal._node));

  vm.Vector2 evaluate() => vm.Vector2.array(_node.evaluate());

  bool get _isVec2 => true;

  Scalar get x => Scalar._(OpCompositeExtract.vec(this._node, 0));
  Scalar get y => Scalar._(OpCompositeExtract.vec(this._node, 1));

  Scalar get r => x;
  Scalar get g => y;
}
