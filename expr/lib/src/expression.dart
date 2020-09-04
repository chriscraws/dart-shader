import 'dart:math';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart' as vm;

import './spirv/spirv.dart' as spirv;
import './spirv/glsl.dart' as spirv;

/// Exception that is thrown when a vector or matrix component
/// is devided by zero.
class DivideByZero implements Exception {
  String toString() => 'Tried to divide component by zero.';
}

/// Shader can be used to construct a spir-v module
/// compatible with Flutter.
class Shader {
  /// The color of each fragment position.
  final Vec4 color;

  Shader({this.color}) : assert(color != null);

  /// Encode the shader as Flutter-compatible SPIR-V.
  ByteBuffer toSPIRV() {
    final module = spirv.Module();
    module.color = color._instruction;
    return module.encode();
  }
}

/// Node within an SSIR abstract syntax tree.
abstract class Expression {
  final spirv.Instruction _instruction;

  Expression._(this._instruction) : assert(_instruction != null);

  spirv.Type get _type;

  List<double> _evaluate();
}

abstract class Scalar extends Expression {
  Scalar._(spirv.Instruction inst) : super._(inst);

  spirv.Type get _type => spirv.floatT;

  factory Scalar(double value) => _ConstScalar(value);

  Scalar operator +(Scalar b) => _Scalar(_Add(this, b));
  Scalar operator -(Scalar b) => _Scalar(_Subtract(this, b));
  Scalar operator -() => _Scalar(_Negate(this));
  Scalar operator *(Scalar b) => _Scalar(_Multiply(this, b));
  Scalar operator /(Scalar b) => _Scalar(_Divide(this, b));
  Scalar operator %(Scalar b) => _Scalar(_Mod(this, b));

  double evaluate() => _evaluate()[0];
}

abstract class Vec2 extends Expression {
  Vec2._(spirv.Instruction instruction) : super._(instruction);

  spirv.Type get _type => spirv.vec2T;

  factory Vec2(double x, double y) => _ConstVec2(x, y);

  Vec2 operator +(Vec2 b) => _Vec2(_Add(this, b));
  Vec2 operator -(Vec2 b) => _Vec2(_Subtract(this, b));
  Vec2 operator -() => _Vec2(_Negate(this));
  Vec2 operator *(Vec2 b) => _Vec2(_Multiply(this, b));
  Vec2 operator /(Vec2 b) => _Vec2(_Divide(this, b));
  Vec2 operator %(Vec2 b) => _Vec2(_Mod(this, b));

  Scalar dot(Vec2 b) => _Scalar(_Dot(this, b));
  Vec2 scale(Scalar s) => _Vec2(_Scale(this, s));

  vm.Vector2 evaluate() => vm.Vector2.array(_evaluate());
}

abstract class Vec3 extends Expression {
  Vec3._(spirv.Instruction instruction) : super._(instruction);

  spirv.Type get _type => spirv.vec3T;

  factory Vec3(double x, double y, double z) => _ConstVec3(x, y, z);

  Vec3 operator +(Vec3 b) => _Vec3(_Add(this, b));
  Vec3 operator -(Vec3 b) => _Vec3(_Subtract(this, b));
  Vec3 operator -() => _Vec3(_Negate(this));
  Vec3 operator *(Vec3 b) => _Vec3(_Multiply(this, b));
  Vec3 operator /(Vec3 b) => _Vec3(_Divide(this, b));
  Vec3 operator %(Vec3 b) => _Vec3(_Mod(this, b));

  Scalar dot(Vec3 b) => _Scalar(_Dot(this, b));
  Vec3 scale(Scalar s) => _Vec3(_Scale(this, s));

  vm.Vector3 evaluate() => vm.Vector3.array(_evaluate());
}

abstract class Vec4 extends Expression {
  Vec4._(spirv.Instruction instruction) : super._(instruction);

  spirv.Type get _type => spirv.vec4T;

  factory Vec4(double x, double y, double z, double w) =>
      _ConstVec4(x, y, z, w);

  factory Vec4.of(List<Expression> components) =>
      _Vec4(_Composite(components, spirv.vec4T));

  Vec4 operator +(Vec4 b) => _Vec4(_Add(this, b));
  Vec4 operator -(Vec4 b) => _Vec4(_Subtract(this, b));
  Vec4 operator -() => _Vec4(_Negate(this));
  Vec4 operator *(Vec4 b) => _Vec4(_Multiply(this, b));
  Vec4 operator /(Vec4 b) => _Vec4(_Divide(this, b));
  Vec4 operator %(Vec4 b) => _Vec4(_Mod(this, b));
  Vec4 operator ^(Vec4 b) => _Vec4(_Pow(this, b));

  /// Return the inverse tangent of `x / y`. Component-wise.
  factory Vec4.aTan2(Vec4 x, Vec4 y) => _Vec4(_ATan2(x, y));

  /// Return the minimum value between x and y. Component-wise.
  factory Vec4.min(Vec4 x, Vec4 y) => _Vec4(_FMin(x, y));

  /// Return the maximum value between x and y. Component-wise.
  factory Vec4.max(Vec4 x, Vec4 y) => _Vec4(_FMax(x, y));

  /// Length.
  Scalar length() => _Length(this);

  /// Dot product.
  Scalar dot(Vec4 b) => _Dot(this, b);

  /// Scale by [s].
  Vec4 scale(Scalar s) => _Vec4(_Scale(this, s));

  /// Truncate. Component-wise.
  Vec4 truncate() => _Vec4(_Trunc(this));

  /// Absolute value. Component-wise.
  Vec4 abs() => _Vec4(_FAbs(this));

  /// Returns [1] for postive values and [-1] for negative values.
  /// Component-wise.
  Vec4 sign() => _Vec4(_FSign(this));

  /// Strip decimals. Component-wise.
  Vec4 floor() => _Vec4(_Floor(this));

  /// Round up. Component-wise.
  Vec4 ceil() => _Vec4(_Ceil(this));

  /// Isolate the fractional (decimal) value. Component-wise.
  Vec4 fract() => _Vec4(_Fract(this));

  /// Converts degrees to radians. Component-wise.
  Vec4 radians() => _Vec4(_Radians(this));

  /// Converts radians to degrees. Component-wise.
  Vec4 degrees() => _Vec4(_Degrees(this));

  /// Interprets value as theta and calculates the sine. Component-wise.
  Vec4 sin() => _Vec4(_Sin(this));

  /// Interprets value as theta and calculates the cosine. Component-wise.
  Vec4 cos() => _Vec4(_Cos(this));

  /// Interprets value as theta and calculates the tangent. Component-wise.
  Vec4 tan() => _Vec4(_Tan(this));

  /// Inverse-sine. Component-wise.
  Vec4 asin() => _Vec4(_ASin(this));

  /// Inverse-cosine. Component-wise.
  Vec4 acos() => _Vec4(_ACos(this));

  /// Inverse-tangent. Component-wise.
  Vec4 atan() => _Vec4(_ATan(this));

  /// Natural exponent, e raised to the power of this value. Component-wise.
  Vec4 exp() => _Vec4(_Exp(this));

  /// Natural logarithm, base e. Component-wise.
  Vec4 log() => _Vec4(_Log(this));

  /// 2 raised to the power of this value. Component-wise.
  Vec4 exp2() => _Vec4(_Exp2(this));

  /// Base-2 logarithm. Component-wise.
  Vec4 log2() => _Vec4(_Log2(this));

  /// Square root. Component-wise.
  Vec4 sqrt() => _Vec4(_Sqrt(this));

  /// Inverse square root. [1 / sqrt(this)]. Component-wise.
  Vec4 isqrt() => _Vec4(_InverseSqrt(this));

  /// Normalize the vector. Divide all components by vector length.
  Vec4 normalize() => _Vec4(_Normalize(this));

  /// Step returns 0 if value is less than [edge], 1 otherwise. Component-wise.
  Vec4 step(Vec4 edge) => _Vec4(_Step(edge, this));

  /// Clamp restricts the value to be between min and max. Component-wise.
  Vec4 clamp(Vec4 min, Vec4 max) => _Vec4(_Clamp(this, min, max));

  /// Mix linearly interpolates between [a] and [b] as this value ranges from 0
  /// to 1. Component-wise.
  Vec4 mix(Vec4 a, Vec4 b) => _Vec4(_Mix(a, b, this));

  /// Performs smooth Hermite interpolation between 0 and 1 as this value ranges
  /// from [a] to [b]. Component-wise.
  Vec4 smoothStep(Vec4 a, Vec4 b) => _Vec4(_SmoothStep(a, b, this));

  /// Orients the vector to point away from a surface as defined by its normal.
  /// Returns the vector unchanged if `dot(reference, incident)` is below zero.
  /// Otherwise return the vector scaled by -1.
  Vec4 faceForward(Vec4 incident, Vec4 reference) =>
      _Vec4(_FaceForward(this, incident, reference));

  /// Calculate the reflection direction for an incident vector.
  /// Returns [this - 2.0 * dot(normal, this) * normal].
  Vec4 reflect(Vec4 normal) => _Vec4(_Reflect(this, normal));

  vm.Vector4 evaluate() => vm.Vector4.array(_evaluate());
}

class _ConstScalar extends Scalar {
  final double value;

  _ConstScalar(this.value)
      : assert(value != null),
        super._(spirv.OpConstant(value));

  List<double> _evaluate() => [value];
}

class _ConstVec2 extends Vec2 {
  final double x;
  final double y;

  _ConstVec2(this.x, this.y)
      : assert(x != null),
        assert(y != null),
        super._(spirv.OpConstantComposite.vec2(x, y));

  List<double> _evaluate() => [x, y];
}

class _ConstVec3 extends Vec3 {
  final double x;
  final double y;
  final double z;

  _ConstVec3(this.x, this.y, this.z)
      : assert(x != null),
        assert(y != null),
        assert(z != null),
        super._(spirv.OpConstantComposite.vec3(x, y, z));

  List<double> _evaluate() => [x, y, z];
}

class _ConstVec4 extends Vec4 {
  final double x;
  final double y;
  final double z;
  final double w;

  _ConstVec4(this.x, this.y, this.z, this.w)
      : assert(x != null),
        assert(y != null),
        assert(z != null),
        assert(w != null),
        super._(spirv.OpConstantComposite.vec4(x, y, z, w));

  List<double> _evaluate() => [x, y, z, w];
}

class _Scalar extends Scalar {
  final Expression child;

  _Scalar(this.child)
      : assert(child != null),
        assert(child._type == spirv.floatT),
        super._(child._instruction);

  List<double> _evaluate() => child._evaluate();
}

class _Vec2 extends Vec2 {
  final Expression child;

  _Vec2(this.child)
      : assert(child != null),
        assert(child._type == spirv.vec2T),
        super._(child._instruction);

  List<double> _evaluate() => child._evaluate();
}

class _Vec3 extends Vec3 {
  final Expression child;

  _Vec3(this.child)
      : assert(child != null),
        assert(child._type == spirv.vec3T),
        super._(child._instruction);

  List<double> _evaluate() => child._evaluate();
}

class _Vec4 extends Vec4 {
  final Expression child;

  _Vec4(this.child)
      : assert(child != null),
        assert(child._type == spirv.vec4T),
        super._(child._instruction);

  List<double> _evaluate() => child._evaluate();
}

class _Composite extends Expression {
  final List<Expression> children;
  final spirv.Type _type;
  final int elementCount;

  _Composite(this.children, this._type)
      : assert(_type != null),
        assert(children != null),
        elementCount = children.length,
        super._(spirv.OpCompositeConstruct(
          children.map((child) => child._instruction).toList(),
        ));

  List<double> _evaluate() => children.fold([], (out, child) {
        out.addAll(child._evaluate());
        return out;
      });
}

abstract class _UniOp extends Expression {
  final Expression a;

  _UniOp(this.a, spirv.Instruction instruction) : super._(instruction);

  spirv.Type get _type => a._type;

  double _op(double a);

  List<double> _evaluate() => a._evaluate().map(_op).toList();
}

class _Negate extends _UniOp {
  _Negate(Expression a) : super(a, spirv.OpFNegate(a._instruction));

  @override
  double _op(double a) => -a;
}

class _Trunc extends _UniOp {
  _Trunc(Expression a) : super(a, spirv.Trunc(a._instruction));

  @override
  double _op(double a) => a.truncateToDouble();
}

class _FAbs extends _UniOp {
  _FAbs(Expression a) : super(a, spirv.FAbs(a._instruction));

  @override
  double _op(double a) => a.abs();
}

class _FSign extends _UniOp {
  _FSign(Expression a) : super(a, spirv.FSign(a._instruction));

  @override
  double _op(double a) => a.sign;
}

class _Floor extends _UniOp {
  _Floor(Expression a) : super(a, spirv.Floor(a._instruction));

  @override
  double _op(double a) => a.floorToDouble();
}

class _Ceil extends _UniOp {
  _Ceil(Expression a) : super(a, spirv.Ceil(a._instruction));

  @override
  double _op(double a) => a.ceilToDouble();
}

class _Fract extends _UniOp {
  _Fract(Expression a) : super(a, spirv.Fract(a._instruction));

  @override
  double _op(double a) => a - a.floorToDouble();
}

class _Radians extends _UniOp {
  _Radians(Expression a) : super(a, spirv.Radians(a._instruction));

  @override
  double _op(double a) => vm.radians(a);
}

class _Degrees extends _UniOp {
  _Degrees(Expression a) : super(a, spirv.Degrees(a._instruction));

  @override
  double _op(double a) => vm.degrees(a);
}

class _Sin extends _UniOp {
  _Sin(Expression a) : super(a, spirv.Sin(a._instruction));

  @override
  double _op(double a) => sin(a);
}

class _Cos extends _UniOp {
  _Cos(Expression a) : super(a, spirv.Cos(a._instruction));

  @override
  double _op(double a) => cos(a);
}

class _Tan extends _UniOp {
  _Tan(Expression a) : super(a, spirv.Tan(a._instruction));

  @override
  double _op(double a) => tan(a);
}

class _ASin extends _UniOp {
  _ASin(Expression a) : super(a, spirv.ASin(a._instruction));

  @override
  double _op(double a) => asin(a);
}

class _ACos extends _UniOp {
  _ACos(Expression a) : super(a, spirv.ACos(a._instruction));

  @override
  double _op(double a) => acos(a);
}

class _ATan extends _UniOp {
  _ATan(Expression a) : super(a, spirv.ATan(a._instruction));

  @override
  double _op(double a) => atan(a);
}

class _Exp extends _UniOp {
  _Exp(Expression a) : super(a, spirv.Exp(a._instruction));

  @override
  double _op(double a) => exp(a);
}

class _Log extends _UniOp {
  _Log(Expression a) : super(a, spirv.Log(a._instruction));

  @override
  double _op(double a) => log(a);
}

class _Exp2 extends _UniOp {
  _Exp2(Expression a) : super(a, spirv.Exp2(a._instruction));

  @override
  double _op(double a) => pow(2, a);
}

class _Log2 extends _UniOp {
  _Log2(Expression a) : super(a, spirv.Log2(a._instruction));

  @override
  double _op(double a) => log(a) / ln2;
}

class _Sqrt extends _UniOp {
  _Sqrt(Expression a) : super(a, spirv.Sqrt(a._instruction));

  @override
  double _op(double a) => sqrt(a);
}

class _InverseSqrt extends _UniOp {
  _InverseSqrt(Expression a) : super(a, spirv.InverseSqrt(a._instruction));

  @override
  double _op(double a) => 1.0 / sqrt(a);
}

abstract class _BinOp extends Expression {
  final Expression a;
  final Expression b;

  _BinOp(this.a, this.b, spirv.Instruction instruction)
      : assert(a != null),
        assert(b != null),
        assert(a._type == b._type),
        assert(instruction != null),
        super._(instruction);

  double _op(double a, double b);

  spirv.Type get _type => a._type;

  List<double> _evaluate() {
    final valueA = a._evaluate();
    final valueB = b._evaluate();
    final out = List<double>(valueA.length);
    for (int i = 0; i < out.length; i++) {
      out[i] = _op(valueA[i], valueB[i]);
    }
    return out;
  }
}

class _Add extends _BinOp {
  _Add(Expression a, Expression b)
      : super(a, b, spirv.OpFAdd(a._instruction, b._instruction));

  double _op(double a, double b) => a + b;
}

class _Subtract extends _BinOp {
  _Subtract(Expression a, Expression b)
      : super(a, b, spirv.OpFSub(a._instruction, b._instruction));

  double _op(double a, double b) => a - b;
}

class _Multiply extends _BinOp {
  _Multiply(Expression a, Expression b)
      : super(a, b, spirv.OpFMul(a._instruction, b._instruction));

  double _op(double a, double b) => a * b;
}

class _Divide extends _BinOp {
  _Divide(Expression a, Expression b)
      : super(a, b, spirv.OpFDiv(a._instruction, b._instruction));

  double _op(double a, double b) {
    if (b == 0) {
      throw DivideByZero();
    }
    return a / b;
  }
}

class _Mod extends _BinOp {
  _Mod(Expression a, Expression b)
      : super(a, b, spirv.OpFMod(a._instruction, b._instruction));

  double _op(double a, double b) => a % b;
}

class _ATan2 extends _BinOp {
  _ATan2(Expression a, Expression b)
      : super(a, b, spirv.ATan2(a._instruction, b._instruction));

  @override
  double _op(double a, double b) => atan2(a, b);
}

class _Pow extends _BinOp {
  _Pow(Expression a, Expression b)
      : super(a, b, spirv.Pow(a._instruction, b._instruction));

  @override
  double _op(double a, double b) => pow(a, b);
}

class _FMin extends _BinOp {
  _FMin(Expression a, Expression b)
      : super(a, b, spirv.FMin(a._instruction, b._instruction));

  @override
  double _op(double a, double b) => min(a, b);
}

class _FMax extends _BinOp {
  _FMax(Expression a, Expression b)
      : super(a, b, spirv.FMax(a._instruction, b._instruction));

  @override
  double _op(double a, double b) => max(a, b);
}

class _Step extends _BinOp {
  _Step(Expression edge, Expression x)
      : super(edge, x, spirv.Step(edge._instruction, x._instruction));

  @override
  double _op(double edge, double x) => x < edge ? 0 : 1;
}

double _length(List<double> vector) {
  double sum = 0;
  for (int i = 0; i < vector.length; i++) {
    final el = vector[i];
    sum += el * el;
  }
  return sqrt(sum);
}

class _Length extends Scalar {
  final Expression a;

  _Length(this.a)
      : assert(a._type != null),
        assert(a._type != spirv.floatT),
        super._(spirv.Length(a._instruction));

  List<double> _evaluate() => [_length(a._evaluate())];
}

class _Normalize extends Scalar {
  final Expression a;

  _Normalize(this.a)
      : assert(a._type != null),
        assert(a._type != spirv.floatT),
        super._(spirv.Normalize(a._instruction));

  List<double> _evaluate() {
    final aResult = a._evaluate();
    final len = _length(aResult);
    for (int i = 0; i < aResult.length; i++) {
      aResult[i] /= len;
    }
    return aResult;
  }
}

double _dot(List<double> a, List<double> b) {
  double sum = 0;
  for (int i = 0; i < a.length; i++) {
    sum += a[i] * b[i];
  }
  return sum;
}

class _Dot extends Scalar {
  final Expression a;
  final Expression b;

  _Dot(this.a, this.b)
      : assert(a._type != spirv.floatT),
        assert(b._type != spirv.floatT),
        super._(spirv.OpFDot(a._instruction, b._instruction));

  List<double> _evaluate() => [_dot(a._evaluate(), b._evaluate())];
}

class _Scale extends Expression {
  final Expression a;
  final Scalar b;

  _Scale(this.a, this.b)
      : assert(a._type != spirv.floatT),
        super._(spirv.OpVectorTimesScalar(a._instruction, b._instruction));

  spirv.Type get _type => a._type;

  List<double> _evaluate() {
    double scale = b.evaluate();
    return a._evaluate().map((x) => x * scale).toList();
  }
}

abstract class _TerOp extends Expression {
  final Expression a;
  final Expression b;
  final Expression c;

  _TerOp(this.a, this.b, this.c, spirv.Instruction instruction)
      : assert(a != null),
        assert(b != null),
        assert(c != null),
        assert(a._type == b._type && b._type == c._type),
        assert(instruction != null),
        super._(instruction);

  double _op(double a, double b, double c) => 0;

  spirv.Type get _type => a._type;

  List<double> _evaluate() {
    final valueA = a._evaluate();
    final valueB = b._evaluate();
    final valueC = c._evaluate();
    final out = List<double>(valueA.length);
    for (int i = 0; i < out.length; i++) {
      out[i] = _op(valueA[i], valueB[i], valueC[i]);
    }
    return out;
  }
}

class _Clamp extends _TerOp {
  _Clamp(Expression a, Expression b, Expression c)
      : super(a, b, c,
            spirv.FClamp(a._instruction, b._instruction, c._instruction));

  double _op(double a, double b, double c) => min(max(a, b), c);
}

class _Mix extends _TerOp {
  _Mix(Expression x, Expression y, Expression a)
      : super(x, y, a,
            spirv.FMix(x._instruction, y._instruction, a._instruction));

  double _op(double x, double y, double a) => vm.mix(x, y, a);
}

class _SmoothStep extends _TerOp {
  _SmoothStep(Expression x, Expression y, Expression a)
      : super(x, y, a,
            spirv.SmoothStep(x._instruction, y._instruction, a._instruction));

  double _op(double x, double y, double a) => vm.smoothStep(x, y, a);
}

class _FaceForward extends Expression {
  final Expression n;
  final Expression i;
  final Expression nref;

  _FaceForward(this.n, this.i, this.nref)
      : assert(n != null),
        assert(i != null),
        assert(nref != null),
        assert(n._type != null),
        assert(n._type != spirv.floatT),
        assert(n._type == i._type && i._type == nref._type),
        super._(
          spirv.FaceForward(n._instruction, i._instruction, nref._instruction),
        );

  spirv.Type get _type => n._type;

  @override
  List<double> _evaluate() => _dot(i._evaluate(), nref._evaluate()) < 0
      ? n._evaluate()
      : n._evaluate().map((i) => -i).toList();
}

class _Reflect extends Expression {
  final Expression i;
  final Expression n;

  _Reflect(this.i, this.n)
      : assert(i != null),
        assert(n != null),
        assert(i._type != null),
        assert(i._type != spirv.floatT),
        assert(i._type == n._type),
        super._(spirv.Reflect(i._instruction, n._instruction));

  spirv.Type get _type => i._type;

  @override
  List<double> _evaluate() {
    final iRes = i._evaluate();
    final nRes = n._evaluate();
    final dot = _dot(nRes, iRes);
    final out = List<double>(iRes.length);
    for (int index = 0; index < out.length; index++) {
      out[index] = iRes[index] - 2.0 * dot * nRes[index];
    }
    return out;
  }
}
