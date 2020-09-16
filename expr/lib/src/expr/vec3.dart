part of '../../expr.dart';

// Both [Scalar] and [Vec3] implement this mixin.
mixin Vec3OrScalar on Expression {
  bool get _isVec3;
}

/// Vector [Expression] with three components.
class Vec3 extends Expression with Vec3OrScalar {
  const Vec3._(Evaluable child) : super._(child);

  Vec3 _construct(Evaluable node) {
    return Vec3._(node);
  }

  /// Construct a constant Vec3 with value [x, y].
  Vec3(double x, double y, double z)
      : super._(OpConstantComposite.vec3(x, y, z));

  /// Construct a constant Vec3 with value [x, x].
  Vec3.all(double x) : super._(OpConstantComposite.vec3(x, x, x));

  /// Construct Vec3 from existing expressions. The total number
  /// of elements in the expressions in [components] must be 3.
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
  Vec3 operator *(Vec3OrScalar b) {
    if (b._isVec3) {
      return Vec3._(OpFMul(this._node, b._node));
    } else {
      return Vec3._(OpVectorTimesScalar(this._node, b._node));
    }
  }

  /// Divide by [b].
  Vec3 operator /(Vec3OrScalar b) {
    if (b._isVec3) {
      return Vec3._(OpFDiv(this._node, b._node));
    } else {
      return Vec3._(
          OpVectorTimesScalar(this._node, OpFDiv(OpConstant(1), b._node)));
    }
  }

  /// Modulo by [b].
  Vec3 operator %(Vec3 b) => Vec3._(OpFMod(this._node, b._node));

  /// Raise to the power of [b].
  Vec3 operator ^(Vec3 b) => Vec3._(Pow(this._node, b._node));

  /// Length.
  Scalar length() => Scalar._(Length(this._node));

  /// Distance to [other].
  Scalar distanceTo(Vec3 other) => Scalar._(Distance(this._node, other._node));

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

  vm.Vector3 evaluate() {
    _node.evaluate();
    return vm.Vector3.array(_node.value);
  }

  bool get _isVec3 => true;

  Scalar get x => Scalar._(OpCompositeExtract.vec(this._node, 0));
  Scalar get y => Scalar._(OpCompositeExtract.vec(this._node, 1));
  Scalar get z => Scalar._(OpCompositeExtract.vec(this._node, 2));

  Vec2 _vec2Swizzle(int x, int y) =>
      Vec2._(OpVectorShuffle(this._node, [x, y]));

  Vec2 get xx => _vec2Swizzle(0, 0);
  Vec2 get xy => _vec2Swizzle(0, 1);
  Vec2 get xz => _vec2Swizzle(0, 2);
  Vec2 get yx => _vec2Swizzle(1, 0);
  Vec2 get yy => _vec2Swizzle(1, 1);
  Vec2 get yz => _vec2Swizzle(1, 2);
  Vec2 get zx => _vec2Swizzle(2, 0);
  Vec2 get zy => _vec2Swizzle(2, 1);
  Vec2 get zz => _vec2Swizzle(2, 2);

  Vec3 _vec3Swizzle(int x, int y, int z) =>
      Vec3._(OpVectorShuffle(this._node, [x, y, z]));

  Vec3 get xxx => _vec3Swizzle(0, 0, 0);
  Vec3 get xxy => _vec3Swizzle(0, 0, 1);
  Vec3 get xxz => _vec3Swizzle(0, 0, 2);
  Vec3 get xyx => _vec3Swizzle(0, 1, 0);
  Vec3 get xyy => _vec3Swizzle(0, 1, 1);
  Vec3 get xyz => _vec3Swizzle(0, 1, 2);
  Vec3 get xzx => _vec3Swizzle(0, 2, 0);
  Vec3 get xzy => _vec3Swizzle(0, 2, 1);
  Vec3 get xzz => _vec3Swizzle(0, 2, 2);
  Vec3 get yxx => _vec3Swizzle(1, 0, 0);
  Vec3 get yxy => _vec3Swizzle(1, 0, 1);
  Vec3 get yxz => _vec3Swizzle(1, 0, 2);
  Vec3 get yyx => _vec3Swizzle(1, 1, 0);
  Vec3 get yyy => _vec3Swizzle(1, 1, 1);
  Vec3 get yyz => _vec3Swizzle(1, 1, 2);
  Vec3 get yzx => _vec3Swizzle(1, 2, 0);
  Vec3 get yzy => _vec3Swizzle(1, 2, 1);
  Vec3 get yzz => _vec3Swizzle(1, 2, 2);
  Vec3 get zxx => _vec3Swizzle(2, 0, 0);
  Vec3 get zxy => _vec3Swizzle(2, 0, 1);
  Vec3 get zxz => _vec3Swizzle(2, 0, 2);
  Vec3 get zyx => _vec3Swizzle(2, 1, 0);
  Vec3 get zyy => _vec3Swizzle(2, 1, 1);
  Vec3 get zyz => _vec3Swizzle(2, 1, 2);
  Vec3 get zzx => _vec3Swizzle(2, 2, 0);
  Vec3 get zzy => _vec3Swizzle(2, 2, 1);
  Vec3 get zzz => _vec3Swizzle(2, 2, 2);

  Vec4 _vec4Swizzle(int x, int y, int z, int w) =>
      Vec4._(OpVectorShuffle(this._node, [x, y, z, w]));

  Vec4 get xxxx => _vec4Swizzle(0, 0, 0, 0);
  Vec4 get xxxy => _vec4Swizzle(0, 0, 0, 1);
  Vec4 get xxxz => _vec4Swizzle(0, 0, 0, 2);
  Vec4 get xxyx => _vec4Swizzle(0, 0, 1, 0);
  Vec4 get xxyy => _vec4Swizzle(0, 0, 1, 1);
  Vec4 get xxyz => _vec4Swizzle(0, 0, 1, 2);
  Vec4 get xxzx => _vec4Swizzle(0, 0, 2, 0);
  Vec4 get xxzy => _vec4Swizzle(0, 0, 2, 1);
  Vec4 get xxzz => _vec4Swizzle(0, 0, 2, 2);
  Vec4 get xyxx => _vec4Swizzle(0, 1, 0, 0);
  Vec4 get xyxy => _vec4Swizzle(0, 1, 0, 1);
  Vec4 get xyxz => _vec4Swizzle(0, 1, 0, 2);
  Vec4 get xyyx => _vec4Swizzle(0, 1, 1, 0);
  Vec4 get xyyy => _vec4Swizzle(0, 1, 1, 1);
  Vec4 get xyyz => _vec4Swizzle(0, 1, 1, 2);
  Vec4 get xyzx => _vec4Swizzle(0, 1, 2, 0);
  Vec4 get xyzy => _vec4Swizzle(0, 1, 2, 1);
  Vec4 get xyzz => _vec4Swizzle(0, 1, 2, 2);
  Vec4 get xzxx => _vec4Swizzle(0, 2, 0, 0);
  Vec4 get xzxy => _vec4Swizzle(0, 2, 0, 1);
  Vec4 get xzxz => _vec4Swizzle(0, 2, 0, 2);
  Vec4 get xzyx => _vec4Swizzle(0, 2, 1, 0);
  Vec4 get xzyy => _vec4Swizzle(0, 2, 1, 1);
  Vec4 get xzyz => _vec4Swizzle(0, 2, 1, 2);
  Vec4 get xzzx => _vec4Swizzle(0, 2, 2, 0);
  Vec4 get xzzy => _vec4Swizzle(0, 2, 2, 1);
  Vec4 get xzzz => _vec4Swizzle(0, 2, 2, 2);
  Vec4 get yxxx => _vec4Swizzle(1, 0, 0, 0);
  Vec4 get yxxy => _vec4Swizzle(1, 0, 0, 1);
  Vec4 get yxxz => _vec4Swizzle(1, 0, 0, 2);
  Vec4 get yxyx => _vec4Swizzle(1, 0, 1, 0);
  Vec4 get yxyy => _vec4Swizzle(1, 0, 1, 1);
  Vec4 get yxyz => _vec4Swizzle(1, 0, 1, 2);
  Vec4 get yxzx => _vec4Swizzle(1, 0, 2, 0);
  Vec4 get yxzy => _vec4Swizzle(1, 0, 2, 1);
  Vec4 get yxzz => _vec4Swizzle(1, 0, 2, 2);
  Vec4 get yyxx => _vec4Swizzle(1, 1, 0, 0);
  Vec4 get yyxy => _vec4Swizzle(1, 1, 0, 1);
  Vec4 get yyxz => _vec4Swizzle(1, 1, 0, 2);
  Vec4 get yyyx => _vec4Swizzle(1, 1, 1, 0);
  Vec4 get yyyy => _vec4Swizzle(1, 1, 1, 1);
  Vec4 get yyyz => _vec4Swizzle(1, 1, 1, 2);
  Vec4 get yyzx => _vec4Swizzle(1, 1, 2, 0);
  Vec4 get yyzy => _vec4Swizzle(1, 1, 2, 1);
  Vec4 get yyzz => _vec4Swizzle(1, 1, 2, 2);
  Vec4 get yzxx => _vec4Swizzle(1, 2, 0, 0);
  Vec4 get yzxy => _vec4Swizzle(1, 2, 0, 1);
  Vec4 get yzxz => _vec4Swizzle(1, 2, 0, 2);
  Vec4 get yzyx => _vec4Swizzle(1, 2, 1, 0);
  Vec4 get yzyy => _vec4Swizzle(1, 2, 1, 1);
  Vec4 get yzyz => _vec4Swizzle(1, 2, 1, 2);
  Vec4 get yzzx => _vec4Swizzle(1, 2, 2, 0);
  Vec4 get yzzy => _vec4Swizzle(1, 2, 2, 1);
  Vec4 get yzzz => _vec4Swizzle(1, 2, 2, 2);
  Vec4 get zxxx => _vec4Swizzle(2, 0, 0, 0);
  Vec4 get zxxy => _vec4Swizzle(2, 0, 0, 1);
  Vec4 get zxxz => _vec4Swizzle(2, 0, 0, 2);
  Vec4 get zxyx => _vec4Swizzle(2, 0, 1, 0);
  Vec4 get zxyy => _vec4Swizzle(2, 0, 1, 1);
  Vec4 get zxyz => _vec4Swizzle(2, 0, 1, 2);
  Vec4 get zxzx => _vec4Swizzle(2, 0, 2, 0);
  Vec4 get zxzy => _vec4Swizzle(2, 0, 2, 1);
  Vec4 get zxzz => _vec4Swizzle(2, 0, 2, 2);
  Vec4 get zyxx => _vec4Swizzle(2, 1, 0, 0);
  Vec4 get zyxy => _vec4Swizzle(2, 1, 0, 1);
  Vec4 get zyxz => _vec4Swizzle(2, 1, 0, 2);
  Vec4 get zyyx => _vec4Swizzle(2, 1, 1, 0);
  Vec4 get zyyy => _vec4Swizzle(2, 1, 1, 1);
  Vec4 get zyyz => _vec4Swizzle(2, 1, 1, 2);
  Vec4 get zyzx => _vec4Swizzle(2, 1, 2, 0);
  Vec4 get zyzy => _vec4Swizzle(2, 1, 2, 1);
  Vec4 get zyzz => _vec4Swizzle(2, 1, 2, 2);
  Vec4 get zzxx => _vec4Swizzle(2, 2, 0, 0);
  Vec4 get zzxy => _vec4Swizzle(2, 2, 0, 1);
  Vec4 get zzxz => _vec4Swizzle(2, 2, 0, 2);
  Vec4 get zzyx => _vec4Swizzle(2, 2, 1, 0);
  Vec4 get zzyy => _vec4Swizzle(2, 2, 1, 1);
  Vec4 get zzyz => _vec4Swizzle(2, 2, 1, 2);
  Vec4 get zzzx => _vec4Swizzle(2, 2, 2, 0);
  Vec4 get zzzy => _vec4Swizzle(2, 2, 2, 1);
  Vec4 get zzzz => _vec4Swizzle(2, 2, 2, 2);
}
