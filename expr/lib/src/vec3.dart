part of '../expr.dart';

/// Vector [Expression] with three components.
class Vec3 extends Expression {
  Vec3._(Evaluable child) : super._(child);

  /// Construct a constant Vec3 with value [x, y].
  Vec3(double x, double y, double z)
      : super._(OpConstantComposite.vec3(x, y, z));

  /// Construct a constant Vec3 with value [x, x].
  Vec3.all(double x) : super._(OpConstantComposite.vec3(x, x, x));

  /// Construct Vec4 from existing expressions. The total number
  /// of elements in the expressions in [components] must be 4.
  Vec3.of(List<Expression> components)
      : super._(
            OpCompositeConstruct.vec3(components.map((c) => c._node).toList()));

  /// Return the inverse tangent of `x / y`.
  static Vec3 aTan2(Vec3 x, Vec3 y) => Vec3._(ATan2(x._node, y._node));

  /// Return the minimum value between x and y.
  static Vec3 min(Vec3 x, Vec3 y) => Vec3._(FMin(x._node, y._node));

  /// Return the maximum value between x and y.
  static Vec3 max(Vec3 x, Vec3 y) => Vec3._(FMax(x._node, y._node));

  /// Returns the sum of this and [b].
  Vec3 operator +(Vec3 b) => Vec3._(OpFAdd(this._node, b._node));

  /// Returns the difference of this and [b].
  Vec3 operator -(Vec3 b) => Vec3._(OpFSub(this._node, b._node));

  /// Equivalent to `this * Vec3(-1)`.
  Vec3 operator -() => Vec3._(OpFNegate(this._node));

  /// Multiply by [b].
  Vec3 operator *(Vec3 b) => Vec3._(OpFMul(this._node, b._node));

  /// Divide by [b].
  Vec3 operator /(Vec3 b) => Vec3._(OpFDiv(this._node, b._node));

  /// Modulo by [b].
  Vec3 operator %(Vec3 b) => Vec3._(OpFMod(this._node, b._node));

  /// Raise to the power of [b].
  Vec3 operator ^(Vec3 b) => Vec3._(Pow(this._node, b._node));

  /// Return a new [Vec3] scaled by a [Scalar] value.
  Vec3 scale(Scalar s) => Vec3._(OpVectorTimesScalar(this._node, s._node));

  /// Length.
  Scalar length() => Scalar._(Length(this._node));

  /// Dot product.
  Scalar dot(Vec3 b) => Scalar._(OpFDot(this._node, b._node));

  /// Truncate.
  Vec3 truncate() => Vec3._(Trunc(this._node));

  /// Absolute value.
  Vec3 abs() => Vec3._(FAbs(this._node));

  /// Returns [1] for postive values and [-1] for negative values.
  Vec3 sign() => Vec3._(FSign(this._node));

  /// Strip decimals.
  Vec3 floor() => Vec3._(Floor(this._node));

  /// Round up.
  Vec3 ceil() => Vec3._(Ceil(this._node));

  /// Isolate the fractional (decimal) value.
  Vec3 fract() => Vec3._(Fract(this._node));

  /// Converts degrees to radians.
  Vec3 radians() => Vec3._(Radians(this._node));

  /// Converts radians to degrees.
  Vec3 degrees() => Vec3._(Degrees(this._node));

  /// Interprets value as theta and calculates the sine.
  Vec3 sin() => Vec3._(Sin(this._node));

  /// Interprets value as theta and calculates the cosine.
  Vec3 cos() => Vec3._(Cos(this._node));

  /// Interprets value as theta and calculates the tangent.
  Vec3 tan() => Vec3._(Tan(this._node));

  /// Inverse-sine.
  Vec3 asin() => Vec3._(ASin(this._node));

  /// Inverse-cosine.
  Vec3 acos() => Vec3._(ACos(this._node));

  /// Inverse-tangent.
  Vec3 atan() => Vec3._(ATan(this._node));

  /// Natural exponent, e raised to the power of this value.
  Vec3 exp() => Vec3._(Exp(this._node));

  /// Natural logarithm, base e.
  Vec3 log() => Vec3._(Log(this._node));

  /// 2 raised to the power of this._node value.
  Vec3 exp2() => Vec3._(Exp2(this._node));

  /// Base-2 logarithm.
  Vec3 log2() => Vec3._(Log2(this._node));

  /// Square root.
  Vec3 sqrt() => Vec3._(Sqrt(this._node));

  /// Inverse square root. [1 / sqrt(this._node)].
  Vec3 isqrt() => Vec3._(InverseSqrt(this._node));

  /// Step returns 0 if value is less than [edge], 1 otherwise.
  Vec3 step(Vec3 edge) => Vec3._(Step(edge._node, this._node));

  /// Clamp restricts the value to be between min and max.
  Vec3 clamp(Vec3 min, Vec3 max) =>
      Vec3._(FClamp(this._node, min._node, max._node));

  /// Mix linearly interpolates between [a] and [b] as this value ranges from 0
  /// to 1.
  Vec3 mix(Vec3 a, Vec3 b) => Vec3._(FMix(a._node, b._node, this._node));

  /// Performs smooth Hermite interpolation between 0 and 1 as this value ranges
  /// from [a] to [b].
  Vec3 smoothStep(Vec3 a, Vec3 b) =>
      Vec3._(SmoothStep(a._node, b._node, this._node));

  /// Orients the vector to point away from a surface as defined by its normal.
  /// Returns the vector unchanged if `dot(reference, incident)` is below zero.
  /// Otherwise return the vector scaled by -1.
  Vec3 faceForward(Vec3 incident, Vec3 reference) =>
      Vec3._(FaceForward(this._node, incident._node, reference._node));

  /// Calculate the reflection direction for an incident vector.
  /// Returns `this - 2.0 * dot(normal, this) * normal`.
  Vec3 reflect(Vec3 normal) => Vec3._(Reflect(this._node, normal._node));

  vm.Vector3 evaluate() => vm.Vector3.array(_node.evaluate());
}
