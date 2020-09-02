import 'package:expr/src/spirv.dart' as spirv;

/// Node within an SSIR abstract syntax tree.
mixin _Expression {
  spirv.Instruction get _instruction;
  spirv.Type get _type;
}

abstract class Scalar with _Expression {
  Scalar._();

  spirv.Type get _type => spirv.floatT;

  factory Scalar(double value) => _ConstScalar(value);

  Scalar operator +(Scalar b) => _Scalar(_Add(this, b));
  Scalar operator -(Scalar b) => _Scalar(_Subtract(this, b));
  Scalar operator *(Scalar b) => _Scalar(_Multiply(this, b));
  Scalar operator /(Scalar b) => _Scalar(_Divide(this, b));
}

class _ConstScalar extends Scalar {
  final double value;

  _ConstScalar(this.value)
      : assert(value != null),
        super._();

  spirv.Instruction get _instruction => spirv.OpConstant(value);
}

class _Scalar extends Scalar {
  final _Expression _child;

  _Scalar(this._child)
      : assert(_child != null),
        assert(_child._type == spirv.floatT),
        super._();

  spirv.Instruction get _instruction => _child._instruction;
}

abstract class Vec4 with _Expression {
  Vec4._();

  spirv.Type get _type => spirv.vec4T;

  factory Vec4(double x, double y, double z, double w) =>
      _ConstVec4(x, y, z, w);
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
        super._();

  spirv.Instruction get _instruction =>
      spirv.OpConstantComposite.vec4(x, y, z, w);
}

abstract class _BinOp with _Expression {
  final _Expression a;
  final _Expression b;

  _BinOp(this.a, this.b)
      : assert(a != null),
        assert(b != null),
        assert(a._type == b._type);

  spirv.Type get _type => a._type;
}

class _Add extends _BinOp {
  _Add(_Expression a, _Expression b) : super(a, b);

  spirv.Instruction get _instruction =>
      spirv.OpFAdd(a._instruction, b._instruction);
}

class _Subtract extends _BinOp {
  _Subtract(_Expression a, _Expression b) : super(a, b);

  spirv.Instruction get _instruction =>
      spirv.OpFSub(a._instruction, b._instruction);
}

class _Multiply extends _BinOp {
  _Multiply(_Expression a, _Expression b) : super(a, b);

  spirv.Instruction get _instruction =>
      spirv.OpFMul(a._instruction, b._instruction);
}

class _Divide extends _BinOp {
  _Divide(_Expression a, _Expression b) : super(a, b);

  spirv.Instruction get _instruction =>
      spirv.OpFDiv(a._instruction, b._instruction);
}
