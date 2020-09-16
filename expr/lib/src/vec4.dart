part of '../expr.dart';

// Both [Scalar] and [Vec4] implement this mixin.
mixin Vec4OrScalar on Expression {
  bool get _isVec4;
}

/// Vector [Expression] with four components.
class Vec4 extends Expression with Vec4OrScalar {
  const Vec4._(Evaluable child) : super._(child);

  Vec4 _construct(Evaluable node) {
    return Vec4._(node);
  }

  /// Construct a constant Vec4 with value [x, y, z, w].
  Vec4(double x, double y, double z, double w)
      : super._(OpConstantComposite.vec4(x, y, z, w));

  /// Construct a constant Vec4 with value [x, x, x, x].
  Vec4.all(double x) : super._(OpConstantComposite.vec4(x, x, x, x));

  /// Construct Vec4 from existing expressions. The total number
  /// of elements in the expressions in [components] must be 4.
  Vec4.of(List<Expression> components)
      : super._(
            OpCompositeConstruct.vec4(components.map((c) => c._node).toList()));

  /// Return the inverse tangent of `x / y`.
  static Vec4 aTan2(Vec4 x, Vec4 y) => Vec4._(ATan2(x._node, y._node));

  /// Return the minimum value between x and y.
  static Vec4 min(Vec4 x, Vec4 y) => Vec4._(FMin(x._node, y._node));

  /// Return the maximum value between x and y.
  static Vec4 max(Vec4 x, Vec4 y) => Vec4._(FMax(x._node, y._node));

  /// Returns the sum of this and [b].
  Vec4 operator +(Vec4 b) => Vec4._(OpFAdd(this._node, b._node));

  /// Returns the difference of this and [b].
  Vec4 operator -(Vec4 b) => Vec4._(OpFSub(this._node, b._node));

  /// Equivalent to `this * Vec4(-1)`.
  Vec4 operator -() => Vec4._(OpFNegate(this._node));

  /// Multiply by [b].
  Vec4 operator *(Vec4OrScalar b) {
    if (b._isVec4) {
      return Vec4._(OpFMul(this._node, b._node));
    } else {
      return Vec4._(OpVectorTimesScalar(this._node, b._node));
    }
  }

  /// Divide by [b].
  Vec4 operator /(Vec4OrScalar b) {
    if (b._isVec4) {
      return Vec4._(OpFDiv(this._node, b._node));
    } else {
      return Vec4._(
          OpVectorTimesScalar(this._node, OpFDiv(OpConstant(1), b._node)));
    }
  }

  /// Modulo by [b].
  Vec4 operator %(Vec4 b) => Vec4._(OpFMod(this._node, b._node));

  /// Raise to the power of [b].
  Vec4 operator ^(Vec4 b) => Vec4._(Pow(this._node, b._node));

  /// Length.
  Scalar length() => Scalar._(Length(this._node));

  /// Distance to [other].
  Scalar distanceTo(Vec4 other) => Scalar._(Distance(this._node, other._node));

  /// Dot product.
  Scalar dot(Vec4 b) => Scalar._(OpFDot(this._node, b._node));

  /// Truncate.
  Vec4 truncate() => Vec4._(Trunc(this._node));

  /// Absolute value.
  Vec4 abs() => Vec4._(FAbs(this._node));

  /// Returns [1] for postive values and [-1] for negative values.
  Vec4 sign() => Vec4._(FSign(this._node));

  /// Strip decimals.
  Vec4 floor() => Vec4._(Floor(this._node));

  /// Round up.
  Vec4 ceil() => Vec4._(Ceil(this._node));

  /// Isolate the fractional (decimal) value.
  Vec4 fract() => Vec4._(Fract(this._node));

  /// Converts degrees to radians.
  Vec4 radians() => Vec4._(Radians(this._node));

  /// Converts radians to degrees.
  Vec4 degrees() => Vec4._(Degrees(this._node));

  /// Interprets value as theta and calculates the sine.
  Vec4 sin() => Vec4._(Sin(this._node));

  /// Interprets value as theta and calculates the cosine.
  Vec4 cos() => Vec4._(Cos(this._node));

  /// Interprets value as theta and calculates the tangent.
  Vec4 tan() => Vec4._(Tan(this._node));

  /// Inverse-sine.
  Vec4 asin() => Vec4._(ASin(this._node));

  /// Inverse-cosine.
  Vec4 acos() => Vec4._(ACos(this._node));

  /// Inverse-tangent.
  Vec4 atan() => Vec4._(ATan(this._node));

  /// Natural exponent, e raised to the power of this value.
  Vec4 exp() => Vec4._(Exp(this._node));

  /// Natural logarithm, base e.
  Vec4 log() => Vec4._(Log(this._node));

  /// 2 raised to the power of this._node value.
  Vec4 exp2() => Vec4._(Exp2(this._node));

  /// Base-2 logarithm.
  Vec4 log2() => Vec4._(Log2(this._node));

  /// Square root.
  Vec4 sqrt() => Vec4._(Sqrt(this._node));

  /// Inverse square root. [1 / sqrt(this._node)].
  Vec4 isqrt() => Vec4._(InverseSqrt(this._node));

  /// Step returns 0 if value is less than [edge], 1 otherwise.
  Vec4 step(Vec4 edge) => Vec4._(Step(edge._node, this._node));

  /// Clamp restricts the value to be between min and max.
  Vec4 clamp(Vec4 min, Vec4 max) =>
      Vec4._(FClamp(this._node, min._node, max._node));

  /// Mix linearly interpolates between [a] and [b] as this value ranges from 0
  /// to 1.
  Vec4 mix(Vec4 a, Vec4 b) => Vec4._(FMix(a._node, b._node, this._node));

  /// Performs smooth Hermite interpolation between 0 and 1 as this value ranges
  /// from [a] to [b].
  Vec4 smoothStep(Vec4 a, Vec4 b) =>
      Vec4._(SmoothStep(a._node, b._node, this._node));

  /// Orients the vector to point away from a surface as defined by its normal.
  /// Returns the vector unchanged if `dot(reference, incident)` is below zero.
  /// Otherwise return the vector scaled by -1.
  Vec4 faceForward(Vec4 incident, Vec4 reference) =>
      Vec4._(FaceForward(this._node, incident._node, reference._node));

  /// Calculate the reflection direction for an incident vector.
  /// Returns `this - 2.0 * dot(normal, this) * normal`.
  Vec4 reflect(Vec4 normal) => Vec4._(Reflect(this._node, normal._node));

  vm.Vector4 evaluate() {
    _node.evaluate();
    return vm.Vector4.array(_node.value);
  }

  bool get _isVec4 => true;

  Scalar get x => Scalar._(OpCompositeExtract.vec(this._node, 0));
  Scalar get y => Scalar._(OpCompositeExtract.vec(this._node, 1));
  Scalar get z => Scalar._(OpCompositeExtract.vec(this._node, 2));
  Scalar get w => Scalar._(OpCompositeExtract.vec(this._node, 3));

  Scalar get r => x;
  Scalar get g => y;
  Scalar get b => z;
  Scalar get a => w;

  Vec2 get xy => Vec2._(OpVectorShuffle(this._node, [0, 1]));
}
