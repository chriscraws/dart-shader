part of '../../shader.dart';

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

  /// Construct a Vec4 from four [Scalar] objects.
  Vec4(Scalar x, Scalar y, Scalar z, Scalar w)
      : super._(
            OpCompositeConstruct.vec4([x._node, y._node, z._node, w._node]));

  /// Construct a constant Vec4 with value [x, y, z, w].
  Vec4.constant(double x, double y, double z, double w)
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

  Vec2 _vec2Swizzle(int x, int y) =>
      Vec2._(OpVectorShuffle(this._node, [x, y]));

  Vec2 get xx => _vec2Swizzle(0, 0);
  Vec2 get xy => _vec2Swizzle(0, 1);
  Vec2 get xz => _vec2Swizzle(0, 2);
  Vec2 get xw => _vec2Swizzle(0, 3);
  Vec2 get yx => _vec2Swizzle(1, 0);
  Vec2 get yy => _vec2Swizzle(1, 1);
  Vec2 get yz => _vec2Swizzle(1, 2);
  Vec2 get yw => _vec2Swizzle(1, 3);
  Vec2 get zx => _vec2Swizzle(2, 0);
  Vec2 get zy => _vec2Swizzle(2, 1);
  Vec2 get zz => _vec2Swizzle(2, 2);
  Vec2 get zw => _vec2Swizzle(2, 3);
  Vec2 get wx => _vec2Swizzle(3, 0);
  Vec2 get wy => _vec2Swizzle(3, 1);
  Vec2 get wz => _vec2Swizzle(3, 2);
  Vec2 get ww => _vec2Swizzle(3, 3);

  Vec3 _vec3Swizzle(int x, int y, int z) =>
      Vec3._(OpVectorShuffle(this._node, [x, y, z]));

  Vec3 get xxx => _vec3Swizzle(0, 0, 0);
  Vec3 get xxy => _vec3Swizzle(0, 0, 1);
  Vec3 get xxz => _vec3Swizzle(0, 0, 2);
  Vec3 get xxw => _vec3Swizzle(0, 0, 3);
  Vec3 get xyx => _vec3Swizzle(0, 1, 0);
  Vec3 get xyy => _vec3Swizzle(0, 1, 1);
  Vec3 get xyz => _vec3Swizzle(0, 1, 2);
  Vec3 get xyw => _vec3Swizzle(0, 1, 3);
  Vec3 get xzx => _vec3Swizzle(0, 2, 0);
  Vec3 get xzy => _vec3Swizzle(0, 2, 1);
  Vec3 get xzz => _vec3Swizzle(0, 2, 2);
  Vec3 get xzw => _vec3Swizzle(0, 2, 3);
  Vec3 get xwx => _vec3Swizzle(0, 3, 0);
  Vec3 get xwy => _vec3Swizzle(0, 3, 1);
  Vec3 get xwz => _vec3Swizzle(0, 3, 2);
  Vec3 get xww => _vec3Swizzle(0, 3, 3);
  Vec3 get yxx => _vec3Swizzle(1, 0, 0);
  Vec3 get yxy => _vec3Swizzle(1, 0, 1);
  Vec3 get yxz => _vec3Swizzle(1, 0, 2);
  Vec3 get yxw => _vec3Swizzle(1, 0, 3);
  Vec3 get yyx => _vec3Swizzle(1, 1, 0);
  Vec3 get yyy => _vec3Swizzle(1, 1, 1);
  Vec3 get yyz => _vec3Swizzle(1, 1, 2);
  Vec3 get yyw => _vec3Swizzle(1, 1, 3);
  Vec3 get yzx => _vec3Swizzle(1, 2, 0);
  Vec3 get yzy => _vec3Swizzle(1, 2, 1);
  Vec3 get yzz => _vec3Swizzle(1, 2, 2);
  Vec3 get yzw => _vec3Swizzle(1, 2, 3);
  Vec3 get ywx => _vec3Swizzle(1, 3, 0);
  Vec3 get ywy => _vec3Swizzle(1, 3, 1);
  Vec3 get ywz => _vec3Swizzle(1, 3, 2);
  Vec3 get yww => _vec3Swizzle(1, 3, 3);
  Vec3 get zxx => _vec3Swizzle(2, 0, 0);
  Vec3 get zxy => _vec3Swizzle(2, 0, 1);
  Vec3 get zxz => _vec3Swizzle(2, 0, 2);
  Vec3 get zxw => _vec3Swizzle(2, 0, 3);
  Vec3 get zyx => _vec3Swizzle(2, 1, 0);
  Vec3 get zyy => _vec3Swizzle(2, 1, 1);
  Vec3 get zyz => _vec3Swizzle(2, 1, 2);
  Vec3 get zyw => _vec3Swizzle(2, 1, 3);
  Vec3 get zzx => _vec3Swizzle(2, 2, 0);
  Vec3 get zzy => _vec3Swizzle(2, 2, 1);
  Vec3 get zzz => _vec3Swizzle(2, 2, 2);
  Vec3 get zzw => _vec3Swizzle(2, 2, 3);
  Vec3 get zwx => _vec3Swizzle(2, 3, 0);
  Vec3 get zwy => _vec3Swizzle(2, 3, 1);
  Vec3 get zwz => _vec3Swizzle(2, 3, 2);
  Vec3 get zww => _vec3Swizzle(2, 3, 3);
  Vec3 get wxx => _vec3Swizzle(3, 0, 0);
  Vec3 get wxy => _vec3Swizzle(3, 0, 1);
  Vec3 get wxz => _vec3Swizzle(3, 0, 2);
  Vec3 get wxw => _vec3Swizzle(3, 0, 3);
  Vec3 get wyx => _vec3Swizzle(3, 1, 0);
  Vec3 get wyy => _vec3Swizzle(3, 1, 1);
  Vec3 get wyz => _vec3Swizzle(3, 1, 2);
  Vec3 get wyw => _vec3Swizzle(3, 1, 3);
  Vec3 get wzx => _vec3Swizzle(3, 2, 0);
  Vec3 get wzy => _vec3Swizzle(3, 2, 1);
  Vec3 get wzz => _vec3Swizzle(3, 2, 2);
  Vec3 get wzw => _vec3Swizzle(3, 2, 3);
  Vec3 get wwx => _vec3Swizzle(3, 3, 0);
  Vec3 get wwy => _vec3Swizzle(3, 3, 1);
  Vec3 get wwz => _vec3Swizzle(3, 3, 2);
  Vec3 get www => _vec3Swizzle(3, 3, 3);

  Vec4 _vec4Swizzle(int x, int y, int z, int w) =>
      Vec4._(OpVectorShuffle(this._node, [x, y, z, w]));

  Vec4 get xxxx => _vec4Swizzle(0, 0, 0, 0);
  Vec4 get xxxy => _vec4Swizzle(0, 0, 0, 1);
  Vec4 get xxxz => _vec4Swizzle(0, 0, 0, 2);
  Vec4 get xxxw => _vec4Swizzle(0, 0, 0, 3);
  Vec4 get xxyx => _vec4Swizzle(0, 0, 1, 0);
  Vec4 get xxyy => _vec4Swizzle(0, 0, 1, 1);
  Vec4 get xxyz => _vec4Swizzle(0, 0, 1, 2);
  Vec4 get xxyw => _vec4Swizzle(0, 0, 1, 3);
  Vec4 get xxzx => _vec4Swizzle(0, 0, 2, 0);
  Vec4 get xxzy => _vec4Swizzle(0, 0, 2, 1);
  Vec4 get xxzz => _vec4Swizzle(0, 0, 2, 2);
  Vec4 get xxzw => _vec4Swizzle(0, 0, 2, 3);
  Vec4 get xxwx => _vec4Swizzle(0, 0, 3, 0);
  Vec4 get xxwy => _vec4Swizzle(0, 0, 3, 1);
  Vec4 get xxwz => _vec4Swizzle(0, 0, 3, 2);
  Vec4 get xxww => _vec4Swizzle(0, 0, 3, 3);
  Vec4 get xyxx => _vec4Swizzle(0, 1, 0, 0);
  Vec4 get xyxy => _vec4Swizzle(0, 1, 0, 1);
  Vec4 get xyxz => _vec4Swizzle(0, 1, 0, 2);
  Vec4 get xyxw => _vec4Swizzle(0, 1, 0, 3);
  Vec4 get xyyx => _vec4Swizzle(0, 1, 1, 0);
  Vec4 get xyyy => _vec4Swizzle(0, 1, 1, 1);
  Vec4 get xyyz => _vec4Swizzle(0, 1, 1, 2);
  Vec4 get xyyw => _vec4Swizzle(0, 1, 1, 3);
  Vec4 get xyzx => _vec4Swizzle(0, 1, 2, 0);
  Vec4 get xyzy => _vec4Swizzle(0, 1, 2, 1);
  Vec4 get xyzz => _vec4Swizzle(0, 1, 2, 2);
  Vec4 get xyzw => _vec4Swizzle(0, 1, 2, 3);
  Vec4 get xywx => _vec4Swizzle(0, 1, 3, 0);
  Vec4 get xywy => _vec4Swizzle(0, 1, 3, 1);
  Vec4 get xywz => _vec4Swizzle(0, 1, 3, 2);
  Vec4 get xyww => _vec4Swizzle(0, 1, 3, 3);
  Vec4 get xzxx => _vec4Swizzle(0, 2, 0, 0);
  Vec4 get xzxy => _vec4Swizzle(0, 2, 0, 1);
  Vec4 get xzxz => _vec4Swizzle(0, 2, 0, 2);
  Vec4 get xzxw => _vec4Swizzle(0, 2, 0, 3);
  Vec4 get xzyx => _vec4Swizzle(0, 2, 1, 0);
  Vec4 get xzyy => _vec4Swizzle(0, 2, 1, 1);
  Vec4 get xzyz => _vec4Swizzle(0, 2, 1, 2);
  Vec4 get xzyw => _vec4Swizzle(0, 2, 1, 3);
  Vec4 get xzzx => _vec4Swizzle(0, 2, 2, 0);
  Vec4 get xzzy => _vec4Swizzle(0, 2, 2, 1);
  Vec4 get xzzz => _vec4Swizzle(0, 2, 2, 2);
  Vec4 get xzzw => _vec4Swizzle(0, 2, 2, 3);
  Vec4 get xzwx => _vec4Swizzle(0, 2, 3, 0);
  Vec4 get xzwy => _vec4Swizzle(0, 2, 3, 1);
  Vec4 get xzwz => _vec4Swizzle(0, 2, 3, 2);
  Vec4 get xzww => _vec4Swizzle(0, 2, 3, 3);
  Vec4 get xwxx => _vec4Swizzle(0, 3, 0, 0);
  Vec4 get xwxy => _vec4Swizzle(0, 3, 0, 1);
  Vec4 get xwxz => _vec4Swizzle(0, 3, 0, 2);
  Vec4 get xwxw => _vec4Swizzle(0, 3, 0, 3);
  Vec4 get xwyx => _vec4Swizzle(0, 3, 1, 0);
  Vec4 get xwyy => _vec4Swizzle(0, 3, 1, 1);
  Vec4 get xwyz => _vec4Swizzle(0, 3, 1, 2);
  Vec4 get xwyw => _vec4Swizzle(0, 3, 1, 3);
  Vec4 get xwzx => _vec4Swizzle(0, 3, 2, 0);
  Vec4 get xwzy => _vec4Swizzle(0, 3, 2, 1);
  Vec4 get xwzz => _vec4Swizzle(0, 3, 2, 2);
  Vec4 get xwzw => _vec4Swizzle(0, 3, 2, 3);
  Vec4 get xwwx => _vec4Swizzle(0, 3, 3, 0);
  Vec4 get xwwy => _vec4Swizzle(0, 3, 3, 1);
  Vec4 get xwwz => _vec4Swizzle(0, 3, 3, 2);
  Vec4 get xwww => _vec4Swizzle(0, 3, 3, 3);
  Vec4 get yxxx => _vec4Swizzle(1, 0, 0, 0);
  Vec4 get yxxy => _vec4Swizzle(1, 0, 0, 1);
  Vec4 get yxxz => _vec4Swizzle(1, 0, 0, 2);
  Vec4 get yxxw => _vec4Swizzle(1, 0, 0, 3);
  Vec4 get yxyx => _vec4Swizzle(1, 0, 1, 0);
  Vec4 get yxyy => _vec4Swizzle(1, 0, 1, 1);
  Vec4 get yxyz => _vec4Swizzle(1, 0, 1, 2);
  Vec4 get yxyw => _vec4Swizzle(1, 0, 1, 3);
  Vec4 get yxzx => _vec4Swizzle(1, 0, 2, 0);
  Vec4 get yxzy => _vec4Swizzle(1, 0, 2, 1);
  Vec4 get yxzz => _vec4Swizzle(1, 0, 2, 2);
  Vec4 get yxzw => _vec4Swizzle(1, 0, 2, 3);
  Vec4 get yxwx => _vec4Swizzle(1, 0, 3, 0);
  Vec4 get yxwy => _vec4Swizzle(1, 0, 3, 1);
  Vec4 get yxwz => _vec4Swizzle(1, 0, 3, 2);
  Vec4 get yxww => _vec4Swizzle(1, 0, 3, 3);
  Vec4 get yyxx => _vec4Swizzle(1, 1, 0, 0);
  Vec4 get yyxy => _vec4Swizzle(1, 1, 0, 1);
  Vec4 get yyxz => _vec4Swizzle(1, 1, 0, 2);
  Vec4 get yyxw => _vec4Swizzle(1, 1, 0, 3);
  Vec4 get yyyx => _vec4Swizzle(1, 1, 1, 0);
  Vec4 get yyyy => _vec4Swizzle(1, 1, 1, 1);
  Vec4 get yyyz => _vec4Swizzle(1, 1, 1, 2);
  Vec4 get yyyw => _vec4Swizzle(1, 1, 1, 3);
  Vec4 get yyzx => _vec4Swizzle(1, 1, 2, 0);
  Vec4 get yyzy => _vec4Swizzle(1, 1, 2, 1);
  Vec4 get yyzz => _vec4Swizzle(1, 1, 2, 2);
  Vec4 get yyzw => _vec4Swizzle(1, 1, 2, 3);
  Vec4 get yywx => _vec4Swizzle(1, 1, 3, 0);
  Vec4 get yywy => _vec4Swizzle(1, 1, 3, 1);
  Vec4 get yywz => _vec4Swizzle(1, 1, 3, 2);
  Vec4 get yyww => _vec4Swizzle(1, 1, 3, 3);
  Vec4 get yzxx => _vec4Swizzle(1, 2, 0, 0);
  Vec4 get yzxy => _vec4Swizzle(1, 2, 0, 1);
  Vec4 get yzxz => _vec4Swizzle(1, 2, 0, 2);
  Vec4 get yzxw => _vec4Swizzle(1, 2, 0, 3);
  Vec4 get yzyx => _vec4Swizzle(1, 2, 1, 0);
  Vec4 get yzyy => _vec4Swizzle(1, 2, 1, 1);
  Vec4 get yzyz => _vec4Swizzle(1, 2, 1, 2);
  Vec4 get yzyw => _vec4Swizzle(1, 2, 1, 3);
  Vec4 get yzzx => _vec4Swizzle(1, 2, 2, 0);
  Vec4 get yzzy => _vec4Swizzle(1, 2, 2, 1);
  Vec4 get yzzz => _vec4Swizzle(1, 2, 2, 2);
  Vec4 get yzzw => _vec4Swizzle(1, 2, 2, 3);
  Vec4 get yzwx => _vec4Swizzle(1, 2, 3, 0);
  Vec4 get yzwy => _vec4Swizzle(1, 2, 3, 1);
  Vec4 get yzwz => _vec4Swizzle(1, 2, 3, 2);
  Vec4 get yzww => _vec4Swizzle(1, 2, 3, 3);
  Vec4 get ywxx => _vec4Swizzle(1, 3, 0, 0);
  Vec4 get ywxy => _vec4Swizzle(1, 3, 0, 1);
  Vec4 get ywxz => _vec4Swizzle(1, 3, 0, 2);
  Vec4 get ywxw => _vec4Swizzle(1, 3, 0, 3);
  Vec4 get ywyx => _vec4Swizzle(1, 3, 1, 0);
  Vec4 get ywyy => _vec4Swizzle(1, 3, 1, 1);
  Vec4 get ywyz => _vec4Swizzle(1, 3, 1, 2);
  Vec4 get ywyw => _vec4Swizzle(1, 3, 1, 3);
  Vec4 get ywzx => _vec4Swizzle(1, 3, 2, 0);
  Vec4 get ywzy => _vec4Swizzle(1, 3, 2, 1);
  Vec4 get ywzz => _vec4Swizzle(1, 3, 2, 2);
  Vec4 get ywzw => _vec4Swizzle(1, 3, 2, 3);
  Vec4 get ywwx => _vec4Swizzle(1, 3, 3, 0);
  Vec4 get ywwy => _vec4Swizzle(1, 3, 3, 1);
  Vec4 get ywwz => _vec4Swizzle(1, 3, 3, 2);
  Vec4 get ywww => _vec4Swizzle(1, 3, 3, 3);
  Vec4 get zxxx => _vec4Swizzle(2, 0, 0, 0);
  Vec4 get zxxy => _vec4Swizzle(2, 0, 0, 1);
  Vec4 get zxxz => _vec4Swizzle(2, 0, 0, 2);
  Vec4 get zxxw => _vec4Swizzle(2, 0, 0, 3);
  Vec4 get zxyx => _vec4Swizzle(2, 0, 1, 0);
  Vec4 get zxyy => _vec4Swizzle(2, 0, 1, 1);
  Vec4 get zxyz => _vec4Swizzle(2, 0, 1, 2);
  Vec4 get zxyw => _vec4Swizzle(2, 0, 1, 3);
  Vec4 get zxzx => _vec4Swizzle(2, 0, 2, 0);
  Vec4 get zxzy => _vec4Swizzle(2, 0, 2, 1);
  Vec4 get zxzz => _vec4Swizzle(2, 0, 2, 2);
  Vec4 get zxzw => _vec4Swizzle(2, 0, 2, 3);
  Vec4 get zxwx => _vec4Swizzle(2, 0, 3, 0);
  Vec4 get zxwy => _vec4Swizzle(2, 0, 3, 1);
  Vec4 get zxwz => _vec4Swizzle(2, 0, 3, 2);
  Vec4 get zxww => _vec4Swizzle(2, 0, 3, 3);
  Vec4 get zyxx => _vec4Swizzle(2, 1, 0, 0);
  Vec4 get zyxy => _vec4Swizzle(2, 1, 0, 1);
  Vec4 get zyxz => _vec4Swizzle(2, 1, 0, 2);
  Vec4 get zyxw => _vec4Swizzle(2, 1, 0, 3);
  Vec4 get zyyx => _vec4Swizzle(2, 1, 1, 0);
  Vec4 get zyyy => _vec4Swizzle(2, 1, 1, 1);
  Vec4 get zyyz => _vec4Swizzle(2, 1, 1, 2);
  Vec4 get zyyw => _vec4Swizzle(2, 1, 1, 3);
  Vec4 get zyzx => _vec4Swizzle(2, 1, 2, 0);
  Vec4 get zyzy => _vec4Swizzle(2, 1, 2, 1);
  Vec4 get zyzz => _vec4Swizzle(2, 1, 2, 2);
  Vec4 get zyzw => _vec4Swizzle(2, 1, 2, 3);
  Vec4 get zywx => _vec4Swizzle(2, 1, 3, 0);
  Vec4 get zywy => _vec4Swizzle(2, 1, 3, 1);
  Vec4 get zywz => _vec4Swizzle(2, 1, 3, 2);
  Vec4 get zyww => _vec4Swizzle(2, 1, 3, 3);
  Vec4 get zzxx => _vec4Swizzle(2, 2, 0, 0);
  Vec4 get zzxy => _vec4Swizzle(2, 2, 0, 1);
  Vec4 get zzxz => _vec4Swizzle(2, 2, 0, 2);
  Vec4 get zzxw => _vec4Swizzle(2, 2, 0, 3);
  Vec4 get zzyx => _vec4Swizzle(2, 2, 1, 0);
  Vec4 get zzyy => _vec4Swizzle(2, 2, 1, 1);
  Vec4 get zzyz => _vec4Swizzle(2, 2, 1, 2);
  Vec4 get zzyw => _vec4Swizzle(2, 2, 1, 3);
  Vec4 get zzzx => _vec4Swizzle(2, 2, 2, 0);
  Vec4 get zzzy => _vec4Swizzle(2, 2, 2, 1);
  Vec4 get zzzz => _vec4Swizzle(2, 2, 2, 2);
  Vec4 get zzzw => _vec4Swizzle(2, 2, 2, 3);
  Vec4 get zzwx => _vec4Swizzle(2, 2, 3, 0);
  Vec4 get zzwy => _vec4Swizzle(2, 2, 3, 1);
  Vec4 get zzwz => _vec4Swizzle(2, 2, 3, 2);
  Vec4 get zzww => _vec4Swizzle(2, 2, 3, 3);
  Vec4 get zwxx => _vec4Swizzle(2, 3, 0, 0);
  Vec4 get zwxy => _vec4Swizzle(2, 3, 0, 1);
  Vec4 get zwxz => _vec4Swizzle(2, 3, 0, 2);
  Vec4 get zwxw => _vec4Swizzle(2, 3, 0, 3);
  Vec4 get zwyx => _vec4Swizzle(2, 3, 1, 0);
  Vec4 get zwyy => _vec4Swizzle(2, 3, 1, 1);
  Vec4 get zwyz => _vec4Swizzle(2, 3, 1, 2);
  Vec4 get zwyw => _vec4Swizzle(2, 3, 1, 3);
  Vec4 get zwzx => _vec4Swizzle(2, 3, 2, 0);
  Vec4 get zwzy => _vec4Swizzle(2, 3, 2, 1);
  Vec4 get zwzz => _vec4Swizzle(2, 3, 2, 2);
  Vec4 get zwzw => _vec4Swizzle(2, 3, 2, 3);
  Vec4 get zwwx => _vec4Swizzle(2, 3, 3, 0);
  Vec4 get zwwy => _vec4Swizzle(2, 3, 3, 1);
  Vec4 get zwwz => _vec4Swizzle(2, 3, 3, 2);
  Vec4 get zwww => _vec4Swizzle(2, 3, 3, 3);
  Vec4 get wxxx => _vec4Swizzle(3, 0, 0, 0);
  Vec4 get wxxy => _vec4Swizzle(3, 0, 0, 1);
  Vec4 get wxxz => _vec4Swizzle(3, 0, 0, 2);
  Vec4 get wxxw => _vec4Swizzle(3, 0, 0, 3);
  Vec4 get wxyx => _vec4Swizzle(3, 0, 1, 0);
  Vec4 get wxyy => _vec4Swizzle(3, 0, 1, 1);
  Vec4 get wxyz => _vec4Swizzle(3, 0, 1, 2);
  Vec4 get wxyw => _vec4Swizzle(3, 0, 1, 3);
  Vec4 get wxzx => _vec4Swizzle(3, 0, 2, 0);
  Vec4 get wxzy => _vec4Swizzle(3, 0, 2, 1);
  Vec4 get wxzz => _vec4Swizzle(3, 0, 2, 2);
  Vec4 get wxzw => _vec4Swizzle(3, 0, 2, 3);
  Vec4 get wxwx => _vec4Swizzle(3, 0, 3, 0);
  Vec4 get wxwy => _vec4Swizzle(3, 0, 3, 1);
  Vec4 get wxwz => _vec4Swizzle(3, 0, 3, 2);
  Vec4 get wxww => _vec4Swizzle(3, 0, 3, 3);
  Vec4 get wyxx => _vec4Swizzle(3, 1, 0, 0);
  Vec4 get wyxy => _vec4Swizzle(3, 1, 0, 1);
  Vec4 get wyxz => _vec4Swizzle(3, 1, 0, 2);
  Vec4 get wyxw => _vec4Swizzle(3, 1, 0, 3);
  Vec4 get wyyx => _vec4Swizzle(3, 1, 1, 0);
  Vec4 get wyyy => _vec4Swizzle(3, 1, 1, 1);
  Vec4 get wyyz => _vec4Swizzle(3, 1, 1, 2);
  Vec4 get wyyw => _vec4Swizzle(3, 1, 1, 3);
  Vec4 get wyzx => _vec4Swizzle(3, 1, 2, 0);
  Vec4 get wyzy => _vec4Swizzle(3, 1, 2, 1);
  Vec4 get wyzz => _vec4Swizzle(3, 1, 2, 2);
  Vec4 get wyzw => _vec4Swizzle(3, 1, 2, 3);
  Vec4 get wywx => _vec4Swizzle(3, 1, 3, 0);
  Vec4 get wywy => _vec4Swizzle(3, 1, 3, 1);
  Vec4 get wywz => _vec4Swizzle(3, 1, 3, 2);
  Vec4 get wyww => _vec4Swizzle(3, 1, 3, 3);
  Vec4 get wzxx => _vec4Swizzle(3, 2, 0, 0);
  Vec4 get wzxy => _vec4Swizzle(3, 2, 0, 1);
  Vec4 get wzxz => _vec4Swizzle(3, 2, 0, 2);
  Vec4 get wzxw => _vec4Swizzle(3, 2, 0, 3);
  Vec4 get wzyx => _vec4Swizzle(3, 2, 1, 0);
  Vec4 get wzyy => _vec4Swizzle(3, 2, 1, 1);
  Vec4 get wzyz => _vec4Swizzle(3, 2, 1, 2);
  Vec4 get wzyw => _vec4Swizzle(3, 2, 1, 3);
  Vec4 get wzzx => _vec4Swizzle(3, 2, 2, 0);
  Vec4 get wzzy => _vec4Swizzle(3, 2, 2, 1);
  Vec4 get wzzz => _vec4Swizzle(3, 2, 2, 2);
  Vec4 get wzzw => _vec4Swizzle(3, 2, 2, 3);
  Vec4 get wzwx => _vec4Swizzle(3, 2, 3, 0);
  Vec4 get wzwy => _vec4Swizzle(3, 2, 3, 1);
  Vec4 get wzwz => _vec4Swizzle(3, 2, 3, 2);
  Vec4 get wzww => _vec4Swizzle(3, 2, 3, 3);
  Vec4 get wwxx => _vec4Swizzle(3, 3, 0, 0);
  Vec4 get wwxy => _vec4Swizzle(3, 3, 0, 1);
  Vec4 get wwxz => _vec4Swizzle(3, 3, 0, 2);
  Vec4 get wwxw => _vec4Swizzle(3, 3, 0, 3);
  Vec4 get wwyx => _vec4Swizzle(3, 3, 1, 0);
  Vec4 get wwyy => _vec4Swizzle(3, 3, 1, 1);
  Vec4 get wwyz => _vec4Swizzle(3, 3, 1, 2);
  Vec4 get wwyw => _vec4Swizzle(3, 3, 1, 3);
  Vec4 get wwzx => _vec4Swizzle(3, 3, 2, 0);
  Vec4 get wwzy => _vec4Swizzle(3, 3, 2, 1);
  Vec4 get wwzz => _vec4Swizzle(3, 3, 2, 2);
  Vec4 get wwzw => _vec4Swizzle(3, 3, 2, 3);
  Vec4 get wwwx => _vec4Swizzle(3, 3, 3, 0);
  Vec4 get wwwy => _vec4Swizzle(3, 3, 3, 1);
  Vec4 get wwwz => _vec4Swizzle(3, 3, 3, 2);
  Vec4 get wwww => _vec4Swizzle(3, 3, 3, 3);
}
