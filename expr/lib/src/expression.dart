import 'dart:typed_data';
import 'package:expr/src/spirv.dart' as spirv;

// Context is used to specify uniforms for a fragment shader,
// it also provides built-in inputs.
class Context {
  Context._();
}

// Fragment can be used to construct a spir-v module
// compatible with Flutter.
abstract class Fragment {
  // Build returns a Vec4 that specifies the color of each fragment position.
  Vec4 build(Context context);

  // Encode the fragment shader as Flutter-compatible SPIR-V.
  ByteBuffer toSPIRV() {
    final module = spirv.Module();
    module.main = build(Context._())._instruction;
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
}

abstract class Vec2 extends _Expression with Numerical {
  Vec2._(spirv.Instruction instruction) : super(instruction);

  spirv.Type get _type => spirv.vec2T;

  factory Vec2(double x, double y) => _ConstVec2(x, y);
}

abstract class Vec4 extends _Expression with Numerical {
  Vec4._(spirv.Instruction instruction) : super(instruction);

  spirv.Type get _type => spirv.vec4T;

  factory Vec4(double x, double y, double z, double w) =>
      _ConstVec4(x, y, z, w);
}

/// Node within an SSIR abstract syntax tree.
abstract class _Expression {
  final spirv.Instruction _instruction;

  _Expression(this._instruction) : assert(_instruction != null);

  spirv.Type get _type;
}

mixin Numerical on _Expression {}

class _ConstScalar extends Scalar {
  final double value;

  _ConstScalar(this.value)
      : assert(value != null),
        super._(spirv.OpConstant(value));
}

class _ConstVec2 extends Vec2 {
  final double x;
  final double y;

  _ConstVec2(this.x, this.y)
      : assert(x != null),
        assert(y != null),
        super._(spirv.OpConstantComposite.vec2(x, y));
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
}

class _Scalar extends Scalar {
  _Scalar(Numerical child)
      : assert(child != null),
        assert(child._type == spirv.floatT),
        super._(child._instruction);
}

class _Negate extends _Expression with Numerical {
  final Numerical a;

  _Negate(this.a)
      : assert(a != null),
        super(spirv.OpFNegate(a._instruction));

  spirv.Type get _type => a._type;
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
}

class _Add extends _BinOp {
  _Add(_Expression a, _Expression b)
      : super(a, b, spirv.OpFAdd(a._instruction, b._instruction));
}

class _Subtract extends _BinOp {
  _Subtract(_Expression a, _Expression b)
      : super(a, b, spirv.OpFSub(a._instruction, b._instruction));
}

class _Multiply extends _BinOp {
  _Multiply(_Expression a, _Expression b)
      : super(a, b, spirv.OpFMul(a._instruction, b._instruction));
}

class _Divide extends _BinOp {
  _Divide(_Expression a, _Expression b)
      : super(a, b, spirv.OpFDiv(a._instruction, b._instruction));
}
