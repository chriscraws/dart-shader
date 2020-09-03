import 'dart:typed_data';
import 'package:expr/src/spirv.dart' as spirv;
import 'package:vector_math/vector_math.dart' as vm;

// Fragment can be used to construct a spir-v module
// compatible with Flutter.
abstract class Fragment {
  // Build returns a Vec4 that specifies the color of each fragment position.
  Vec4 get color;

  // Encode the fragment shader as Flutter-compatible SPIR-V.
  ByteBuffer toSPIRV() {
    final module = spirv.Module();
    module.main = color._instruction;
    return module.encode();
  }
}

abstract class Scalar extends _Expression with Numerical {
  Scalar._(spirv.Instruction inst) : super(inst);

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

abstract class Vec2 extends _Expression with Numerical {
  Vec2._(spirv.Instruction instruction) : super(instruction);

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

abstract class Vec3 extends _Expression with Numerical {
  Vec3._(spirv.Instruction instruction) : super(instruction);

  spirv.Type get _type => spirv.vec2T;

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

abstract class Vec4 extends _Expression with Numerical {
  Vec4._(spirv.Instruction instruction) : super(instruction);

  spirv.Type get _type => spirv.vec4T;

  factory Vec4(double x, double y, double z, double w) =>
      _ConstVec4(x, y, z, w);

  Vec4 operator +(Vec4 b) => _Vec4(_Add(this, b));
  Vec4 operator -(Vec4 b) => _Vec4(_Subtract(this, b));
  Vec4 operator -() => _Vec4(_Negate(this));
  Vec4 operator *(Vec4 b) => _Vec4(_Multiply(this, b));
  Vec4 operator /(Vec4 b) => _Vec4(_Divide(this, b));
  Vec4 operator %(Vec4 b) => _Vec4(_Mod(this, b));

  Scalar dot(Vec4 b) => _Scalar(_Dot(this, b));
  Vec4 scale(Scalar s) => _Vec4(_Scale(this, s));

  vm.Vector4 evaluate() => vm.Vector4.array(_evaluate());
}

/// Node within an SSIR abstract syntax tree.
abstract class _Expression {
  final spirv.Instruction _instruction;

  _Expression(this._instruction) : assert(_instruction != null);

  spirv.Type get _type;

  List<double> _evaluate();
}

mixin Numerical on _Expression {}

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
  final Numerical child;

  _Scalar(this.child)
      : assert(child != null),
        assert(child._type == spirv.floatT),
        super._(child._instruction);

  List<double> _evaluate() => child._evaluate();
}

class _Vec2 extends Vec2 {
  final Numerical child;

  _Vec2(this.child)
      : assert(child != null),
        assert(child._type == spirv.vec2T),
        super._(child._instruction);

  List<double> _evaluate() => child._evaluate();
}

class _Vec3 extends Vec3 {
  final Numerical child;

  _Vec3(this.child)
      : assert(child != null),
        assert(child._type == spirv.vec3T),
        super._(child._instruction);

  List<double> _evaluate() => child._evaluate();
}

class _Vec4 extends Vec4 {
  final Numerical child;

  _Vec4(this.child)
      : assert(child != null),
        assert(child._type == spirv.vec4T),
        super._(child._instruction);

  List<double> _evaluate() => child._evaluate();
}

class _Negate extends _Expression with Numerical {
  final Numerical a;

  _Negate(this.a)
      : assert(a != null),
        super(spirv.OpFNegate(a._instruction));

  spirv.Type get _type => a._type;

  List<double> _evaluate() => a._evaluate().map((v) => -v).toList();
}

abstract class _BinOp extends _Expression with Numerical {
  final Numerical a;
  final Numerical b;

  _BinOp(this.a, this.b, spirv.Instruction instruction)
      : assert(a != null),
        assert(b != null),
        assert(a._type == b._type),
        assert(instruction != null),
        super(instruction);

  spirv.Type get _type => a._type;

  List<double> _apply(double Function(double a, double b) fn) {
    final valueA = a._evaluate();
    final valueB = b._evaluate();
    final out = List<double>(valueA.length);
    for (int i = 0; i < out.length; i++) {
      out[i] = fn(valueA[i], valueB[i]);
    }
    return out;
  }
}

class _Add extends _BinOp {
  _Add(_Expression a, _Expression b)
      : super(a, b, spirv.OpFAdd(a._instruction, b._instruction));

  List<double> _evaluate() => _apply((a, b) => a + b);
}

class _Subtract extends _BinOp {
  _Subtract(_Expression a, _Expression b)
      : super(a, b, spirv.OpFSub(a._instruction, b._instruction));

  List<double> _evaluate() => _apply((a, b) => a - b);
}

class _Multiply extends _BinOp {
  _Multiply(_Expression a, _Expression b)
      : super(a, b, spirv.OpFMul(a._instruction, b._instruction));

  List<double> _evaluate() => _apply((a, b) => a * b);
}

class _Divide extends _BinOp {
  _Divide(_Expression a, _Expression b)
      : super(a, b, spirv.OpFDiv(a._instruction, b._instruction));

  List<double> _evaluate() => _apply((a, b) => a / b);
}

class _Mod extends _BinOp {
  _Mod(_Expression a, _Expression b)
      : super(a, b, spirv.OpFMod(a._instruction, b._instruction));

  List<double> _evaluate() => _apply((a, b) => a % b);
}

class _Dot extends Scalar {
  final _Expression a;
  final _Expression b;

  _Dot(this.a, this.b)
      : assert(a._type != spirv.floatT),
        assert(b._type != spirv.floatT),
        super._(spirv.OpFDot(a._instruction, b._instruction));

  List<double> _evaluate() {
    double sum = 0;
    final aResult = a._evaluate();
    final bResult = b._evaluate();
    for (int i = 0; i < aResult.length; i++) {
      sum += aResult[i] * bResult[i];
    }
    return [sum];
  }
}

class _Scale extends _Expression with Numerical {
  final _Expression a;
  final Scalar b;

  _Scale(this.a, this.b)
      : assert(a._type != spirv.floatT),
        super(spirv.OpVectorTimesScalar(a._instruction, b._instruction));

  spirv.Type get _type => a._type;

  List<double> _evaluate() {
    double scale = b.evaluate();
    return a._evaluate().map((x) => x * scale).toList();
  }
}
