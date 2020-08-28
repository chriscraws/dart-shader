import 'dart:typed_data';
import 'package:expr/src/spirv.dart' as spirv;
import 'package:expr/src/constants.dart';

/// Specifies the numerical type of an instance of [Expression].
abstract class Type {
  VectorType get _vectorType;
  int get _vectorDimensions => vectorTypeDimensions[_vectorType];
}

/// Floating point number.
class Scalar extends Type {
  VectorType get _vectorType => VectorType.scalar;
}

/// Two-component vector.
class Vec2 extends Type {
  VectorType get _vectorType => VectorType.vec2;
}

/// Three-component vector.
class Vec3 extends Type {
  VectorType get _vectorType => VectorType.vec3;
}

/// Four-component vector.
class Vec4 extends Type {
  VectorType get _vectorType => VectorType.vec4;
}

/// Two-by-two matrix.
class Mat2 extends Type {
  VectorType get _vectorType => VectorType.mat2;
}

/// Three-by-three matrix.
class Mat3 extends Type {
  VectorType get _vectorType => VectorType.mat3;
}

/// Four-by-four matrix.
class Mat4 extends Type {
  VectorType get _vectorType => VectorType.mat4;
}

// Specifies the precision of an expression.
abstract class Precision {
  PrecisionType get _precisionType;
}

// Low precision
class LowP extends Precision {
  PrecisionType get _precisionType => PrecisionType.low;
}

// Medium precision
class MediumP extends Precision {
  PrecisionType get _precisionType => PrecisionType.medium;
}

// High precision
class HighP extends Precision {
  PrecisionType get _precisionType => PrecisionType.high;
}

/// Node within an SSIR abstract syntax tree.
abstract class Expression<P extends Precision, T extends Type> {
  final T _type;
  final P _precision;

  Expression._(this._precision, this._type);

  spirv.Instruction toInstruction();
}
